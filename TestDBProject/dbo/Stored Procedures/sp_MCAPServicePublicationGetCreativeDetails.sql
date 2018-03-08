CREATE PROCEDURE [dbo].[sp_MCAPServicePublicationGetCreativeDetails] 
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
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='PUB',@Mediatype='PUB',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='PUB',@Mediatype='PUB',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @CreativeId > 0
	   BEGIN
		  SELECT creativedetailid, 
                    creativemasterid AS creativid, 
                    creativeassetname AS creativename, 
				@BasePath + creativedetailpub.CreativeRepository +creativedetailpub.CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + creativedetailpub.CreativeRepository +creativedetailpub.CreativeAssetName AS RemoteCreativeFilePath,
                    creativefiletype, 
                    deleted, 
                    pagenumber, 
                    creativedetailpub.[PageTypeID], 
                    dbo.[Getsizetext](fk_sizeid)           AS PixelHeight, 
                    dbo.[Getsizetext](fk_sizeid)           AS PixelWidth, 
                    fk_sizeid, 
                    formname, 
                    [PageStartDT], 
                    [PageEndDT], 
                    pagename, 
                    pubpagenumber, 
                    pagetype.descrip 
                FROM   creativedetailpub 
                       LEFT JOIN pagetype 
                               ON creativedetailpub.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       LEFT JOIN size 
                               ON size.[SizeID] = creativedetailpub.fk_sizeid 
                WHERE  creativemasterid = @CreativeID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
	   END
	   ELSE IF @OccurrenceID > 0
	   BEGIN
			 SELECT  AdId,
				    [OccurrenceDetailPUBID] AS OccurrenceID,
				    CreativeMasterID as CreativeID,
				    CreativeDetailID,
				    PageNumber,
				    isDeleted,
				    @BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				    CreativeAssetThumbnailName As [ThumbnailSource] 
			 FROM  vw_PublicationCreatives 
			 WHERE [OccurrenceDetailPUBID]=@OccurrenceID  AND isDeleted=0  
			 ORDER BY  Pagenumber
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
		  SELECT	AdId,
				[OccurrenceDetailPUBID] AS OccurrenceID,
				CreativeMasterID AS CreativeID,
				CreativeDetailID,
				PageNumber,
				@BasePath + CreativeRepository +CreativeAssetName AS LocalCreativeFilePath,
				@RemoteBasePath + CreativeRepository +CreativeAssetName AS RemoteCreativeFilePath,
				CreativeAssetThumbnailName As [ThumbnailSource], 
				isDeleted
		  FROM  vw_PublicationCreatives 
		  WHERE ADID=@AdID AND PrimaryCreativeIndicator=1 AND isDeleted=0  
		  ORDER BY Pagenumber ASC,CreativeDetailID
	   END

END