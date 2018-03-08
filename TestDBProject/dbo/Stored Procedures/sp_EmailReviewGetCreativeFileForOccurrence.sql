
-- =================================================================================================
-- Author				: Arun Nair 
-- Create date			: 10/21/2015
-- Description			: Get Email Review Creative File
-- Execution Process	: 
-- Updated By			: 
--								
-- ==================================================================================================

CREATE PROCEDURE [dbo].[sp_EmailReviewGetCreativeFileForOccurrence] 
(
 @OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
					DECLARE @PatternMasterId AS INTEGER
					DECLARE @CreativeMasterId AS INTEGER

				SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceID
					SELECT @CreativeMasterId=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PatternMasterId

					SELECT   [CreativeDetailsEMID] AS CreativeDetailID,CreativeMasterID  ,					
					[dbo].[CreativeDetailEM].[CreativeRepository]+[dbo].[CreativeDetailEM].CreativeAssetName AS [PrimarySource],
					[dbo].[CreativeDetailEM].[CreativeFileSize] AS [FileSize],
					[dbo].[CreativeDetailEM].[CreativeFileType] AS [Format]
					FROM  [dbo].[CreativeDetailEM] 
					 INNER JOIN creative on Creative.pk_id = CreativeDetailEM.creativeMasterID where SourceOccurrenceId =@OccurrenceID					
					AND [dbo].[CreativeDetailEM].[CreativeRepository] is not null
					and [dbo].[CreativeDetailEM].CreativeAssetName is not null

						
			--   SELECT [CreativeStaging].CreativeStagingID as CreativeMasterID  , [PatternStaging].[PatternStagingID],
			--[CreativeDetailStagingEM].CreativeRepository+[CreativeDetailStagingEM].CreativeAssetName  AS [PrimarySource],
			--[CreativeDetailStagingEM].CreativeFileType as [Format],
			--[CreativeDetailStagingEM].CreativeFileSize AS [FileSize]
		 --   FROM [PatternStaging] 
   --INNER JOIN [CreativeStaging] on [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
   --inner join [CreativeDetailStagingEM] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingEM].CreativeStagingID
   --inner Join [OccurrenceDetailEM] on [OccurrenceDetailEM].OccurrenceDetailEMID = [CreativeStaging].OccurrenceID  where OccurrenceDetailEMID =@OccurrenceID
				
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_EmailReviewGetCreativeFileForOccurrence] : %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END