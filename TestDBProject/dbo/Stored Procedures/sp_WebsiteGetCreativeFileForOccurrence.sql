-- =================================================================================================
-- Author				: Ramesh Bangi
-- Create date			: 10/27/2015
-- Description			: Get Website Creative File
-- Execution Process	: [dbo].[sp_WebsiteGetCreativeFileForOccurrence] 14
-- Updated By			: 
--								
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteGetCreativeFileForOccurrence] 
(
 @OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
					DECLARE @PatternMasterId AS INTEGER
					DECLARE @CreativeMasterId AS INTEGER

					SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailWEB] WHERE [OccurrenceDetailWEBID]=@OccurrenceID
					SELECT @CreativeMasterId=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PatternMasterId
					SELECT   [CreativeDetailWebID] AS CreativeDetailID,CreativeMasterID  ,					
					[dbo].[CreativeDetailWEB].[CreativeRepository]+	[dbo].[CreativeDetailWEB].CreativeAssetName AS [PrimarySource],
					[dbo].[CreativeDetailWEB].[CreativeFileSize] AS [FileSize],
					[dbo].[CreativeDetailWEB].[CreativeFileType] AS [Format]
					FROM  [dbo].[CreativeDetailWEB] WHERE [dbo].[CreativeDetailWEB].[CreativeMasterID]= @CreativeMasterId
				
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_WebsiteGetCreativeFileForOccurrence] : %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
