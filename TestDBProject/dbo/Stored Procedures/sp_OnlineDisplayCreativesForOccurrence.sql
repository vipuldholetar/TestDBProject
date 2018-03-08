-- =============================================
-- Author			: Karunakar
-- Create date		: 21st Sep 2015
-- Description		: Get Occurrence Creative Details for Online Display
-- Execution Process: sp_OnlineDisplayCreativesForOccurrence 
-- Updated By		: 
-- =============================================
Create PROCEDURE [dbo].[sp_OnlineDisplayCreativesForOccurrence]
(
@Adid As Int
)
AS
BEGIN
			SET NOCOUNT ON;
						DECLARE @BasePath As NVARCHAR(max)
						SELECT @BasePath=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'


				BEGIN TRY
						 SELECT   [dbo].[OccurrenceDetailOND].[AdID],
								  [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID] AS OccurrenceId,
								  [dbo].[Creative].PK_Id AS CreativeMasterID,
								  [dbo].[CreativeDetailond].[CreativeDetailONDID] AS CreativeDetailID,
								  CreativeAssetName  AS [ImageName],
								  [dbo].[Pattern].[CreativeID]  AS PatternMasterCreativeMasterID,
								  @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LargeImagepath],
								  @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
								 1 As Pagenumber,
								 '20' AS ImageSize,
								  0 AS IsSelected
						 FROM  [dbo].[OccurrenceDetailOND]
						 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[OccurrenceDetailOND].[PatternID]
						 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
						 INNER JOIN [dbo].[CreativeDetailOND] ON [dbo].[CreativeDetailOND].[CreativeMasterID]= [dbo].[Pattern].[CreativeID]
						 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]
						  WHERE [dbo].[OccurrenceDetailOND].[AdID]=@Adid
						
				END TRY

			  BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_OnlineDisplayCreativesForOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 				  
			  END CATCH 

END
