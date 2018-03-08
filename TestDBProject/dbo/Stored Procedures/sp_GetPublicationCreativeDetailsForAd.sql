
-- ================================================================================================
-- Author			:	Arun Nair
-- Create date		:	19/05/2015
-- Description		:	Get AdCreative Details Publication
-- Execution Process: [sp_GetPublicationCreativeDetailsForAd]  4025,0
-- Updated By		:	Karunakar on 23rd June 2015
--						Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_GetPublicationCreativeDetailsForAd]
(
@AdID AS INT,
@OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
			IF(@OccurrenceID=0)
				BEGIN
					 SELECT	  AdId,
							  [OccurrenceDetailPUBID] AS OccurrenceID,
							  CreativeMasterID,
							  CreativeDetailID,
							  PatternMasterCreativeMasterID,
							  PageNumber,
							  CreativeRepository + CreativeAssetName AS [PrimarySource],
							  CreativeAssetThumbnailName As [ThumbnailSource], 
							  isDeleted
					 FROM  vw_PublicationCreatives WHERE ADID=@AdID AND PrimaryCreativeIndicator=1 AND isDeleted=0  
					 ORDER BY Pagenumber ASC,CreativeDetailID
				END
			ELSE
				BEGIN
				
						--create table #TempCreativeMasters
						--(
						--rownum  int identity(1,1),
						--creativemasterid int,
						--createdtm datetime
						--)
						--insert into #TempCreativeMasters
						--select distinct top 5 CreativeMasterID, CreateDTM from vw_PublicationCreatives where adid=@adid and isDeleted=0 order by CreateDTM desc
						--DECLARE @BasePath As NVARCHAR(100)

						--SELECT @BasePath=Value FROM ConfigurationMaster WHERE SystemName='All' and ComponentName='Creative Repository'
						--		select AdId,PK_OccurrenceID AS OccurrenceID,
						--					CreativeMasterID,CreativeDetailID,

						--					CreativeAssetName  AS [ImageName],

						--					PatternMasterCreativeMasterID,

						--					CreativeRepository,

						--				  @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],

						--				  @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],

						--				  '20' AS ImageSize,
						--				  pagenumber,
						--				  0 AS IsSelected from vw_PublicationCreatives where CreativeMasterID in (select  creativemasterid from #TempCreativeMasters)
				
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
				SELECT DISTINCT TOP 5 CreativeMasterID, [CreatedDT] FROM [dbo].[vw_PublicationCreatives]
					WHERE adid=@AdID and isDeleted=0 and [OccurrenceDetailPUBID]<>@OccurrenceID ORDER BY [CreatedDT] DESC				
				
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
					   [PageTypeID],
					   PixelHeight,
					   PixelWidth,
					   FK_SizeID,
					   FormName,
					   [PageStartDT],
					   [PageEndDT],
					   PageName,
					   PubPageNumber 
					   FROM
				   (
					SELECT  1 as rowid,
					AdId,
					[OccurrenceDetailPUBID] AS OccurrenceID,
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
					[PageTypeID],
					PixelHeight,
					PixelWidth,
					FK_SizeID,
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					PubPageNumber
					FROM [dbo].[vw_PublicationCreatives]
					WHERE [OccurrenceDetailPUBID]=@OccurrenceID
					 
					UNION
				
					SELECT 2 as rowid,
					AdId,
					[OccurrenceDetailPUBID] AS OccurrenceID,
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
					[PageTypeID],
					PixelHeight,
					PixelWidth,
					FK_SizeID,
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					PubPageNumber
					FROM [dbo].[vw_PublicationCreatives]
					WHERE CreativeMasterID IN 
					 (
						SELECT  creativemasterid FROM #TempCreativeMasters
					 ) AND [OccurrenceDetailPUBID]<>@OccurrenceID
				)
				 DATA ORDER BY  pagenumber,rowid
					
				 DROP TABLE	#TempCreativeMasters
				END
		END TRY
		BEGIN CATCH
				 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_GetCreativeDetailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
		
END
