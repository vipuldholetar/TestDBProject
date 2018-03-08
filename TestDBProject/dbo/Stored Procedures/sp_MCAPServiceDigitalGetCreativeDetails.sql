
CREATE PROCEDURE [dbo].[sp_MCAPServiceDigitalGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS INT,
@AdId AS INT,
@PromotionID  AS INT 
)
AS
BEGIN
	   DECLARE @CreativeMasterStgid AS INT
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100) 
	   
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OND',@Mediatype='OND',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OND',@Mediatype='OND',@Ext=0
	   ELSE	
			SET @BasePath = @RemoteBasePath
		
		IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 

	   IF  @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT  distinct [PatternStaging].PatternID,
					   [dbo].[PatternStaging].[CreativeStgID] AS CreativeStagingId,
					   [dbo].[PatternStaging].[CreativeSignature],
					   @BasePath + [dbo].vw_CreativeDetailStagingDigital.[CreativeRepository]+
						  [dbo].vw_CreativeDetailStagingDigital.CreativeSignature+'.'+CreativeFileType AS LocalCreativeFilePath,
					   @RemoteBasePath + [dbo].vw_CreativeDetailStagingDigital.[CreativeRepository]+
						  [dbo].vw_CreativeDetailStagingDigital.CreativeSignature+'.'+CreativeFileType AS RemoteCreativeFilePath,
					   [dbo].vw_CreativeDetailStagingDigital.[FileSize] AS CreativeFileSize,
					   [dbo].vw_CreativeDetailStagingDigital.[CreativeFileType] as [Format]
				    FROM  [dbo].[PatternStaging]
			 INNER JOIN [dbo].vw_CreativeDetailStagingDigital ON 
			 [dbo].vw_CreativeDetailStagingDigital.[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			 WHERE [dbo].[PatternStaging].CreativeSignature=@CreativeSignature
			 and [dbo].vw_CreativeDetailStagingDigital.[CreativeRepository] is not null  and FileSize>0 
			 --and CreativeDownloaded=1
		  END
		  ELSE
		  BEGIN
			 SELECT  [dbo].[vw_OccurrenceDetailDigital].[AdID],
				    [Pattern].PatternID,
				    [dbo].[vw_OccurrenceDetailDigital].[OccurrenceDetailID] AS OccurrenceId,
				    [dbo].[Creative].PK_Id AS CreativeID,
				    [dbo].[vw_CreativeDetailDigital].[CreativeDetailID],
				    CreativeAssetName  AS [CreativeName],
				    @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As LocalCreativeFilePath,
				    @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LocalThumbnailpath],
				    @RemoteBasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteCreativeFilePath,
				    @RemoteBasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteThumbnailpath,
				    1 As Pagenumber,
				    '20' AS ImageSize,
				    0 AS IsSelected
			 FROM  [dbo].[vw_OccurrenceDetailDigital]
			 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[vw_OccurrenceDetailDigital].[PatternID]
			 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
			 INNER JOIN [dbo].[vw_CreativeDetailDigital] ON [dbo].[vw_CreativeDetailDigital].[CreativeID]= [dbo].[Pattern].[CreativeID]
			 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[vw_OccurrenceDetailDigital].[OccurrenceDetailID]
			 WHERE [dbo].[Pattern].CreativeSignature=@CreativeSignature
		  END
			 
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT  [dbo].[vw_OccurrenceDetailDigital].[AdID],
				    [Pattern].PatternID,
				    [dbo].[vw_OccurrenceDetailDigital].[OccurrenceDetailID] AS OccurrenceId,
				    [dbo].[Creative].PK_Id AS CreativeID,
				    [dbo].[vw_CreativeDetailDigital].[CreativeDetailID],
				    CreativeAssetName  AS [CreativeName],
				    isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,
				    isnull(ContentDetailID,0) ContentDetailID,
				    isnull(CreativeForCropStagingID,0) CreativeForCropStagingID,
				    @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As LocalCreativeFilePath,
				    @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LocalThumbnailpath],
				    @RemoteBasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteCreativeFilePath,
				    @RemoteBasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteThumbnailpath,
				    1 As Pagenumber,
				    '20' AS ImageSize,
				    0 AS IsSelected
			 FROM  [dbo].[vw_OccurrenceDetailDigital]
			 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[vw_OccurrenceDetailDigital].[PatternID]
			 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
			 INNER JOIN [dbo].[vw_CreativeDetailDigital] ON [dbo].[vw_CreativeDetailDigital].[CreativeID]= [dbo].[Pattern].[CreativeID]
			 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[vw_OccurrenceDetailDigital].[OccurrenceDetailID]
			 left join CreativeForCropStaging on [Creative].PK_Id = CreativeForCropStaging.CreativeMasterStagingID
			 left join CreativeContentDetailStaging on [vw_CreativeDetailDigital].CreativeDetailID = CreativeContentDetailStaging.CreativeDetailID
			 WHERE [dbo].[vw_OccurrenceDetailDigital].[AdID]=@Adid
	   END
	   ELSE IF @PromotionID > 0
	   BEGIN
		  SELECT CDR.creativeid,
				@BasePath + CDR.CreativeRepository+CDR.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CDR.CreativeRepository+CDR.CreativeAssetName AS RemoteCreativeFilePath
            FROM   [Promotion] PM 
                    INNER JOIN creativedetailinclude CDI 
                            ON PM.[CropID] = CDI.fk_cropid 
                    INNER JOIN [dbo].[creativecontentdetail] CCD 
                            ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                    INNER JOIN vw_creativedetailDigital CDR 
                            ON CDR.[CreativeDetailID] = CCD.[CreativeDetailID] 
            WHERE  PM.[PromotionID] = @PromotionID 
	   END
	   
END