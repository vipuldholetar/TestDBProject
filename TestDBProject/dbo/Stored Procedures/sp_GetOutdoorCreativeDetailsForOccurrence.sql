-- =============================================
-- Author			: Arun Nair
-- Create date		: 07/15/2015
-- Description		: Get OccurrenceCreative Details for Outdoor
-- Execution Process: 
-- Updated By		: sp_GetOutdoorCreativeDetailsForOccurrence 11107,20018
--					  Arun on 08/12/2015 -Cleanup ONEMT 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetOutdoorCreativeDetailsForOccurrence]
(
@Adid As Int,
@OccurrenceID AS INT
)
AS
BEGIN
			SET NOCOUNT ON;
						DECLARE @BasePath As NVARCHAR(max)
						SELECT @BasePath=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'


				BEGIN TRY
						 SELECT   [dbo].[OccurrenceDetailODR].[AdID],
								  [dbo].[OccurrenceDetailODR].[OccurrenceDetailODRID] AS OccurrenceId,
								  [dbo].[Creative].PK_Id AS CreativeMasterID,
								  [dbo].[CreativeDetailODR].[CreativeDetailODRID] AS CreativeDetailID,
								  CreativeAssetName  AS [ImageName],
								  [dbo].[Pattern].[CreativeID]  AS PatternMasterCreativeMasterID,
								  @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LargeImagepath],
								  @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
								 1 As Pagenumber,
								 '20' AS ImageSize,
								  0 AS IsSelected
						 FROM  [dbo].[OccurrenceDetailODR]
						 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[OccurrenceDetailODR].[PatternID]
						 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
						 INNER JOIN [dbo].[CreativeDetailODR] ON [dbo].[CreativeDetailODR].CreativeMasterID= [dbo].[Pattern].[CreativeID]
						 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[OccurrenceDetailODR].[OccurrenceDetailODRID]
						  WHERE [dbo].[OccurrenceDetailODR].[AdID]=@Adid
						
				END TRY

			  BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_GetOutdoorCreativeDetailsForOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 				  
			  END CATCH 

END
