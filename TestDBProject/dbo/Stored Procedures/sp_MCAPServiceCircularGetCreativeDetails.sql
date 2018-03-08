CREATE PROCEDURE [dbo].[sp_MCAPServiceCircularGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeId AS INT,
@OccurrenceID AS INT,
@AdId AS INT 
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100) 
	   DECLARE @PatternId AS INTEGER

	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIR',@Mediatype='CIR',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='CIR',@Mediatype='CIR',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeId > 0 
	   BEGIN
		  SELECT creativedetailid, 
                    creativemasterid, 
                    creativeassetname AS creativename, 
                    creativefiletype, 
                    deleted AS isDeleted, 
                    pagenumber, 
                    creativedetailcir.[PageTypeID], 
                    dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
                    dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
                    size.[SizeID], 
                    formname, 
                    [PageStartDT], 
                    [PageEndDT], 
                    pagename, 
                    pubpagenumber, 
                    pagetype.descrip,
				@BasePath + creativedetailcir.CreativeRepository +creativedetailcir.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + creativedetailcir.CreativeRepository +creativedetailcir.CreativeAssetName AS RemoteCreativeFilePath
                FROM   creativedetailcir 
                       LEFT JOIN pagetype 
                               ON creativedetailcir.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       LEFT JOIN size 
                               ON size.[SizeID] = creativedetailcir.[SizeID] 
                WHERE  creativemasterid = @CreativeID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
	   END
	   ELSE IF @OccurrenceID > 0
	   BEGIN
			 SELECT  AdId,
				    [OccurrenceDetailCIRID] AS OccurrenceID,
				    CreativeMasterID as CreativeID,
				    CreativeDetailID,
				    PageNumber,
				    isDeleted,
				    @BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				    CreativeAssetThumbnailName As [ThumbnailSource],
				    [PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
				[PageEndDT],PageName,PubPageNumber
			 FROM  vw_CircularCreatives 
			 WHERE [OccurrenceDetailCIRID]=@OccurrenceID  AND isDeleted=0  
			 ORDER BY  Pagenumber
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
		  SELECT	AdId,
				[OccurrenceDetailCIRID] AS OccurrenceID,
				CreativeMasterID as CreativeID,
				CreativeDetailID,
				PageNumber,
				@BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				CreativeAssetThumbnailName As [ThumbnailSource], 
				isDeleted,
				[PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],
				[PageEndDT],PageName,PubPageNumber
		  FROM  vw_CircularCreatives 
		  WHERE sourceoccurrenceid = (select [PrimaryOccurrenceID] from ad where [AdID]=@AdID AND isDeleted=0)  
		  and PrimaryCreativeIndicator=1
		  ORDER BY Pagenumber ASC,CreativeDetailID
	   END

END