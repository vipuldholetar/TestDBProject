-- =====================================================================================================
-- Author			:	Arun Nair 
-- Create date		:	11/13/2015
-- Description		:	Get AdCreative Details
-- Execution Process:	[sp_SocialGetCreativeDetailsForAd]  10428,0
-- Updated By		:	Arun Nair on 02/12/2016 - Changes for showing creative in Occurrence Tab
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_SocialGetCreativeDetailsForAd]--10452,1
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
							  [dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID] AS OccurrenceID,
							  [Creative].PK_Id AS CreativeMasterID,
							  CreativeDetailSOC.[CreativeDetailSOCID] AS CreativeDetailID,
							  [Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
							  CreativeDetailSOC.PageNumber,
							  CreativeDetailSOC.CreativeRepository +CreativeDetailSOC.CreativeAssetName AS [PrimarySource],
							  [Creative].AssetThmbnlName as [ThumbnailSource], 
							  CreativeDetailSOC.Deleted as isDeleted					 
					 FROM  [dbo].[CreativeDetailSOC] 
					INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailSOC].CreativeMasterID =[dbo].[Creative].PK_Id
					INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailSOC].CreativeMasterID=[dbo].[Pattern].[CreativeID]
					INNER join [dbo].[OccurrenceDetailSOC] on dbo.[OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID]
					INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID]=[dbo].[AD].[PrimaryOccurrenceID]
					WHERE AD.[AdID]=@AdID AND CreativeDetailSOC.Deleted=0  and [Creative].PrimaryIndicator=1 AND AD.[PrimaryOccurrenceID]=@PrimaryOccurrenceID
					 ORDER BY Pagenumber ASC, CreativeDetailSOC.[CreativeDetailSOCID]
				END
			ELSE				--getting  top 5 view Creatives from ad 
				BEGIN
					--create table #TempCreativeMasters
					--(
					--rownum  int identity(1,1),
					--creativemasterid int,
					--createdtm datetime)
					--insert into #TempCreativeMasters
					--Select distinct top 5 CreativeMasterID, CreateDTM from vw_SocialCreatives where adid=@adid and isDeleted=0 order by CreateDTM desc
				
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
					--	0 AS IsSelected from [dbo].[vw_SocialCreatives] where CreativeMasterID in (select  creativemasterid from #TempCreativeMasters)
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
				SELECT DISTINCT TOP 5 CreativeMasterID, CreateDTM FROM  [dbo].[vw_SocialCreatives]
					WHERE adid=@AdID and isDeleted=0 and [OccurrenceDetailSOCID]<>@OccurrenceID ORDER BY CreateDTM DESC				
				
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
					   [SizeID],
					   FormName,
					   [PageStartDT],
					   [PageEndDT],
					   PageName,
					   PubPageNumber 
					   FROM
				   (
					SELECT  1 as rowid,
					AdId,
					[OccurrenceDetailSOCID] AS OccurrenceID,
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
					[SizeID],
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					PubPageNumber
					FROM  [dbo].[vw_SocialCreatives]
					WHERE [OccurrenceDetailSOCID]=@OccurrenceID
					 
					UNION
				
					SELECT 2 as rowid,
					AdId,
					[OccurrenceDetailSOCID] AS OccurrenceID,
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
					[SizeID],
					FormName,
					[PageStartDT],
					[PageEndDT],
					PageName,
					PubPageNumber
					FROM  [dbo].[vw_SocialCreatives]
					WHERE CreativeMasterID IN 
					 (
						SELECT  creativemasterid FROM #TempCreativeMasters
					 ) AND [OccurrenceDetailSOCID]<>@OccurrenceID
				)
				 DATA ORDER BY  pagenumber,rowid
					
				 DROP TABLE	#TempCreativeMasters
				END
		END TRY
		BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialGetCreativeDetailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
END
