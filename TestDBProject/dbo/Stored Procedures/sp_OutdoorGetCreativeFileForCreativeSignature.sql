-- ====================================================================================================
-- Author			: ARUN NAIR
-- Create date		: 07/07/2015
-- Description		: This stored procedure is used to Getting Outdoor Creative ImageFile
-- Execution Process: [sp_OutdoorGetPrimaryCreativeFileForAd] 8079 
-- Updated By		: 
-- =====================================================================================================

CREATE PROCEDURE [dbo].[sp_OutdoorGetCreativeFileForCreativeSignature] --'AT&T 4G NetWork,ATL,07-06-15.jpg'
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY
			SELECT  [dbo].[PatternStaging].[CreativeStgID],
					[dbo].[PatternStaging].[CreativeSignature] AS [CreativeSignatureCODE],
					[dbo].[CreativeDetailStagingODR].[CreativeRepository]+
					[dbo].[CreativeDetailStagingODR].[CreativeAssetName] AS [PrimarySource],
					[dbo].[CreativeDetailStagingODR].[CreativeFileSize],
					[dbo].[CreativeDetailStagingODR].[CreativeFileType] as [Format]
				   FROM  [dbo].[PatternStaging]
			INNER JOIN [dbo].[CreativeDetailStagingODR] ON 
			[dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_OutdoorGetCreativeFileForCreativeSignature]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END