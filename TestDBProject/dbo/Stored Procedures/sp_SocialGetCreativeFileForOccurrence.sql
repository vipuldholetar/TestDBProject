

-- =================================================================================================
-- Author				: Ramesh Bangi 
-- Create date			: 11/18/2015
-- Description			: Get Social Creative File
-- Execution Process	: 
-- Updated By			: 
--								
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_SocialGetCreativeFileForOccurrence] 
(
 @OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
					DECLARE @PatternMasterId AS INTEGER
					DECLARE @CreativeMasterId AS INTEGER

					SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceID
					SELECT @CreativeMasterId=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PatternMasterId
					SELECT   [CreativeDetailSOCID] AS CreativeDetailID,CreativeMasterID  ,					
					[dbo].[CreativeDetailSOC].[CreativeRepository]+[dbo].[CreativeDetailSOC].CreativeAssetName AS [PrimarySource],
					[dbo].[CreativeDetailSOC].[CreativeFileSize] AS [FileSize],
					[dbo].[CreativeDetailSOC].[CreativeFileType] AS [Format]
					FROM  [dbo].[CreativeDetailSOC] WHERE [dbo].[CreativeDetailSOC].[CreativeMasterID]= @CreativeMasterId
					AND [dbo].[CreativeDetailSOC].[CreativeRepository] is not null
					AND [dbo].[CreativeDetailSOC].[CreativeAssetName] is not null
				
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_SocialGetCreativeFileForOccurrence] : %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
