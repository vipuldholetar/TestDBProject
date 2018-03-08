CREATE PROCEDURE [dbo].[sp_MCAPServiceTVGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS VARCHAR(100),
@PatternId INT,
@AdId AS INT 
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100)
	   
	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='TV',@Mediatype='TV',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='TV',@Mediatype='TV',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT  [dbo].[PatternStaging].[CreativeStgID],
					[dbo].[PatternStaging].[CreativeSignature],
					@BasePath + [dbo].[CreativeDetailStagingTV].[MediaFilePath]+
					[dbo].[CreativeDetailStagingTV].[MediaFileName] AS LocalCreativeFilePath,
					@RemoteBasePath + [dbo].[CreativeDetailStagingTV].[MediaFilePath]+
					[dbo].[CreativeDetailStagingTV].[MediaFileName] AS RemoteCreativeFilePath,
					[dbo].[CreativeDetailStagingTV].[FileSize],
					[dbo].[CreativeDetailStagingTV].[MediaFormat]
			 FROM  [dbo].[PatternStaging]
			    INNER JOIN [dbo].[CreativeDetailStagingTV] ON 
			    [dbo].[CreativeDetailStagingTV].[CreativeStgMasterID]=[dbo].[PatternStaging].[CreativeStgID]
			WHERE [dbo].[PatternStaging].[CreativeSignature]= @CreativeSignature 
			 AND [dbo].[CreativeDetailStagingTV].[MediaFormat]='mpg'
		  END
		  ELSE
		  BEGIN
			 SELECT  Pattern.PatternID,
				    [dbo].[Pattern].[CreativeID],
				    [dbo].[Pattern].[CreativeSignature],
				    CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS LocalCreativeFilePath,
				    CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS RemoteCreativeFilePath
			 FROM  [dbo].[Pattern]
			    INNER JOIN [dbo].[CreativeDetailTV] ON 
			    [dbo].[CreativeDetailTV].[CreativeMasterID]=[dbo].[Pattern].CreativeID
			WHERE [dbo].[Pattern].[CreativeSignature]= @CreativeSignature
		  END
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
		  SELECT [Creative].PK_Id AS Creativeid,
				CreativeDetailTV.[CreativeDetailTVID] As CreativeDetailId,
				CAST([Creative].PrimaryIndicator AS INT) AS PrimaryIndicator,
				@BasePath + CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS RemoteCreativeFilePath,
				cast(CreativeDetailTV.[CreativeDetailTVID] as varchar)+'-'+CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName as DetailIDwithFilepath
		  FROM [Creative] inner join CreativeDetailTV on [Creative].PK_Id=CreativeDetailTV.creativemasterid 
		  WHERE [Creative].[AdId]=@Adid and [Creative].PrimaryIndicator=1
	   END
	   ELSE IF @PatternId > 0 
	   BEGIN
			 SELECT @BasePath + CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS RemoteCreativeFilePath
			 FROM            [Pattern] 
			 INNER JOIN   CreativeDetailTV 
				ON [Pattern].[CreativeID] = CreativeDetailTV.CreativeMasterID
			 Where [Pattern].[PatternID]=@PatternId
	   END
END