
CREATE PROCEDURE [dbo].[sp_MCAPServicePrintGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeId AS INT,
@OccurrenceID AS INT,
@AdId AS INT,
@PublicationIssueId AS INT,
@PromotionID  AS INT  
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100) 
	   DECLARE @PatternId AS INTEGER

	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIR',@Mediatype='CIR',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIR',@Mediatype='CIR',@Ext=0
	   ELSE	
			SET @BasePath = @RemoteBasePath
		
	   IF @BasePath IS NULL OR @BasePath = ''
		  SET @BasePath = 'C:\MCAPCreatives\' 
	   

	   IF @CreativeId > 0 
	   BEGIN
		  SELECT creativedetailid, 
                    creativeid, 
                    creativeassetname AS creativename, 
                    creativefiletype, 
                    deleted AS isDeleted, 
                    pagenumber, 
                    [vw_CreativeDetailPrint].[PageTypeID], 
                    dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
                    dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
                    size.[SizeID], 
                    formname, 
                    [PageStartDT], 
                    [PageEndDT], 
                    pagename, 
                    pubpagenumber, 
                    pagetype.descrip,
				@BasePath + [vw_CreativeDetailPrint].CreativeRepository +[vw_CreativeDetailPrint].CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + [vw_CreativeDetailPrint].CreativeRepository +[vw_CreativeDetailPrint].CreativeAssetName AS RemoteCreativeFilePath
                FROM   [vw_CreativeDetailPrint] 
                       LEFT JOIN pagetype 
                               ON [vw_CreativeDetailPrint].[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       LEFT JOIN size 
                               ON size.[SizeID] = [vw_CreativeDetailPrint].[SizeID] 
                WHERE  creativeid = @CreativeID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
	   END
	   ELSE IF @OccurrenceID > 0
	   BEGIN
			 SELECT  AdId,
				    [OccurrenceDetailID] AS OccurrenceID,
				    CreativeID,
				    CreativeDetailID,
				    PageNumber,
				    isDeleted,
				    @BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				    CreativeAssetThumbnailName As [ThumbnailSource],
				    [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
				[PageEndDT],PageName,PubPageNumber
			 FROM  vw_PrintCreatives 
			 WHERE [OccurrenceDetailID]=@OccurrenceID  AND isDeleted=0  
			 ORDER BY  Pagenumber
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
		  SELECT	vw_PrintCreatives.AdId,
				[OccurrenceDetailID] AS OccurrenceID,
				CreativeID,
				vw_PrintCreatives.CreativeDetailID,
				PageNumber,
				isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,
				isnull(ContentDetailID,0) ContentDetailID,
				isnull(CreativeForCropStagingID,0) CreativeForCropStagingID,
				@BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				CreativeAssetThumbnailName As [ThumbnailSource], 
				isDeleted,
				[PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
				[PageEndDT],PageName,PubPageNumber
		  FROM  vw_PrintCreatives 
			 left join CreativeForCropStaging on vw_PrintCreatives.CreativeID = CreativeForCropStaging.CreativeMasterStagingID
			 left join CreativeContentDetailStaging on vw_PrintCreatives.CreativeDetailID = CreativeContentDetailStaging.CreativeDetailID
		  WHERE sourceoccurrenceid = (select [PrimaryOccurrenceID] from ad where [AdID]=@AdID AND isDeleted=0)  
		  and PrimaryCreativeIndicator=1
		  ORDER BY Pagenumber ASC, vw_PrintCreatives.CreativeDetailID
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
                    INNER JOIN vw_creativedetailPrint CDR 
                            ON CDR.[CreativeDetailID] = CCD.[CreativeDetailID] 
            WHERE  PM.[PromotionID] = @PromotionID 
	   END

END