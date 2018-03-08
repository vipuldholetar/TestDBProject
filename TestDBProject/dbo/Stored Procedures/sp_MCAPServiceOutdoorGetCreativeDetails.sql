CREATE PROCEDURE [dbo].[sp_MCAPServiceOutdoorGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeId AS INT,
@CreativeSignature AS varchar(MAX),
@PatternId AS INT,
@AdId AS INT,
@PromotionID  AS INT = 0
)
AS
BEGIN
		DECLARE @BasePath AS VARCHAR(MAX)
		DECLARE @RemoteBasePath AS VARCHAR(MAX) 
	   
		select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

		IF @LocationId = 58
			exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OD',@Mediatype='OD',@Ext=0
		ELSE IF @LocationId = 4126
		exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='OD',@Mediatype='OD',@Ext=0
		ELSE	
			SET @BasePath = @RemoteBasePath
		
		IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 
			  
	   IF @CreativeId > 0 
	   BEGIN
		IF EXISTS(SELECT TOP 1 * FROM [CreativeStaging] WHERE CreativeStagingID = @CreativeId)
		 BEGIN
		 
			SELECT [CreativeDetailStagingODR].[CreativeDetailStagingODRID] AS CreativeDetailID, 
			[CreativeDetailStagingODR].CreativeStagingID AS CreativeId, 
			CreativeAssetName As creativename,
			@BasePath + CreativeRepository + CreativeAssetName AS LocalCreativeFilePath,
			@RemoteBasePath + CreativeRepository + CreativeAssetName AS RemoteCreativeFilePath,
			@BasePath + ThmbnlRep +AssetThmbnlName AS LocalThumbnailPath,
			@RemoteBasePath + ThmbnlRep + AssetThmbnlName AS RemoteThumbnailPath,
			creativerepository + creativeassetname AS CreativeRepository, 
			creativefiletype, 
			0                                      AS Deleted, 
			1                                      AS PageNumber, 
			''                                     AS PageTypeId, 
			''                                     AS PixelHeight, 
			''                                     AS PixelWidth, 
			0                                      AS FK_SizeID, 
			''                                     AS FormName, 
			Getdate()                              AS PageStartDt, 
			Getdate()                              AS PageEndDt, 
			''                                     AS PageName, 
			1                                      AS PubPageNumber, 
			''                                     AS Descrip 
			FROM   [CreativeStaging] 
			INNER JOIN [CreativeDetailStagingODR] 
			ON [CreativeStaging].CreativeStagingID = [CreativeDetailStagingODR].CreativeStagingID                                 
			AND [CreativeStaging].CreativeStagingID = @CreativeID 

		 END
		 ELSE
		 BEGIN

		  SELECT creativedetailodr.[CreativeDetailODRID] AS CreativeDetailID, 
                    creativedetailodr.creativemasterid AS CreativeId, 
				CASE WHEN CreativeAssetName IS NULL 
					   THEN LegacyCreativeAssetName + '.' + creativefiletype  
						  ELSE creativeassetname END as creativename,
				CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
								ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
				CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
								ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
				CASE WHEN AssetThmbnlName IS NULL 
						THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath,
                    creativerepository + creativeassetname AS CreativeRepository, 
                    creativefiletype, 
                    0                                      AS Deleted, 
                    1                                      AS PageNumber, 
                    ''                                     AS PageTypeId, 
                    ''                                     AS PixelHeight, 
                    ''                                     AS PixelWidth, 
                    0                                      AS FK_SizeID, 
                    ''                                     AS FormName, 
                    Getdate()                              AS PageStartDt, 
                    Getdate()                              AS PageEndDt, 
                    ''                                     AS PageName, 
                    1                                      AS PubPageNumber, 
                    ''                                     AS Descrip 
                FROM   [Creative] 
                       INNER JOIN creativedetailodr 
                               ON [Creative].pk_id = 
                                  creativedetailodr.creativemasterid 
                                  AND [Creative].pk_id = @CreativeID 
                                  --AND [Creative].primaryindicator = 1 
		 END

	   END
	   ELSE IF @CreativeSignature <> '' AND @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT TOP 1 * FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature)
		  BEGIN
				SELECT  [dbo].[PatternStaging].[CreativeStgID],
					   [dbo].[PatternStaging].[CreativeSignature],
					   creativefiletype,
					   @BasePath + CreativeRepository + CreativeAssetName AS LocalCreativeFilePath,
					   @RemoteBasePath + CreativeRepository + CreativeAssetName AS RemoteCreativeFilePath,
					   @BasePath + ThmbnlRep +AssetThmbnlName AS LocalThumbnailPath,
					   @RemoteBasePath + ThmbnlRep + AssetThmbnlName AS RemoteThumbnailPath,
					   [dbo].[CreativeDetailStagingODR].[CreativeFileSize],
					   [dbo].[CreativeDetailStagingODR].[CreativeFileType] as [Format]
				FROM  [dbo].[PatternStaging]
				INNER JOIN [dbo].[CreativeDetailStagingODR] ON 
				    [dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
				INNER JOIN [CreativeStaging] ON [CreativeStaging].CreativeStagingID=[CreativeDetailStagingODR].CreativeStagingID
				WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature
		  END
		  ELSE
		  BEGIN
				SELECT  [dbo].[Pattern].PatternId,
					   [dbo].[Pattern].[CreativeID],
					   [dbo].[Pattern].[CreativeSignature],
					   creativefiletype,
					   CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
								ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
						CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
								ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				    
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath,
					    [dbo].[CreativeDetailODR].[CreativeFileType] as [Format]
					  FROM  [dbo].[Pattern]
			    INNER JOIN [dbo].[CreativeDetailODR] ON 
				[dbo].[CreativeDetailODR].[CreativeMasterID]=[dbo].[Pattern].[CreativeID]
				INNER JOIN [Creative] ON [Creative].PK_Id=CreativeDetailODR.creativemasterid
			    WHERE [dbo].[Pattern].[CreativeSignature]=@CreativeSignature
		  END
	   END	
	   ELSE IF @PatternId > 0
	   BEGIN
			 SELECT CASE WHEN CreativeAssetName IS NULL 
						THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
							ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
					CASE WHEN CreativeAssetName IS NULL 
						THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
							ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				    CreativeDetailODR.CreativeMasterID,
					creativefiletype,
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath
			 FROM    [Pattern] 
				INNER JOIN   CreativeDetailODR 
				ON [Pattern].[CreativeID] = CreativeDetailODR.CreativeMasterID
				INNER JOIN [Creative] ON [Creative].PK_Id=CreativeDetailODR.creativemasterid
			 Where [Pattern].[PatternID]=@PatternId

        END  
	   ELSE IF @AdId > 0
	   BEGIN
			 SELECT [Creative].PK_Id AS [CreativeID],
					CreativeDetailODR.[CreativeDetailODRID] AS CreativeDetailId,
					[Creative].PrimaryIndicator,
					creativefiletype,
				    isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,
				    isnull(ContentDetailID,0) ContentDetailID,
				    isnull(CreativeForCropStagingID,0) CreativeForCropStagingID,
					CASE WHEN CreativeAssetName IS NULL 
						THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
							ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
					CASE WHEN CreativeAssetName IS NULL 
						THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
							ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,

				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
					
					CASE WHEN AssetThmbnlName IS NULL 
						THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath
			 FROM [Creative] 
			 INNER JOIN CreativeDetailODR ON [Creative].PK_Id=CreativeDetailODR.creativemasterid
			 left join CreativeForCropStaging on [Creative].PK_Id = CreativeForCropStaging.CreativeMasterStagingID
			 left join CreativeContentDetailStaging on CreativeDetailODR.CreativeDetailODRID = CreativeContentDetailStaging.CreativeDetailID
			 where [Creative].[AdId]=@Adid
			 AND [Creative].PrimaryIndicator=1
	   END
	   ELSE IF @PromotionID > 0
	   BEGIN
		  SELECT CDR.creativemasterid    [CreativeID], 
				CASE WHEN CreativeAssetName IS NULL 
				    THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
					   ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
				CASE WHEN CreativeAssetName IS NULL 
				    THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
					   ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				CASE WHEN AssetThmbnlName IS NULL 
				    THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
					   ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
					
				CASE WHEN AssetThmbnlName IS NULL 
				    THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
					   ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailodr] CDR 
                               ON CDR.[CreativeDetailODRID] = CCD.[CreativeDetailID] 
				    INNER JOIN [dbo].[Creative]
						  ON CDR.CreativeMasterID =[dbo].[Creative].PK_Id
                WHERE  PM.[PromotionID] = @PromotionID 
	   END
END