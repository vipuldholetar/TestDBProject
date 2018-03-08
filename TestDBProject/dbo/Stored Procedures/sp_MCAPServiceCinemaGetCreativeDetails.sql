CREATE PROCEDURE [dbo].[sp_MCAPServiceCinemaGetCreativeDetails] 
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
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIN',@Mediatype='CIN',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIN',@Mediatype='CIN',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT  [dbo].[PatternStaging].PatternId,
				    [dbo].[PatternStaging].[CreativeStgID] AS CreativeStagingId,
					[dbo].[PatternStaging].[CreativeSignature],
					@BasePath + [dbo].[CreativeDetailStagingCIN].[CreativeRepository] + [dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS LocalCreativeFilePath,
					@RemoteBasePath + [dbo].[CreativeDetailStagingCIN].[CreativeRepository] + [dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS RemoteCreativeFilePath,
					[dbo].[CreativeDetailStagingCIN].[CreativeFileSize]
			 FROM  [dbo].[PatternStaging]
			 INNER JOIN [dbo].[CreativeDetailStagingCIN] ON 
			 [dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			 WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
		  END
		  ELSE
		  BEGIN
			 SELECT  [dbo].[Pattern].PatternID,
				    [dbo].[Pattern].[CreativeID] ,
					[dbo].[Pattern].[CreativeSignature],
					@BasePath + [dbo].[CreativeDetailCIN].[CreativeRepository] + [dbo].[CreativeDetailCIN].[CreativeAssetName] AS LocalCreativeFilePath,
					@RemoteBasePath + [dbo].[CreativeDetailCIN].[CreativeRepository] + [dbo].[CreativeDetailCIN].[CreativeAssetName] AS RemoteCreativeFilePath
			 FROM  [dbo].[Pattern]
			 INNER JOIN [dbo].[CreativeDetailCIN] ON 
			 [dbo].[CreativeDetailCIN].[CreativeMasterID]=[dbo].[Pattern].[CreativeID]
			 WHERE [dbo].[Pattern].[CreativeSignature]=@CreativeSignature
		  END
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT [Creative].PK_Id,
				    CreativeDetailCIN.[CreativeDetailCINID] As CreativeDetailId,
				    [Creative].PrimaryIndicator,
				  @BasePath + CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName AS LocalCreativeFilePath,
				  @RemoteBasePath + CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName AS RemoteCreativeFilePath,
				  cast(CreativeDetailCIN.[CreativeDetailCINID] as varchar)+'-'+CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName as DetailIDwithFilepath
			 FROM [Creative] 
			 inner join CreativeDetailCIN on [Creative].PK_Id=CreativeDetailCIN.[CreativeMasterID] and [Creative].[AdId]=@Adid
			 and [Creative].PrimaryIndicator=1
	   END
	   
END