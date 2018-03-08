-- ===========================================================================================
-- Author				: Ramesh Bangi
-- Create date			: 7/28/2015
-- Description			: This stored procedure is used to Getting Exception Queue View Data
-- Execution Process	: [dbo].[sp_ExceptionQueueViewCreative]'0647e2c4a8bb9be7f75583868b38714295811cb7','Online Video',0,0
-- Updated By			: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--						: Updated by Ramesh Bangi for Online Display and Online Video
--						: Karunakar on 12th October 2015,Adding Mobile Media Stream for fetching View Creative data
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_ExceptionQueueViewCreative]  
(
@CreativeSignature AS NVARCHAR(MAX),
@MediaStreamId AS NVARCHAR(MAX),
@AdID AS INT,
@OccurrenceID AS BIGINT      
)
AS
BEGIN
			DECLARE @ondpk_id VARCHAR(MAX)
			DECLARE @onvpk_id VARCHAR(MAX)
			DECLARE @mobpk_Patternstgid VARCHAR(MAX)
			Declare @MediaStreamValue As NVARCHAR(50)
			Select @MediaStreamValue = Value From [Configuration] Where SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamId
			
              BEGIN TRY
              IF(@MediaStreamValue='CIN')
                     BEGIN
                           SELECT  [dbo].[PatternStaging].[CreativeStgID],
                           [dbo].[PatternStaging].[CreativeSignature],
                           [dbo].[CreativeDetailStagingCIN].[CreativeRepository]+       [dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS CreativeFilePath,
                           [dbo].[CreativeDetailStagingCIN].[CreativeFileSize]
						  
                           FROM  [dbo].[PatternStaging]
                         INNER JOIN [dbo].[CreativeDetailStagingCIN] ON 
                         [dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
                         WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
                     END
              IF(@MediaStreamValue='TV')
                     BEGIN
                           SELECT  [dbo].[PatternStaging].[CreativeStgID],
                           [dbo].[PatternStaging].[CreativeSignature],
                           [dbo].[CreativeDetailStagingTV].[MediaFilePath]+
                           [dbo].[CreativeDetailStagingTV].[MediaFileName] AS [PrimarySource],
                           [dbo].[CreativeDetailStagingTV].[FileSize],
                           [dbo].[CreativeDetailStagingTV].[MediaFormat]
                           FROM  [dbo].[PatternStaging]
                         INNER JOIN [dbo].[CreativeDetailStagingTV] ON 
                         [dbo].[CreativeDetailStagingTV].[CreativeStgMasterID]=[dbo].[PatternStaging].[CreativeStgID]
                         WHERE [dbo].[PatternStaging].[CreativeSignature]= @CreativeSignature
                     END
         IF(@MediaStreamValue='OD')
                     BEGIN
                           SELECT  [dbo].[PatternStaging].[CreativeStgID],
                           [dbo].[PatternStaging].[CreativeSignature],
                           [dbo].[CreativeDetailStagingODR].[CreativeRepository]+
                           [dbo].[CreativeDetailStagingODR].[CreativeAssetName] AS [PrimarySource],
                           [dbo].[CreativeDetailStagingODR].[CreativeFileSize]
                           FROM  [dbo].[PatternStaging]
                         INNER JOIN [dbo].[CreativeDetailStagingODR] ON 
                         [dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
                         WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
                     END
                    
            IF(@MediaStreamValue='RAD')
                     BEGIN
                       select [PatternStaging].[PatternStagingID] as PatternMasterStagingID, [CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].mediaformat))  AS CreativeFilePath from [PatternStaging]
              inner join [CreativeStaging] on [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
              inner join [CreativeDetailStagingRA] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID]
              --inner join [PatternDetailRAStaging] on  [PatternDetailRAStaging].[PatternStgID]=[PatternStaging].[PatternStagingID]
              and PatternStaging.CreativeSignature=@CreativeSignature
                     END
			IF(@MediaStreamValue='OND')
                     BEGIN
					 SELECT DISTINCT @ondpk_id=[PatternStagingID] FROM [OccurrenceDetailOND] WHERE creativesignature=@CreativeSignature
					       SELECT  distinct [dbo].[PatternStaging].[CreativeStgID],
						   [dbo].[CreativeStaging].CreativeSignature AS creativesignature,
                           [dbo].[CreativeDetailStagingOND].[CreativeRepository]+[dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
                           [dbo].CreativeDetailStagingOND.[FileSize]
                           FROM  [dbo].[PatternStaging]
                         INNER JOIN [dbo].CreativeDetailStagingOND ON 
                         [dbo].CreativeDetailStagingOND.[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
						 inner join [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID]
                         WHERE [PatternStaging].[PatternStagingID]=@ondpk_id
						 and CreativeDetailStagingOND.CreativeDownloaded=1 and CreativeDetailStagingOND.FileSize>0 
						 and CreativeDetailStagingOND.CreativeFileType='jpg'
					 END
			IF(@MediaStreamValue='ONV')
                     BEGIN
					 SELECT DISTINCT @onvpk_id=[PatternStagingID] FROM [OccurrenceDetailONV] WHERE creativesignature=@CreativeSignature
					       SELECT  distinct [dbo].[PatternStaging].[CreativeStgID],
						   [dbo].[CreativeStaging].CreativeSignature AS creativesignature,
                           [dbo].[CreativeDetailStagingONV].[CreativeRepository]+[dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
                           [dbo].CreativeDetailStagingONV.[FileSize]
                           FROM  [dbo].[PatternStaging]
                         INNER JOIN [dbo].CreativeDetailStagingONV ON 
                         [dbo].CreativeDetailStagingONV.[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
						 inner join [CreativeStaging] on [CreativeStaging].[CreativeStagingID]=[PatternStaging].[CreativeStgID]
                         WHERE [PatternStaging].[PatternStagingID]=@onvpk_id
						 and CreativeDetailStagingONV.CreativeDownloaded=1 and CreativeDetailStagingONV.FileSize>0 and CreativeDetailStagingONV.CreativeFileType='MP4'
					 END
			IF(@MediaStreamValue='MOB')
                     BEGIN
					      SELECT  top 1 [dbo].[CreativeDetailStagingMOB].[CreativeStagingID] as FK_CreativeStgId,
						   [dbo].[CreativeDetailStagingmob].[CreativeRepository]+[dbo].[CreativeDetailStagingmob].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
                           [dbo].CreativeDetailStagingmob.[FileSize],
						   [dbo].[CreativeDetailStagingMOB].[CreativeFileType]
                          FROM  [dbo].[CreativeDetailStagingMOB]  
					WHERE SignatureDefault=@CreativeSignature
					and CreativeDownloaded=1 and FileSize>0 
					ORDER BY [CreativeDetailStagingID]

					 END
            IF(@MediaStreamValue='PUB')
                     BEGIN
                     IF(@OccurrenceID=0)
                           BEGIN
                                  SELECT         AdId,
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
                           
                           create table #TempCreativeMasters1
                           (
                           rownum  int identity(1,1),
                           creativemasterid int,
                           createdtm datetime)

                           insert into #TempCreativeMasters1
                           select distinct top 5 CreativeMasterID, [CreatedDT] from vw_PublicationCreatives where adid=@adid and isDeleted=0 order by [CreatedDT] desc

                                  DECLARE @BasePath As NVARCHAR(20)

                                  SELECT @BasePath=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'



                                         select AdId,[OccurrenceDetailPUBID] AS OccurrenceID,

                                                              CreativeMasterID,CreativeDetailID,

                                                              CreativeAssetName  AS [ImageName],

                                                              PatternMasterCreativeMasterID,

                                                              CreativeRepository,

                                                         @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],

                                                         @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],

                                                         '20' AS ImageSize,
                                                         pagenumber,
                                                         0 AS IsSelected from vw_PublicationCreatives where CreativeMasterID in (select  creativemasterid from #TempCreativeMasters)
                           
                                  ORDER BY PageNumber ASC,SourceOccurrenceId DESC
                           drop table    #TempCreativeMasters1
                           END
                     END

            IF(@MediaStreamValue='CIR')
                     BEGIN
                     IF(@OccurrenceID=0)

                           BEGIN

                                  SELECT         AdId,

                                                  [OccurrenceDetailCIRID] AS OccurrenceID,

                                                  CreativeMasterID,

                                                  CreativeDetailID,

                                                  PatternMasterCreativeMasterID,

                                                  PageNumber,

                                                  CreativeRepository +CreativeAssetName AS [PrimarySource],

                                                  CreativeAssetThumbnailName As [ThumbnailSource], 

                                                  isDeleted

                                  FROM  vw_CircularCreatives WHERE ADID=@AdID AND isDeleted=0  and PrimaryCreativeIndicator=1

                                  ORDER BY Pagenumber ASC,CreativeDetailID

                           END

                     ELSE

                           BEGIN
                           
                           create table TempCreativeMasters
                           (
                           rownum  int identity(1,1),
                           creativemasterid int,
                           createdtm datetime)

                           insert into TempCreativeMasters
                           select distinct  CreativeMasterID, [CreatedDT] from vw_CircularCreatives where adid=@adid and isDeleted=0 order by [CreatedDT] desc

                                  DECLARE @BasePath1 As NVARCHAR(20)

                        SELECT @BasePath1=Value FROM [Configuration] WHERE SystemName='All' and ComponentName='Creative Repository'

                                         select AdId,[OccurrenceDetailCIRID] AS OccurrenceID,

                                                              CreativeMasterID,CreativeDetailID,

                                                              CreativeAssetName  AS [ImageName],

                                                              PatternMasterCreativeMasterID,

                                                              CreativeRepository,

                                                         @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName AS [LargeImagepath],

                                                         @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [ThumbImagepath],

                                                         '20' AS ImageSize,
                                                         pagenumber,
                                                         0 AS IsSelected from vw_CircularCreatives where CreativeMasterID in (select  creativemasterid from TempCreativeMasters)
                           
                                  ORDER BY PageNumber ASC,SourceOccurrenceId DESC
                           drop table    TempCreativeMasters
                           END
                     END
             
			 ---L.E. 8.31.2017 added EM to view in exception queue
			IF(@MediaStreamValue='EM')
			BEGIN
				IF(@AdID>0)
				BEGIN 
					SELECT  AdId,
					pK_OccurrenceID AS OccurrenceID,
					CreativeMasterID,
					CreativeDetailID,
					PatternMasterCreativeMasterID,
					PageNumber,
					CreativeRepository +CreativeAssetName AS [PrimarySource],
					CreativeAssetThumbnailName As [ThumbnailSource], 
					isDeleted                               
					FROM  vw_emailCreatives WHERE ADID=@AdID
				END 
				ELSE
				BEGIN
					Select 
					[dbo].[PatternStaging].[CreativeStgID],
					[dbo].[PatternStaging].[CreativeSignature],
					[dbo].[CreativeDetailStagingEM].[CreativeRepository]+
					[dbo].[CreativeDetailStagingEM].[CreativeAssetName] AS [PrimarySource],
					[dbo].[CreativeDetailStagingEM].[CreativeFileSize]
					FROM  [dbo].[PatternStaging]
					Inner join [dbo].[OccurrenceDetailEM]  on [dbo].[OccurrenceDetailEM].PatternID=[dbo].[PatternStaging].PatternID
					INNER JOIN [dbo].[CreativeDetailStagingEM] ON 
					[dbo].[CreativeDetailStagingEM].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[OccurrenceDetailEM].occurrencedetailEMID =@OccurrenceID
				END

                 
			END

			  END TRY
              BEGIN CATCH
                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                                  RAISERROR ('sp_ExceptionQueueViewCreative: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH
END