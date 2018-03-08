
-- =================================================================================================
-- Author				: Ramesh Bangi
-- Create date			: 09/30/2015
-- Description			: This stored procedure is used to Getting Mobile Creative File
-- Execution Process	: [sp_MobileGetCreativeFileForCS] '002251d4de27bf0ab946220819026d5da50dacc3'
-- Updated By			: Karunakar on 15th October 2015,
--								1.Adding CreativeDownload and FileSize ,CreativeFileType Check in Query
--								2.Replacing  CreativeAssestname with SignatureDefault and CreativeFileType
--						: Karunakar on 20th Oct 2015,Removing Creative File Type Check in CreativeDetailStagingMOB
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_MobileGetCreativeFileForCS] 
(
@CreativeSignature AS NVARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY
					SELECT  Top 1  [CreativeDetailStagingID],
					[CreativeStagingID] as [CreativeMasterId],
					--[dbo].[PatternMasterStg].[FK_CreativeSignature],
					[dbo].[CreativeDetailStagingMOB].[CreativeRepository]+[dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
					[dbo].[CreativeDetailStagingMOB].[FileSize],
					[dbo].[CreativeDetailStagingMOB].[CreativeFileType] as [Format]
					FROM  [dbo].[CreativeDetailStagingMOB]  
					WHERE SignatureDefault=@CreativeSignature
					and CreativeDownloaded=1 and FileSize>0 
					ORDER BY [CreativeDetailStagingID]
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_MobileGetCreativeFileForCS]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END