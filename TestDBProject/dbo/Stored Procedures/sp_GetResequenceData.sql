-- ===================================================================================================== 
-- Author    :  Karunakar 
-- Create date  :  15th December 2015 
-- Execution  :  sp_GetResequenceData 27035,'CIR' 
-- Description  :  This Procedure is used to Get Resequence Records 
-- Updated By  :   
-- ======================================================================================================= 
CREATE PROCEDURE [dbo].[sp_GetResequenceData]( @CreativeMasterID AS INT, 
                                              @MediaStream      AS NVARCHAR(50) ,
										  @isStaging as bit = 0) 
AS 
  BEGIN 
      SET nocount ON; 

      IF( @MediaStream = 'CIR' ) --Circular 
        BEGIN 
            SELECT creativedetailid, 
                   creativemasterid, 
                   Substring(creativeassetname, 0, 
                   Charindex('.', ( creativeassetname 
                                  )) 
                   ) AS 
                   ImageName, 
                   pagetype.[PageTypeID], 
                   pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelWidth, 
                   size.[SizeID], 
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) 
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   creativedetailcir 
                   INNER JOIN pagetype 
                           ON creativedetailcir.[PageTypeID] = pagetype.[PageTypeID] 
                   INNER JOIN size 
                           ON size.[SizeID] = creativedetailcir.[SizeID] 
            WHERE  ( creativemasterid = @CreativeMasterID ) 
                   AND deleted = 0 
            ORDER  BY pagenumber 
        END 

      IF( @MediaStream = 'PUB' ) --Publication 
        BEGIN 
            SELECT creativedetailid, 
                   creativemasterid, 
                   Substring(creativeassetname, 0, 
                   Charindex('.', ( creativeassetname 
                                  )) 
                   ) AS 
                   ImageName, 
                   pagetype.[PageTypeID], 
                   pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](fk_sizeid) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](fk_sizeid) 
                   AS 
                   PixelWidth, 
                   fk_sizeid, 
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) 
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   creativedetailpub 
                   INNER JOIN pagetype 
                           ON creativedetailpub.[PageTypeID] = pagetype.[PageTypeID] 
                   INNER JOIN size 
                           ON size.[SizeID] = creativedetailpub.fk_sizeid 
            WHERE  ( creativemasterid = @CreativeMasterID ) 
                   AND deleted = 0 
            ORDER  BY pagenumber 
        END 

      IF( @MediaStream = 'EM' ) --Email 
        BEGIN 
		IF(@isStaging =0)
		Begin
		SELECT [CreativeDetailsEMID] 
                   AS 
                   CreativeDetailID, 
                   creativemasterid, 
                   CASE WHEN creativeassetname is null THEN LegacyAssetName
						ELSE Substring(creativeassetname, 0,Charindex('.', ( creativeassetname))) END
                    AS ImageName, 
                   pagetype.[PageTypeID], 
					CASE WHEN pagenumber is null then ROW_NUMBER() OVER(ORDER BY [CreativeDetailsEMID] ASC) ELSE PAGENUMBER END AS Pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelWidth, 
                   size.[SizeID],
				    CASE WHEN pagenumber is null THEN 
					( Replicate('0', 3 - Len(ROW_NUMBER() OVER(ORDER BY [CreativeDetailsEMID] ASC)))+ Cast(ROW_NUMBER() OVER(ORDER BY [CreativeDetailsEMID] ASC) AS VARCHAR(3)) )
					ELSE
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) END
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   creativedetailem 
                   LEFT JOIN pagetype 
                           ON creativedetailem.pagetypeid = pagetype.[PageTypeID] 
                   LEFT JOIN size 
                           ON size.[SizeID] = creativedetailem.[SizeID] 
            WHERE  ( creativemasterid = @CreativeMasterID ) --AND  creativedetailem.PageNumber IS NOT NULL
                    AND (deleted = 0  or deleted is null) 
            ORDER  BY pagenumber
		end 
		else
		begin 
		
		 SELECT [CreativeDetailStagingEMID] 
                   AS 
                   CreativeDetailID, 
                   CreativeStagingID AS creativemasterid, 
                   CASE WHEN creativeassetname is null THEN LegacyAssetName
						ELSE Substring(creativeassetname, 0,Charindex('.', ( creativeassetname))) END
                    AS ImageName, 
                   pagetype.[PageTypeID], 
					CASE WHEN pagenumber is null then ROW_NUMBER() OVER(ORDER BY [CreativeDetailStagingEMID] ASC) ELSE PAGENUMBER END AS Pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelWidth, 
                   size.[SizeID],
				    CASE WHEN pagenumber is null THEN 
					( Replicate('0', 3 - Len(ROW_NUMBER() OVER(ORDER BY [CreativeDetailStagingEMID] ASC)))+ Cast(ROW_NUMBER() OVER(ORDER BY [CreativeDetailStagingEMID] ASC) AS VARCHAR(3)) )
					ELSE
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) END
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   CreativeDetailStagingEM 
                   LEFT JOIN pagetype 
                           ON CreativeDetailStagingEM.pagetypeid = pagetype.[PageTypeID] 
                   LEFT JOIN size 
                           ON size.[SizeID] = CreativeDetailStagingEM.[SizeID] 
            WHERE  ( CreativeStagingID = @CreativeMasterID ) 
                    AND (deleted = 0  or deleted is null) 
            ORDER  BY pagenumber
		END 
        END

      IF( @MediaStream = 'SOC' ) --Social 
        BEGIN 
            SELECT [CreativeDetailSOCID] 
                   AS 
                   CreativeDetailID, 
                   creativemasterid, 
                   Substring(creativeassetname, 0, 
                   Charindex('.', ( creativeassetname 
                                  )) 
                   ) AS 
                   ImageName, 
                   pagetype.[PageTypeID], 
                   pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelWidth, 
                   size.[SizeID], 
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) 
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   creativedetailsoc 
                   INNER JOIN pagetype 
                           ON creativedetailsoc.[PageTypeID] = pagetype.[PageTypeID] 
                   INNER JOIN size 
                           ON size.[SizeID] = creativedetailsoc.[SizeID] 
            WHERE  ( creativemasterid = @CreativeMasterID ) 
                   AND deleted = 0 
            ORDER  BY pagenumber 
        END 

      IF( @MediaStream = 'WEB' ) --Website 
        BEGIN 
            SELECT [CreativeDetailWebID] 
                   AS 
                   CreativeDetailID, 
                   creativemasterid, 
                   Substring(creativeassetname, 0, 
                   Charindex('.', ( creativeassetname 
                                  )) 
                   ) AS 
                   ImageName, 
                   pagetype.[PageTypeID], 
                   pagenumber, 
                   pagename, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelHeight, 
                   dbo.[Getsizetext](size.[SizeID]) 
                   AS 
                   PixelWidth, 
                   size.[SizeID], 
                   ( Replicate('0', 3 - Len(pagenumber)) 
                     + Cast(pagenumber AS VARCHAR(3)) ) 
                   AS 
                   ImageFileName, 
                   Isnull(Substring(creativeassetname, 0, Charindex('.', ( 
                   creativeassetname) 
                   )), ( 
                   Replicate('0', 3 - Len(pagenumber)) + Cast(pagenumber AS 
                   VARCHAR(3) 
                   )) 
                   ) 
                   + '-' + pagetype.descrip 
                   AS 
                   PageSize 
            FROM   creativedetailweb 
                   INNER JOIN pagetype 
                           ON creativedetailweb.[PageTypeID] = pagetype.[PageTypeID] 
                   INNER JOIN size 
                           ON size.[SizeID] = creativedetailweb.[SizeID] 
            WHERE  ( creativemasterid = @CreativeMasterID ) 
                   AND deleted = 0 
            ORDER  BY pagenumber 
        END 
  END
