-- ==============================================================================================
-- Author			: Arun Nair
-- Create date		: 19/05/2015
-- Description		: Get AdCreative Details
-- Execution Process: [sp_GetCircularCreativeDetailsForAd]  37815,630094
-- Updated By		: Arun Nair on 29/05/2015 select * from ad
--					: Updated Changes Based on Configuration Master table LOV on 01 july 2015
--					: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--					: Karunakar on 15th Sep 2015
--					: Arun Nair on 12/14/2014 - Added Additional fields from CreativesCIR
--					: RP on 10/14/2014 - for showing creative Details in Occurrence Tab 
-- =============================================================================================
CREATE PROCEDURE [dbo].[sp_GetCircularCreativeDetailsForAd]
(
@AdID AS INT,
@OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
			IF(@OccurrenceID=0)	--Checking if Occurrence id is 0,getting data from ad view Creatives
				BEGIN
					 SELECT	  AdId,
							  [OccurrenceDetailCIRID] AS OccurrenceID,
							  CreativeMasterID,
							  CreativeDetailID,
							  PatternMasterCreativeMasterID,
							  PageNumber,
							  CreativeRepository +CreativeAssetName AS [PrimarySource],
							  CreativeAssetThumbnailName As [ThumbnailSource], 
							  isDeleted,
							   [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
							  [PageEndDT],PageName,PubPageNumber
					 FROM  vw_CircularCreatives WHERE sourceoccurrenceid =(select [PrimaryOccurrenceID] from ad where [AdID]=@AdID AND isDeleted=0)  and PrimaryCreativeIndicator=1
					
					 ORDER BY Pagenumber ASC,CreativeDetailID
				END
			ELSE				--getting  top 5 view Creatives from ad 
				BEGIN
				create table #TempCreativeMasters
				(
				rownum  int identity(1,1),
				creativemasterid int,
				createdtm datetime)
				insert into #TempCreativeMasters
				select distinct top 5 CreativeMasterID, [CreatedDT] from vw_CircularCreatives where adid=@AdID and isDeleted=0 and [OccurrenceDetailCIRID]<>@OccurrenceID order by [CreatedDT] desc				
				DECLARE @BasePath As NVARCHAR(100)
				SELECT @BasePath=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'
				SELECT rowid,AdId,OccurrenceID,CreativeMasterID,CreativeDetailID,[ImageName],PatternMasterCreativeMasterID,
					CreativeRepository,[LargeImagepath],[ThumbImagepath],width,height,pagenumber,IsSelected, [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
					 [PageEndDT],PageName,PubPageNumber from (
					SELECT  1 as rowid,AdId,[OccurrenceDetailCIRID] AS OccurrenceID,
					CreativeMasterID,CreativeDetailID,
					CreativeAssetName  AS [ImageName],
					PatternMasterCreativeMasterID,
					CreativeRepository,
					@BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],
					@BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
					'135' AS width,
					'135' AS height,
					pagenumber,
					0 AS IsSelected, [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
					 [PageEndDT],PageName,PubPageNumber
					 from vw_CircularCreatives where [OccurrenceDetailCIRID]=@OccurrenceID
					 
					UNION
				
					SELECT 2 as rowid,AdId,[OccurrenceDetailCIRID] AS OccurrenceID,
					CreativeMasterID,CreativeDetailID,
					CreativeAssetName  AS [ImageName],
					PatternMasterCreativeMasterID,
					CreativeRepository,
					@BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],
					@BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],
					'135' AS width,
					'135' AS height,
					pagenumber,
					0 AS IsSelected, [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
					 [PageEndDT],PageName,PubPageNumber
					 from vw_CircularCreatives where CreativeMasterID in (select  creativemasterid from #TempCreativeMasters) and [OccurrenceDetailCIRID]<>@OccurrenceID
					) data order by pagenumber,rowid
					
					
				drop table	#TempCreativeMasters
				END
		END TRY
		BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_GetCircularCreativeDetailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
END
