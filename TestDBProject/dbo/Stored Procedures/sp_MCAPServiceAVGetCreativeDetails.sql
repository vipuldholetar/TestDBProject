CREATE PROCEDURE [dbo].[sp_MCAPServiceAVGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS VARCHAR(100),
@PatternId INT,
@AdId AS INT,
@PromotionID  AS INT
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100)
	   
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='TV',@Mediatype='TV',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='TV',@Mediatype='TV',@Ext=0
	   ELSE	
			SET @BasePath = @RemoteBasePath
		
		IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 
			  
	   IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT CreativeSignature FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature ) 
		  BEGIN
			 SELECT  PatternStaging.PatternId,
				    PatternStaging.[CreativeStgID],
				    PatternStaging.[CreativeSignature],
				    @BasePath + [dbo].vw_CreativeDetailStagingAV.CreativeRepository+
				    [dbo].vw_CreativeDetailStagingAV.CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + [dbo].vw_CreativeDetailStagingAV.CreativeRepository+
				    [dbo].vw_CreativeDetailStagingAV.CreativeAssetName AS RemoteCreativeFilePath,
				    [dbo].vw_CreativeDetailStagingAV.[FileSize],
				    [dbo].vw_CreativeDetailStagingAV.CreativeFileType
			 FROM  
			 (
				SELECT PatternStagingID as PatternStagingID, 0 as PatternID, CreativeStgID, 
				    0 as Priority, 144 as MediaStream,  CreativeSignature 
				FROM [dbo].[PatternStaging]
				UNION
				SELECT PatternStagingID, PatternID, CreativeStgID as CreativeStagingID, 
				    Priority, MediaStream,  CreativeSignature 
				FROM PatternStaging
			 ) PatternStaging
			 INNER JOIN [dbo].vw_CreativeDetailStagingAV ON 
			    [dbo].vw_CreativeDetailStagingAV.[CreativeStagingID]=PatternStaging.[CreativeStgID]
			WHERE PatternStaging.[CreativeSignature]= @CreativeSignature 
			 --AND [dbo].vw_CreativeDetailStagingAV.[MediaFormat]='mpg'
		  END
		  ELSE
		  BEGIN
			 SELECT  Pattern.PatternID,
				    [dbo].[Pattern].[CreativeID],
				    [dbo].[Pattern].[CreativeSignature],
				    vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS LocalCreativeFilePath,
				    vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS RemoteCreativeFilePath
			 FROM  [dbo].[Pattern]
			    INNER JOIN [dbo].[vw_CreativeDetailAV] ON 
			    [dbo].[vw_CreativeDetailAV].[CreativeID]=[dbo].[Pattern].CreativeID
			WHERE [dbo].[Pattern].[CreativeSignature]= @CreativeSignature
		  END
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
		  SELECT [Creative].PK_Id AS Creativeid,
				vw_CreativeDetailAV.[CreativeDetailID] As CreativeDetailId,
				CAST([Creative].PrimaryIndicator AS INT) AS PrimaryIndicator,
				@BasePath + vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS RemoteCreativeFilePath,
				cast(vw_CreativeDetailAV.[CreativeDetailID] as varchar)+'-'+vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName as DetailIDwithFilepath
		  FROM [Creative] inner join vw_CreativeDetailAV on [Creative].PK_Id=vw_CreativeDetailAV.creativeid 
		  WHERE [Creative].[AdId]=@Adid and [Creative].PrimaryIndicator=1
	   END
	   ELSE IF @PatternId > 0 
	   BEGIN
			 SELECT @BasePath + vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + vw_CreativeDetailAV.CreativeRepository+vw_CreativeDetailAV.CreativeAssetName AS RemoteCreativeFilePath
			 FROM            [Pattern] 
			 INNER JOIN   vw_CreativeDetailAV
				ON [Pattern].[CreativeID] = vw_CreativeDetailAV.CreativeID
			 Where [Pattern].[PatternID]=@PatternId
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
                    INNER JOIN vw_creativedetailAV CDR 
                            ON CDR.[CreativeDetailID] = CCD.[CreativeDetailID] 
            WHERE  PM.[PromotionID] = @PromotionID 
	   END
END