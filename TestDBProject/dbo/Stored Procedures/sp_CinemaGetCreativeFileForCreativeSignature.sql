-- ===========================================================================================
-- Author				:	Arun Nair
-- Create date			:	07/17/2015
-- Description			:	This stored procedure is used to Getting Cinema Creative ImageFile
-- Execution Process	:	[dbo].[sp_CinemaGetCreativeFileForCreativeSignature]'337251aen'
-- Updated By			:	Karunakar on 7th Sep 2015
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_CinemaGetCreativeFileForCreativeSignature]  --'337251aen' --'AT&T 4G NetWork,ATL,07-06-15.jpg'
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY
			SELECT  [dbo].[PatternStaging].[CreativeStgID],
					[dbo].[PatternStaging].[CreativeSignature],
					[dbo].[CreativeDetailStagingCIN].[CreativeRepository]+	[dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS CreativeFilePath,
					[dbo].[CreativeDetailStagingCIN].[CreativeFileSize]
				   FROM  [dbo].[PatternStaging]
			INNER JOIN [dbo].[CreativeDetailStagingCIN] ON 
			[dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_CinemaGetCreativeFileForCreativeSignature: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END