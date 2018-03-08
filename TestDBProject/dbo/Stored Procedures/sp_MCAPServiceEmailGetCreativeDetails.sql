CREATE PROCEDURE [dbo].[sp_MCAPServiceEmailGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeID as Integer,
@OccurrenceID AS BIGINT,
@AdId AS BIGINT,
@PromotionID  AS INT = 0
)
AS
BEGIN
		DECLARE @BasePath AS VARCHAR(MAX)
		DECLARE @RemoteBasePath AS VARCHAR(MAX)

		select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

		IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='EML',@Mediatype='EM',@Ext=0
		ELSE IF @LocationId = 4126
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='EML',@Mediatype='EM',@Ext=0
		ELSE	
			SET @BasePath = @RemoteBasePath
		
		IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 
			  
	   IF @CreativeID > 0
	   BEGIN
		  if exists( Select top 1 adid from CreativeDetailEM inner join creative on creative.PK_Id = CreativeDetailEM.CreativeMasterID
				    where CreativeMasterID = @CreativeID   and adid is not null)
		  begin
				SELECT [CreativeDetailsEMID] AS CreativeDetailID, 
					   creativemasterid as creativeid, 
					   CASE WHEN creativeassetname IS NULL THEN LegacyAssetName + '.' + creativefiletype  ELSE creativeassetname END as creativename, 
					   creativefiletype, 
					   deleted AS isDeleted, 
					   pagenumber, 
					   creativedetailem.pagetypeid, 
					   dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
					   dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
					   size.[SizeID], 
					   creativedetailem.formname, 
					   [PageStartDT], 
					   [PageEndDT], 
					   pagename, 
					   emailpagenumber                        AS PubPageNumber, 
					   pagetype.descrip,
					   CASE WHEN CreativeDetailEM.CreativeAssetName IS NULL 
						  THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype 
							 ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
					   CASE WHEN CreativeDetailEM.CreativeAssetName IS NULL 
						  THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
							 ELSE  @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
					   
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
					   CASE WHEN AssetThmbnlName IS NULL 
						    THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype 
							    ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath
				FROM   creativedetailem 
					   INNER JOIN Creative ON Creative.PK_Id = creativedetailem.CreativeMasterID
					  LEFT JOIN pagetype 
							ON creativedetailem.pagetypeid = 
							   pagetype.[PageTypeID] 
					  LEFT JOIN size 
							ON size.[SizeID] = creativedetailem.[SizeID] 
				WHERE  creativemasterid = @CreativeID 
					  AND (Deleted=0 or Deleted is null) 
				ORDER  BY pagenumber 

		  END 
		  ELSE
		  BEGIN 

		  --Edited By Mark Marshall
				
			 SELECT [CreativeDetailStagingEM].CreativeDetailStagingEMID AS CreativeDetailID, 
				[CreativeDetailStagingEM].[CreativeStagingID], 
				CASE WHEN CreativeAssetName IS NULL 
					THEN LegacyAssetName + '.' + creativefiletype  
						ELSE CreativeAssetName END AS creativeassetname, 
				creativerepository + CASE WHEN CreativeAssetName IS NULL 
					THEN LegacyAssetName + '.' + creativefiletype  
						ELSE CreativeAssetName END AS CreativeRepository, 
				creativefiletype, 
				0 AS isDeleted, 
				1 AS PageNumber, 
				'' AS PageTypeId, 
				'' AS PixelHeight, 
				'' AS PixelWidth, 
				0 AS FK_SizeID, 
				'' AS FormName, 
				Getdate() AS PageStartDt, 
				Getdate() AS PageEndDt, 
				'' AS PageName, 
				1 AS PubPageNumber, 
				'' AS Descrip,
				CASE WHEN CreativeAssetName IS NULL 
					THEN @BasePath + creativerepository + LegacyAssetName + '.' + creativefiletype  
						ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
				CASE WHEN CreativeAssetName IS NULL 
					THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
						ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				@BasePath + ThmbnlRep + AssetThmbnlName as [LocalThumbnailPath],
				@RemoteBasePath + ThmbnlRep + AssetThmbnlName as [RemoteThumbnailPath]
			 FROM   [dbo].[PatternStaging] 
				INNER JOIN [dbo].[CreativeDetailStagingEM] ON 
					   [dbo].[CreativeDetailStagingEM].[CreativeStagingID] = [dbo].[PatternStaging].[CreativeStgID] 
				INNER JOIN [dbo].[CreativeStaging] ON [CreativeStaging].CreativeStagingID = [CreativeDetailStagingEM].[CreativeStagingID] 
			 WHERE  [dbo].[CreativeDetailStagingEM].[CreativeStagingID] =  @CreativeID 
				AND ([CreativeDetailStagingEM].Deleted=0 or [CreativeDetailStagingEM].Deleted is null)
			 ORDER  BY pagenumber 
		  END
	   END
	   ELSE IF @OccurrenceID > 0 
	   BEGIN 
			 IF EXISTS(SELECT TOP 1 * FROM CreativeStaging WHERE OccurrenceID = @OccurrenceID)
			 BEGIN
				    SELECT [CreativeStaging].CreativeStagingID,
					[CreativeDetailStagingEM].CreativeDetailStagingEMID AS CreativeDetailID, -- MI-1194  L.E. 10.11.17
					 [PatternStaging].[PatternStagingID],
						 creativefiletype,'' as descrip,
						 CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + [CreativeDetailStagingEM].CreativeRepository + CreativeAssetName END  AS LocalCreativeFilePath,
						 CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @RemoteBasePath + [CreativeDetailStagingEM].CreativeRepository +CreativeAssetName END AS RemoteCreativeFilePath,
						  @BasePath + ThmbnlRep + AssetThmbnlName as [LocalThumbnailPath],
						  @RemoteBasePath + ThmbnlRep + AssetThmbnlName as [RemoteThumbnailPath],
						 [CreativeDetailStagingEM].CreativeFileType as [Format],
						 [CreativeDetailStagingEM].CreativeFileSize AS CreativeFileSize, 
						 pagenumber
				    FROM [PatternStaging] 
				    INNER JOIN [CreativeStaging] on [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
				    inner join [CreativeDetailStagingEM] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingEM].CreativeStagingID
				    inner Join [OccurrenceDetailEM] on [OccurrenceDetailEM].OccurrenceDetailEMID = [CreativeStaging].OccurrenceID  
				    where OccurrenceDetailEMID =@OccurrenceID AND ([CreativeDetailStagingEM].Deleted=0 or [CreativeDetailStagingEM].Deleted is null)
					order by pagenumber
			 END
			 ELSE
			 BEGIN
				    SELECT  PrimaryCreativeIndicator,AdId,
						  PK_OccurrenceID AS OccurrenceID,
						  CreativeMasterID AS CreativeID,
						  CreativeDetailID,
						  PageNumber,
						  isDeleted, 
						  creativefiletype,
						  '' as descrip,
						  CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
						  CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @RemoteBasePath + CreativeRepository +  CreativeAssetName END AS RemoteCreativeFilePath,
						  CreativeAssetThumbnailName As [ThumbnailSource],
						  
				    CASE WHEN CreativeAssetThumbnailName IS NULL 
						THEN @BasePath + CreativeThumbnailRepository + LegacyCreativeThumbnailAssetName + '.' + CreativeThumbnailFileType 
							ELSE @BasePath + CreativeThumbnailRepository +CreativeAssetThumbnailName END AS LocalThumbnailPath,
						  CASE WHEN CreativeAssetThumbnailName IS NULL 
						    THEN CreativeThumbnailRepository + LegacyCreativeThumbnailAssetName + '.' + CreativeThumbnailFileType 
							    ELSE @RemoteBasePath + CreativeThumbnailRepository +CreativeAssetThumbnailName END AS RemoteThumbnailPath
				    FROM  [vw_EmailCreatives] 
				    WHERE PK_OccurrenceID=@OccurrenceID AND (isDeleted=0 or isDeleted is null) and PrimaryCreativeIndicator=1
				    ORDER BY  Pagenumber
			 END
		  END
		  ELSE IF @AdId > 0 
		  BEGIN
				Declare @PrimaryOccurrenceID as BIGINT	
				SET @PrimaryOccurrenceID=(SELECT [PrimaryOccurrenceID] FROM  AD WHERE AD.[AdID]=@AdID)


				IF EXISTS(SELECT 1 FROM  [dbo].[CreativeDetailEM] 
						INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
						WHERE [Creative].[AdID]=@AdID AND (CreativeDetailEM.Deleted=0 or CreativeDetailEM.Deleted is null) AND [Creative].PrimaryIndicator=1  AND [CreativeDetailEM].Pagenumber is null )
				BEGIN 
					DECLARE @IncrementValue int
					SET @IncrementValue = 0 
					Update [CreativeDetailEM] set [CreativeDetailEM].pagenumber=  @IncrementValue,@IncrementValue=@IncrementValue+1
					FROM  [dbo].[CreativeDetailEM] 
					INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
					where [Creative].[AdID]=@AdID AND (CreativeDetailEM.Deleted=0 or CreativeDetailEM.Deleted is null)
					and [Creative].PrimaryIndicator=1 AND Pagenumber is null
				END 


				SELECT  AD.[AdID],
					   [dbo].[Pattern].PatternId,
					   [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID] AS OccurrenceID,
					   [Creative].PK_Id AS CreativeID,
					   CreativeDetailEM.[CreativeDetailsEMID] AS CreativeDetailID,
					   CreativeDetailEM.PageNumber,
					   creativefiletype, 
					   CreativeDetailEM.Deleted as IsDeleted,
					   isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,
					   isnull(ContentDetailID,0) ContentDetailID,
					   isnull(CreativeForCropStagingID,0) CreativeForCropStagingID,					
					   CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + CreativeDetailEM.CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
					   CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @RemoteBasePath + CreativeDetailEM.CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,

					   CASE WHEN AssetThmbnlName IS NULL 
					   THEN 
							CASE WHEN (@BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType)  is null 
							THEN 
								CASE WHEN CreativeAssetName IS NULL 
								THEN @BasePath + REPLACE(CreativeRepository,'Original','Thumb') + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + REPLACE(CreativeDetailEM.CreativeRepository,'Original','Thumb') + CreativeAssetName 
								END
							ELSE @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							END
						ELSE 
							CASE WHEN (@BasePath + ThmbnlRep +CreativeAssetName )  is null  THEN 
							@BasePath + ThmbnlRep +AssetThmbnlName  
							ELSE
							@BasePath + ThmbnlRep +CreativeAssetName   END
						END  AS LocalThumbnailPath,

					   CASE WHEN AssetThmbnlName IS NULL 
					   THEN 
							CASE WHEN ( ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype ) is null 
							THEN 
								CASE WHEN CreativeAssetName IS NULL 
								THEN REPLACE(CreativeRepository,'Original','Thumb') + LegacyAssetName + '.' + creativefiletype 	
								ELSE @RemoteBasePath + REPLACE(CreativeDetailEM.CreativeRepository,'Original','Thumb') + CreativeAssetName 
								END
							ELSE ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype 
							END 
						ELSE
							CASE WHEN (@RemoteBasePath + ThmbnlRep +CreativeAssetName )  is null  THEN 
							@RemoteBasePath + ThmbnlRep +AssetThmbnlName  
							ELSE
							@RemoteBasePath + ThmbnlRep +CreativeAssetName   END
						END AS RemoteThumbnailPath , 

						Case when CreativeAssetName IS NULL THEN 
							CASE WHEN (LegacyThmbnlAssetName=LegacyAssetName) then 1 else 0 end
						ELSE  
							CASE WHEN (AssetThmbnlName=CreativeAssetName) then 1 else 0 end 
						END AS PrimaryIndicator
						
				FROM  [dbo].[CreativeDetailEM] 
				INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
				INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailEM].CreativeMasterID=[dbo].[Pattern].[CreativeID]
				INNER join [dbo].[OccurrenceDetailEM] on dbo.[OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID]
				INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]=[dbo].[AD].[PrimaryOccurrenceID]
				left join CreativeForCropStaging on [Creative].PK_Id = CreativeForCropStaging.CreativeMasterStagingID
				left join CreativeContentDetailStaging on [CreativeDetailEM].CreativeDetailsEMID = CreativeContentDetailStaging.CreativeDetailID

				where AD.[AdID]=@AdID AND (CreativeDetailEM.Deleted=0 or CreativeDetailEM.Deleted is null)
				and [Creative].PrimaryIndicator=1 AND AD.[PrimaryOccurrenceID]=@PrimaryOccurrenceID
				ORDER BY Pagenumber ASC, CreativeDetailEM.[CreativeDetailsEMID]
		  END
		  ELSE IF @PromotionID > 0 
		  BEGIN
			 SELECT CDR.creativemasterid AS CreativeID, 
				   CASE WHEN CreativeAssetName IS NULL 
					   THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype  
						  ELSE @BasePath + CDR.CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
				    CASE WHEN CreativeAssetName IS NULL 
					   THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
						  ELSE @RemoteBasePath + CDR.CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				    CASE WHEN AssetThmbnlName IS NULL 
						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
				    CASE WHEN AssetThmbnlName IS NULL 
					   THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype 
						  ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailem] CDR 
                               ON CDR.[CreativeDetailsEMID] = CCD.[CreativeDetailID] 
				    INNER JOIN [dbo].[Creative]
						  ON CDR.CreativeMasterID =[dbo].[Creative].PK_Id
                WHERE  PM.[PromotionID] = @PromotionID 
		  END
END