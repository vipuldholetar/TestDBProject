-- ===========================================================================================
-- Author			: Murali Jaganathan
-- Create date		: 07/14/2015
-- Description		: This stored procedure is used to Getting Television Creative ImageFile
-- Execution Process: [sp_TelevisionGetPrimaryCreativeFileForAd] 8079 
-- Updated By		: Ramesh Bangi on 09/07/2015 for View Creative take mpg files only 
-- =============================================================================================

CREATE PROCEDURE [dbo].[sp_TelevisionGetCreativeFileForCreativeSignature] 
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY
			SELECT  [dbo].[PatternStaging].[CreativeStgID],
					[dbo].[PatternStaging].[CreativeSignature],
					[dbo].[CreativeDetailStagingTV].[MediaFilePath]+
					[dbo].[CreativeDetailStagingTV].[MediaFileName] AS [PrimarySource],
					[dbo].[CreativeDetailStagingTV].[FileSize],
					[dbo].[CreativeDetailStagingTV].[MediaFormat]
				   FROM  [dbo].[PatternStaging]
			INNER JOIN [dbo].[CreativeDetailStagingTV] ON 
			[dbo].[CreativeDetailStagingTV].[CreativeStgMasterID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeSignature]= @CreativeSignature AND [dbo].[CreativeDetailStagingTV].[MediaFormat]='mpg'
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_TelevisionGetCreativeFileForCreativeSignature]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END