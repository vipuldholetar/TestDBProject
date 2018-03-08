CREATE PROCEDURE [dbo].[sp_MCAPServiceOnlineDisplayGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS INT,
@AdId AS INT 
)
AS
BEGIN
	   DECLARE @CreativeMasterStgid AS INT
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100) 
	   
	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OND',@Mediatype='OND',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OND',@Mediatype='OND',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF  @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT  distinct [PatternStaging].PatternID,
					   [dbo].[PatternStaging].[CreativeStgID] AS CreativeStagingId,
					   [dbo].[PatternStaging].[CreativeSignature],
					   @BasePath + [dbo].[CreativeDetailStagingOND].[CreativeRepository]+
						  [dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS LocalCreativeFilePath,
					   @RemoteBasePath + [dbo].[CreativeDetailStagingOND].[CreativeRepository]+
						  [dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS RemoteCreativeFilePath,
					   [dbo].[CreativeDetailStagingOND].[FileSize] AS CreativeFileSize,
					   [dbo].[CreativeDetailStagingOND].[CreativeFileType] as [Format]
				    FROM  [dbo].[PatternStaging]
			 INNER JOIN [dbo].[CreativeDetailStagingOND] ON 
			 [dbo].[CreativeDetailStagingOND].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			 WHERE [dbo].[PatternStaging].CreativeSignature=@CreativeSignature
			 and CreativeDownloaded=1 and FileSize>0 and [dbo].[CreativeDetailStagingOND].[CreativeRepository] is not null
		  END
		  ELSE
		  BEGIN
			 SELECT  [dbo].[OccurrenceDetailOND].[AdID],
				    [Pattern].PatternID,
				    [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID] AS OccurrenceId,
				    [dbo].[Creative].PK_Id AS CreativeID,
				    [dbo].[CreativeDetailond].[CreativeDetailONDID] AS CreativeDetailID,
				    CreativeAssetName  AS [CreativeName],
				    @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As LocalCreativeFilePath,
				    @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LocalThumbnailpath],
				    @RemoteBasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteCreativeFilePath,
				    @RemoteBasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteThumbnailpath,
				    1 As Pagenumber,
				    '20' AS ImageSize,
				    0 AS IsSelected
			 FROM  [dbo].[OccurrenceDetailOND]
			 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[OccurrenceDetailOND].[PatternID]
			 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
			 INNER JOIN [dbo].[CreativeDetailOND] ON [dbo].[CreativeDetailOND].[CreativeMasterID]= [dbo].[Pattern].[CreativeID]
			 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]
			 WHERE [dbo].[Pattern].CreativeSignature=@CreativeSignature
		  END
			 
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT  [dbo].[OccurrenceDetailOND].[AdID],
				    [Pattern].PatternID,
				    [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID] AS OccurrenceId,
				    [dbo].[Creative].PK_Id AS CreativeID,
				    [dbo].[CreativeDetailond].[CreativeDetailONDID] AS CreativeDetailID,
				    CreativeAssetName  AS [CreativeName],
				    @BasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As LocalCreativeFilePath,
				    @BasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As [LocalThumbnailpath],
				    @RemoteBasePath+  '\\'+ Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteCreativeFilePath,
				    @RemoteBasePath+'\\'+Replace(CreativeRepository,'\','\\') +CreativeAssetName As RemoteThumbnailpath,
				    1 As Pagenumber,
				    '20' AS ImageSize,
				    0 AS IsSelected
			 FROM  [dbo].[OccurrenceDetailOND]
			 INNER JOIN [dbo].[Pattern]ON [dbo].[Pattern].[PatternID]=[dbo].[OccurrenceDetailOND].[PatternID]
			 INNER JOIN [dbo].[Creative] ON [dbo].[Creative].PK_Id=[dbo].[Pattern].[CreativeID]
			 INNER JOIN [dbo].[CreativeDetailOND] ON [dbo].[CreativeDetailOND].[CreativeMasterID]= [dbo].[Pattern].[CreativeID]
			 inner join dbo.ad on ad.[PrimaryOccurrenceID]= [dbo].[OccurrenceDetailOND].[OccurrenceDetailONDID]
			 WHERE [dbo].[OccurrenceDetailOND].[AdID]=@Adid
	   END
	   
END