
-- ====================================================================================
-- Author			:	Nanjunda
-- Create date		:	07/15/2015
-- Description		:	Get Creative names for Cinema Media Retreival Engine
-- Execution Process:	sp_CinemaUpdateCreativeDetails 
-- Updated By		:	Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- ======================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaUpdateCreativeDetails]
(
	@OccurrenceID			INT,
	@MediaFormat			VARCHAR(10),
	@MediaFilepath			VARCHAR(250),
	@MediaFileName			VARCHAR(250),
	@FileSize				BIGINT,
	@PatternMasterStagingID BIGINT,
	@MediaBasePath			VARCHAR(250)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @CreativeStagingID INT = 0, @MediaStream VARCHAR(250) = ''

			SELECT @MediaStream = value FROM [Configuration] WHERE valuetitle = 'Cinema'

			INSERT INTO [CreativeStaging](Deleted, [CreatedDT], [OccurrenceID]) VALUES(0, GETDATE(), @OccurrenceID)

			SELECT @CreativeStagingID = @@IDENTITY

			INSERT INTO [CreativeDetailStagingCIN]([CreativeStagingID], CreativeFileType, CreativeRepository, CreativeAssetName, CreativeFileSize)
			VALUES(@CreativeStagingID, REPLACE(@MediaFormat, '.', ''), '\' + @MediaStream + '\' + CONVERT(VARCHAR(250), @CreativeStagingID) + '\Original\', 
					CONVERT(VARCHAR(250), @CreativeStagingID) + @MediaFormat, @FileSize)

			UPDATE [PatternStaging]  SET [CreativeStgID] = @CreativeStagingID WHERE [PatternStagingID] = @PatternMasterStagingID

			SELECT [CreativeDetailStagingCINID], [CreativeStagingID], @MediaBasePath + '\'+ @MediaStream [AssetServer],
			@MediaBasePath + '\' + @MediaStream + '\' + CONVERT(VARCHAR(250), @CreativeStagingID) + '\Original\' + CONVERT(VARCHAR(250), @CreativeStagingID) + '.flv'[SharedFilePath],
			@MediaBasePath + '\' + @MediaStream + '\' + CONVERT(VARCHAR(250), @CreativeStagingID) + '\' + 'Original'[CreativeFolderPath]	
			FROM [CreativeDetailStagingCIN] 
			WHERE [CreativeDetailStagingCINID] = @@IDENTITY			
		COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('sp_CinemaUpdateCreativeDetails : %d: %s', 16, 1, @error, @message, @lineNo); 		
	END CATCH		
END