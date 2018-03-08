CREATE PROCEDURE [dbo].[sp_MCAPServiceMobileGetCreativeDetails] 
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
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='MOB',@Mediatype='MOB',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='MOB',@Mediatype='MOB',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT SignatureDefault FROM [CreativeDetailStagingMOB] WHERE SignatureDefault = @CreativeSignature ) 
		  BEGIN
			 SELECT  Top 1  [CreativeDetailStagingID],
					   [CreativeStagingID] as [CreativeStagingId],
					   SignatureDefault as CreativeSignature,
					   @BasePath + [dbo].[CreativeDetailStagingMOB].[CreativeRepository]+
					   [dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+CreativeFileType AS LocalCreativeFilePath,
					   @RemoteBasePath + [dbo].[CreativeDetailStagingMOB].[CreativeRepository]+
					   [dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+CreativeFileType AS RemoteCreativeFilePath,
					   [dbo].[CreativeDetailStagingMOB].[FileSize] AS CreativeFileSize,
					   [dbo].[CreativeDetailStagingMOB].[CreativeFileType] as [Format]
			 FROM  [dbo].[CreativeDetailStagingMOB]  
			 WHERE SignatureDefault=@CreativeSignature
			 and CreativeDownloaded=1 and FileSize>0 
			 ORDER BY [CreativeDetailStagingID]
		  END
		  ELSE
		  BEGIN
			 SELECT  Top 1 PatternID,
					   [CreativeID],
					   CreativeSignature,
					   @BasePath + [dbo].[CreativeDetailMOB].[CreativeRepository]+
					   [dbo].[CreativeDetailMOB].CreativeAssetName AS LocalCreativeFilePath,
					   @RemoteBasePath + [dbo].[CreativeDetailMOB].[CreativeRepository]+
					   [dbo].[CreativeDetailMOB].CreativeAssetName AS RemoteCreativeFilePath,
					   [dbo].[CreativeDetailMOB].[CreativeFileSize] AS CreativeFileSize,
					   [dbo].[CreativeDetailMOB].[CreativeFileType] as [Format]
			 FROM  [dbo].[CreativeDetailMOB]  
				INNER JOIN Pattern ON Pattern.CreativeID = [CreativeDetailMOB].CreativeMasterID
			 WHERE CreativeSignature=@CreativeSignature
		  END
			 
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT Top 1 [Creative].PK_Id AS Creativeid,
				CreativeDetailmob.[CreativeDetailMOBID] As CreativeDetailId,
				[Creative].PrimaryIndicator,
				@BasePath + CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName AS RemoteCreativeFilePath,
				cast(CreativeDetailmob.[CreativeDetailMOBID] as varchar)+'-'+CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName as DetailIDwithFilepath,
				CreativeDetailmob.CreativeFileType
			 FROM [Creative] 
			 inner join CreativeDetailmob on [Creative].PK_Id=CreativeDetailmob.[CreativeMasterID] and [Creative].[AdId]=@Adid
			 and [Creative].PrimaryIndicator=1
	   END
	   
END