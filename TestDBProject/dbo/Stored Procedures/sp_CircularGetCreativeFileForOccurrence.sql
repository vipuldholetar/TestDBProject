-- =================================================================================================
-- Author				: Arun Nair 
-- Create date			: 10/21/2015
-- Description			: Get Email Creative File
-- Execution Process	: 
-- Updated By			: 
--								
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_CircularGetCreativeFileForOccurrence] 
(
 @OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
					DECLARE @PatternMasterId AS INTEGER
					DECLARE @CreativeMasterId AS INTEGER

					SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailCIR] WHERE [OccurrenceDetailCIRID]=@OccurrenceID
					SELECT @CreativeMasterId=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PatternMasterId
					SELECT   [CreativeDetailID] AS CreativeDetailID,CreativeMasterID  ,					
					[dbo].[CreativeDetailCIR].[CreativeRepository]+[dbo].[CreativeDetailCIR].CreativeAssetName AS [PrimarySource],
					[dbo].[CreativeDetailCIR].[SizeID] AS [FileSize],
					[dbo].[CreativeDetailCIR].[CreativeFileType] AS [Format]
					FROM  [dbo].[CreativeDetailCIR] WHERE [dbo].[CreativeDetailCIR].[CreativeMasterID]= @CreativeMasterId
					AND [dbo].[CreativeDetailCIR].[CreativeRepository] is not null
					and [dbo].[CreativeDetailCIR].CreativeAssetName is not null
				
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_CircularGetCreativeFileForOccurrence] : %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END