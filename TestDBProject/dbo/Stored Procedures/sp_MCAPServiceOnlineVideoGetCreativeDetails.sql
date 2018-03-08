CREATE PROCEDURE [dbo].[sp_MCAPServiceOnlineVideoGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS INT,
@AdId AS INT 
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100)

        IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='ONV',@Mediatype='ONV',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='ONV',@Mediatype='ONV',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT Distinct [dbo].[PatternStaging].PatternId,
				    [dbo].[PatternStaging].[CreativeStgID] as CreativeStagingId,
				    [dbo].[PatternStaging].[CreativeSignature],
				    @BasePath + [dbo].[CreativeDetailStagingONV].[CreativeRepository]+
						  [dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS LocalCreativeFilePath,
				    @RemoteBasePath + [dbo].[CreativeDetailStagingONV].[CreativeRepository]+
						  [dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS RemoteCreativeFilePath,
				    [dbo].[CreativeDetailStagingONV].[FileSize] as CreativeFileSize,
				    [dbo].[CreativeDetailStagingONV].[CreativeFileType] as [Format]
			 FROM  [dbo].[PatternStaging]
			 INNER JOIN [dbo].[CreativeDetailStagingONV] ON 
			 [dbo].[CreativeDetailStagingONV].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			 WHERE [dbo].[PatternStaging].CreativeSignature = @CreativeSignature
			 AND CreativeDownloaded=1 
			 AND FileSize>0 and CreativeFileType='MP4'
		  END
		  ELSE
		  BEGIN
			 SELECT Distinct [dbo].[Pattern].PatternId,
				    [dbo].[Pattern].[CreativeID],
				    [dbo].[Pattern].[CreativeSignature],
				    @BasePath + [dbo].[CreativeDetailONV].[CreativeRepository]+
						  [dbo].[CreativeDetailONV].[CreativeAssetName] AS LocalCreativeFilePath,
				    @RemoteBasePath + [dbo].[CreativeDetailONV].[CreativeRepository]+
						  [dbo].[CreativeDetailONV].[CreativeAssetName] AS RemoteCreativeFilePath,
				    [dbo].[CreativeDetailONV].[CreativeFileSize] as CreativeFileSize,
				    [dbo].[CreativeDetailONV].[CreativeFileType] as [Format]
			 FROM  [dbo].[Pattern]
			 INNER JOIN [dbo].[CreativeDetailONV] ON 
			 [dbo].[CreativeDetailONV].[CreativeMasterID]=[dbo].[Pattern].[CreativeID]
			 WHERE [dbo].[Pattern].CreativeSignature = @CreativeSignature
			 AND CreativeFileSize>0 and CreativeFileType='MP4'
		  END
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT Top 1 [Creative].PK_Id AS Creativeid,
				CreativeDetailONV.[CreativeDetailONVID] As CreativeDetailId,
				[Creative].PrimaryIndicator AS Primarycreativeindicator,
				@BasePath + CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName AS RemoteCreativeFilePath,
				cast(CreativeDetailONV.[CreativeDetailONVID] as varchar)+'-'+CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName as DetailIDwithFilepath
			 FROM [Creative] 
			 inner join CreativeDetailONV on [Creative].PK_Id=CreativeDetailONV.[CreativeMasterID] 
			 WHERE [Creative].[AdId]=@Adid
			 and [Creative].PrimaryIndicator=1
	   END
	   
END