-- =================================================================================================
-- Author				: Ramesh Bangi
-- Create date			: 09/10/2015
-- Description			: This stored procedure is used to Getting Online Display Creative ImageFile
-- Execution Process	: [sp_OnlineVideoGetCreativeFileForCS] 'f2bd313e51da7d95e5cd3470d74a6982e9b6d8a3'
-- Updated By			: Karunakar on 15th October 2015,
--								1.Adding CreativeDownload and FileSize ,CreativeFileType Check in Query
--								2.Replacing  CreativeAssestname with SignatureDefault and CreativeFileType
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_OnlineVideoGetCreativeFileForCS] 
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		DECLARE @CreativeMasterStgid AS INT

		BEGIN TRY
			SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature
			SELECT Distinct  [dbo].[PatternStaging].[CreativeStgID],
					--[dbo].[PatternMasterStg].[FK_CreativeSignature],
					[dbo].[CreativeDetailStagingONV].[CreativeRepository]+[dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
					[dbo].[CreativeDetailStagingONV].[FileSize],
					[dbo].[CreativeDetailStagingONV].[CreativeFileType] as [Format]
				   FROM  [dbo].[PatternStaging]
			INNER JOIN [dbo].[CreativeDetailStagingONV] ON 
			[dbo].[CreativeDetailStagingONV].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeStgID]=@CreativeMasterStgid
			 and CreativeDownloaded=1 
			 and FileSize>0 and CreativeFileType='MP4'
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_OnlineVideoGetCreativeFileForCS]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END