-- =================================================================================================
-- Author				: Ramesh Bangi
-- Create date			: 09/10/2015
-- Description			: This stored procedure is used to Getting Online Display Creative ImageFile
-- Execution Process	: [sp_OnlineDisplayGetCreativeFileForCS] '2d402fc9327b6598e6d37a42733a8b3cd6cb3013'
-- Updated By			: Karunakar on 15th October 2015,
--								1.Adding CreativeDownload and FileSize ,CreativeFileType Check in Query
--								2.Replacing  CreativeAssestname with SignatureDefault and CreativeFileType

-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_OnlineDisplayGetCreativeFileForCS] 
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		DECLARE @CreativeMasterStgid AS INT

		BEGIN TRY
			SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature

			SELECT  distinct [dbo].[PatternStaging].[CreativeStgID],
					--[dbo].[PatternMasterStg].[FK_CreativeSignature],
					[dbo].[CreativeDetailStagingOND].[CreativeRepository]+[dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
					[dbo].[CreativeDetailStagingOND].[FileSize],
					[dbo].[CreativeDetailStagingOND].[CreativeFileType] as [Format]
				   FROM  [dbo].[PatternStaging]
			INNER JOIN [dbo].[CreativeDetailStagingOND] ON 
			[dbo].[CreativeDetailStagingOND].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeStgID]=@CreativeMasterStgid
			and CreativeDownloaded=1 and FileSize>0 and [dbo].[CreativeDetailStagingOND].[CreativeRepository] is not null
			
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_OnlineDisplayGetCreativeFileForCS]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END