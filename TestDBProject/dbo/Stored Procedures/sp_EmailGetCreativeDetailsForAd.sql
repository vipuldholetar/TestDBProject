-- ==============================================================================================
-- Author			:	KARUNAKAR
-- Create date		:	30th October 2015
-- Description		:	Get AdCreative Details
-- Execution Process:	[sp_EmailGetCreativeDetailsForAd]  10428,0
-- Updated By		:	Updated Karunakar on 5th Nov 2015,If OccurrenceID=0 ,Ad Primary Occurrence Creatives Only Display 
--					:	Arun Nair on 02/12/2016- Changes for Showing Creative in Occurrence tab
-- =============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailGetCreativeDetailsForAd]
(
@AdID AS INT,
@OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
			IF(@OccurrenceID=0)		--Checking if Occurrence id is 0,getting data from ad view Creatives
				BEGIN
					Declare @PrimaryOccurrenceID as BIGINT	
					SET @PrimaryOccurrenceID=(SELECT [PrimaryOccurrenceID] FROM  AD WHERE AD.[AdID]=@AdID)
					PRINT(@PrimaryOccurrenceID)
					 SELECT	  AD.[AdID] as AdId,
							  [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID] AS OccurrenceID,
							  [Creative].PK_Id AS CreativeMasterID,
							  CreativeDetailEM.[CreativeDetailsEMID] AS CreativeDetailID,
							  [Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
							 CreativeDetailEM.PageNumber,
							  CreativeDetailEM.CreativeRepository +CreativeDetailEM.CreativeAssetName AS [PrimarySource],
							  [Creative].AssetThmbnlName as [ThumbnailSource], 
							  CreativeDetailEM.Deleted as isDeleted					 
					 FROM  [dbo].[CreativeDetailEM] 
					INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
					INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailEM].CreativeMasterID=[dbo].[Pattern].[CreativeID]
					INNER join [dbo].[OccurrenceDetailEM] on dbo.[OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID]
					INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]=[dbo].[AD].[PrimaryOccurrenceID]
					where AD.[AdID]=@AdID AND (CreativeDetailEM.Deleted=0 or CreativeDetailEM.Deleted is null)
					  and [Creative].PrimaryIndicator=1 AND AD.[PrimaryOccurrenceID]=@PrimaryOccurrenceID
					 ORDER BY Pagenumber ASC, CreativeDetailEM.[CreativeDetailsEMID]
				END
			ELSE				--getting  top 5 view Creatives from ad 
				BEGIN
					--create table #TempCreativeMasters
					--(
					--rownum  int identity(1,1),
					--creativemasterid int,
					--createdtm datetime)
					--insert into #TempCreativeMasters
					--select distinct top 5 CreativeMasterID, CreateDTM from vw_EmailCreatives where adid=@adid and isDeleted=0 order by CreateDTM desc
				
					--DECLARE @BasePath As NVARCHAR(100)
					--SELECT @BasePath=Value FROM ConfigurationMaster WHERE SystemName='All' and ComponentName='Creative Repository'
					--	select AdId,PK_OccurrenceID AS OccurrenceID,
					--	CreativeMasterID,CreativeDetailID,
					--	CreativeAssetName  AS [ImageName],
					--	PatternMasterCreativeMasterID,
					--	CreativeRepository,
					--	@BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],
					--	@BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
					--	'20' AS ImageSize,
					--	pagenumber,
					--	0 AS IsSelected from [dbo].[vw_EmailCreatives] where CreativeMasterID in (select  creativemasterid from #TempCreativeMasters)
					--	ORDER BY PageNumber ASC,SourceOccurrenceId DESC
					--drop table	#TempCreativeMasters
						DECLARE @BasePath As NVARCHAR(100)
				CREATE TABLE #TempCreativeMasters
				(
					rownum  int identity(1,1),
					creativemasterid int,
					createdtm datetime
				)
				INSERT INTO #TempCreativeMasters
				SELECT DISTINCT TOP 5 CreativeMasterID, CreateDTM FROM [dbo].[vw_EmailCreatives]
					WHERE adid=@AdID and isDeleted=0 and PK_OccurrenceID<>@OccurrenceID ORDER BY CreateDTM DESC				
				
				SELECT @BasePath=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'
				SELECT rowid,
					   AdId,
					   OccurrenceID,
					   CreativeMasterID,
					   CreativeDetailID,
					   [ImageName],
					   PatternMasterCreativeMasterID,
					   CreativeRepository,
					   [LargeImagepath],
					   [ThumbImagepath],
					   width,
					   height,
					   pagenumber,
					   IsSelected,
					   PageTypeId,
					   PixelHeight,
					   PixelWidth,
					   [SizeID],
					   FormName,
					   [PageStartDT],
					   [PageEndDT],
					   PageName,
					   EmailPageNumber 
					   FROM
				   (
					SELECT  1 as rowid,
					AdId,
					PK_OccurrenceID AS OccurrenceID,
					CreativeMasterID,CreativeDetailID,
					CreativeAssetName  AS [ImageName],
					PatternMasterCreativeMasterID,
					CreativeRepository,
					@BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],
					@BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
					'135' AS width,
					'135' AS height,
					PageNumber,
					0 AS IsSelected, 
					PageTypeId,
					PixelHeight,
					PixelWidth,
					[SizeID],
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					EmailPageNumber
					FROM [dbo].[vw_EmailCreatives]
					WHERE PK_OccurrenceID=@OccurrenceID
					 
					UNION
				
					SELECT 2 as rowid,
					AdId,
					PK_OccurrenceID AS OccurrenceID,
					CreativeMasterID,
					CreativeDetailID,
					CreativeAssetName  AS [ImageName],
					PatternMasterCreativeMasterID,
					CreativeRepository,
					@BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],
					@BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
					'135' AS width,
					'135' AS height,
					pagenumber,
					0 AS IsSelected,
					PageTypeId,
					PixelHeight,
					PixelWidth,
					[SizeID],
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					EmailPageNumber
					FROM [dbo].[vw_EmailCreatives]
					WHERE CreativeMasterID IN 
					 (
						SELECT  creativemasterid FROM #TempCreativeMasters
					 ) AND PK_OccurrenceID<>@OccurrenceID
				)
				 DATA ORDER BY  pagenumber,rowid
					
				 DROP TABLE	#TempCreativeMasters
				END
		END TRY
		BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailGetCreativeDetailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
END
