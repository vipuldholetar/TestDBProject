
-- ==================================================================================================== 
-- Author            : Arun Nair    
-- Create date       : 12/15/2015   
-- Execution     : sp_GetCreativeData 374994,'MOB',''   
-- Description       : Get CreativeDetails Records for Print Media   
-- Updated By     : Arun Nair on  02/04/2016 for Mobile Creative  
-- ==================================================================================================== 
CREATE PROCEDURE [dbo].[Sp_getcreativedata] 
--'','MOB','02b708654f0e177c2b235773158865b35d8deb59'  
(@CreativeMasterID  AS INT, 
 @MediaStreamVal    AS VARCHAR(50), 
 @CreativeSignature AS VARCHAR(500)) 
AS 
  BEGIN 
      SET nocount ON; 
	  
      BEGIN try 
          IF( @MediaStreamVal = 'CIR' ) --Circular   
            BEGIN 
                SELECT creativedetailid, 
                       creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
                       creativefiletype, 
                       deleted, 
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
                       pagetype.descrip 
                FROM   creativedetailcir 
                       INNER JOIN pagetype 
                               ON creativedetailcir.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       INNER JOIN size 
                               ON size.[SizeID] = creativedetailcir.[SizeID] 
                WHERE  creativemasterid = @CreativeMasterID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
            END 

          IF( @MediaStreamVal = 'PUB' ) --Publication   
            BEGIN 
                SELECT creativedetailid, 
                       creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
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
                       INNER JOIN pagetype 
                               ON creativedetailpub.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       INNER JOIN size 
                               ON size.[SizeID] = creativedetailpub.fk_sizeid 
                WHERE  creativemasterid = @CreativeMasterID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
            END 

          IF( @MediaStreamVal = 'EM' ) --Email   
            BEGIN 
			if exists( Select top 1 adid from CreativeDetailEM inner join creative on creative.PK_Id = CreativeDetailEM.CreativeMasterID
   where CreativeMasterID = @CreativeMasterID   and adid is not null)
   begin
                SELECT [CreativeDetailsEMID]                                  AS 
                       CreativeDetailID, 
                       creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
                       creativefiletype, 
                       deleted, 
                       pagenumber, 
                       creativedetailem.pagetypeid, 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
                       size.[SizeID], 
                       formname, 
                       [PageStartDT], 
                       [PageEndDT], 
                       pagename, 
                       emailpagenumber                        AS PubPageNumber, 
                       pagetype.descrip 
                FROM   creativedetailem 
                       LEFT JOIN pagetype 
                               ON creativedetailem.pagetypeid = 
                                  pagetype.[PageTypeID] 
                       LEFT JOIN size 
                               ON size.[SizeID] = creativedetailem.[SizeID] 
                WHERE  creativemasterid = @CreativeMasterID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 

				END 
				ELSE
				BEGIN 

				--Edited By Mark Marshall
				
				       SELECT [CreativeDetailStagingEM].CreativeDetailStagingEMID                       AS 
                       CreativeDetailID, 
                       [CreativeDetailStagingEM].[CreativeStagingID] AS 
                       CreativeMasterID, 
                       creativeassetname, 
                       creativerepository + creativeassetname               AS 
                       CreativeRepository, 
                       creativefiletype, 
                       0                                                    AS 
                       Deleted 
                       , 
                       1 
                       AS PageNumber, 
                       ''                                                   AS 
                       PageTypeId, 
                       ''                                                   AS 
                       PixelHeight 
                       , 
                       '' 
                       AS PixelWidth, 
                       0                                                    AS 
                       FK_SizeID, 
                       ''                                                   AS 
                       FormName, 
                       Getdate()                                            AS 
                       PageStartDt 
                       , 
                       Getdate() 
                       AS PageEndDt, 
                       ''                                                   AS 
                       PageName, 
                       1                                                    AS 
                       PubPageNumber 
                       , 
                       ''                                                   AS 
                       Descrip 
                FROM   [dbo].[PatternStaging] 
                       INNER JOIN [dbo].[CreativeDetailStagingEM] 
                               ON 
            [dbo].[CreativeDetailStagingEM].[CreativeStagingID] 
            = 
            [dbo].[PatternStaging].[CreativeStgID] 
			
                WHERE  [dbo].[CreativeDetailStagingEM].[CreativeStagingID] =  @CreativeMasterID 
				AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
			
			END

            END 

          IF( @MediaStreamVal = 'SOC' ) --Social   
            BEGIN 
                SELECT [CreativeDetailSOCID]                                  AS 
                       CreativeDetailID, 
                       creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
                       creativefiletype, 
                       deleted                                PageNumber, 
                       creativedetailsoc.[PageTypeID], 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
                       size.[SizeID], 
                       formname, 
                       [PageStartDT], 
                       [PageEndDT], 
                       pagename, 
                       pubpagenumber, 
                       pagetype.descrip 
                FROM   creativedetailsoc 
                       INNER JOIN pagetype 
                               ON creativedetailsoc.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       INNER JOIN size 
                               ON size.[SizeID] = creativedetailsoc.[SizeID] 
                WHERE  creativemasterid = @CreativeMasterID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
            END 

          IF( @MediaStreamVal = 'WEB' ) --Website   
            BEGIN 
                SELECT [CreativeDetailWebID]                                  AS 
                       CreativeDetailID, 
                       creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
                       creativefiletype, 
                       deleted, 
                       pagenumber, 
                       creativedetailweb.[PageTypeID], 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelHeight, 
                       dbo.[Getsizetext](size.[SizeID])           AS PixelWidth, 
                       size.[SizeID], 
                       formname, 
                       [PageStartDT], 
                       [PageEndDT], 
                       pagename, 
                       pubpagenumber, 
                       pagetype.descrip 
                FROM   creativedetailweb 
                       INNER JOIN pagetype 
                               ON creativedetailweb.[PageTypeID] = 
                                  pagetype.[PageTypeID] 
                       INNER JOIN size 
                               ON size.[SizeID] = creativedetailweb.[SizeID] 
                WHERE  creativemasterid = @CreativeMasterID 
                       AND deleted = 0 
                       AND creativeassetname IS NOT NULL 
                ORDER  BY pagenumber 
            END 

          IF( @MediaStreamVal = 'OD' 
              AND @CreativeSignature <> '' ) --Outdoor staging   
            BEGIN 
                SELECT [CreativeDetailStagingODR].[CreativeDetailStagingODRID]                        AS 
                       CreativeDetailID, 
                       [CreativeDetailStagingODR].[CreativeStagingID] AS 
                       CreativeMasterID, 
                       creativeassetname, 
                       creativerepository + creativeassetname               AS 
                       CreativeRepository, 
                       creativefiletype, 
                       0                                                    AS 
                       Deleted 
                       , 
                       1 
                       AS PageNumber, 
                       ''                                                   AS 
                       PageTypeId, 
                       ''                                                   AS 
                       PixelHeight 
                       , 
                       '' 
                       AS PixelWidth, 
                       0                                                    AS 
                       FK_SizeID, 
                       ''                                                   AS 
                       FormName, 
                       Getdate()                                            AS 
                       PageStartDt 
                       , 
                       Getdate() 
                       AS PageEndDt, 
                       ''                                                   AS 
                       PageName, 
                       1                                                    AS 
                       PubPageNumber 
                       , 
                       ''                                                   AS 
                       Descrip 
                FROM   [dbo].[PatternStaging] 
                       INNER JOIN [dbo].[CreativeDetailStagingODR] 
                               ON 
            [dbo].[CreativeDetailStagingODR].[CreativeStagingID] 
            = 
            [dbo].[PatternStaging].[CreativeStgID] 
                WHERE  [dbo].[PatternStaging].[CreativeSignature] = 
                       @CreativeSignature 
            END 

          IF( @MediaStreamVal = 'OD' 
              AND (@CreativeSignature = '' or @CreativeSignature IS NULL) ) --Outdoor After Mapping   
            BEGIN 
                SELECT creativedetailodr.[CreativeDetailODRID]                AS 
                       CreativeDetailID, 
                       creativedetailodr.creativemasterid, 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
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
                                  AND [Creative].pk_id = @CreativeMasterID 
                                  AND [Creative].primaryindicator = 1 
            END 

          IF( @MediaStreamVal = 'OND' 
              AND @CreativeSignature <> '' ) --Online Display staging   
            BEGIN 
                DECLARE @CreativeMasterStgid AS INT 

                SELECT @CreativeMasterStgid = [CreativeStagingID] 
                FROM   [CreativeStaging] 
                WHERE  creativesignature = @CreativeSignature 

                SELECT [creativedetailstagingond].[CreativeDetailStagingID] AS 
                       CreativeDetailID, 
                       [creativedetailstagingond].CreativeStagingID AS 
                       CreativeMasterID 
                       , 
                       creativeassetname, 
                       creativerepository + creativeassetname                AS 
                       CreativeRepository, 
                       creativefiletype, 
                       0                                                     AS 
                       Deleted, 
                       1                                                     AS 
                       PageNumber 
                       , 
                       '' 
                       AS PageTypeId, 
                       ''                                                    AS 
                       PixelHeight, 
                       ''                                                    AS 
                       PixelWidth 
                       , 
                       0 
                       AS FK_SizeID, 
                       ''                                                    AS 
                       FormName, 
                       Getdate()                                             AS 
                       PageStartDt, 
                       Getdate()                                             AS 
                       PageEndDt, 
                       ''                                                    AS 
                       PageName, 
                       1                                                     AS 
                       PubPageNumber, 
                       ''                                                    AS 
                       Descrip 
                FROM   [dbo].[creativedetailstagingond] 
                WHERE 
            [dbo].[creativedetailstagingond].CreativeStagingID 
            = 
                   @CreativeMasterStgid 
            AND creativedownloaded = 1 
            AND filesize > 0 
            AND [dbo].[creativedetailstagingond].[creativerepository] 
                IS 
                NOT 
                NULL 
            END 

		  IF( @MediaStreamVal = 'OND' 
              AND (@CreativeSignature = '' or @CreativeSignature is null) ) --Online Display staging   
            BEGIN 
                SELECT [dbo].[creativedetailOND].[CreativeDetailONDID]        AS 
                       CreativeDetailID, 
                       [dbo].[creativedetailOND].[CreativeMasterID], 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
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
                       INNER JOIN [dbo].[creativedetailOND] 
                               ON [Creative].pk_id = 
                                  [dbo].[creativedetailOND].[CreativeMasterID] 
                                  AND [Creative].pk_id = @CreativeMasterID 
                                  AND [Creative].primaryindicator = 1 
            END 

          IF( @MediaStreamVal = 'MOB' 
              AND @CreativeSignature <> '' ) --Mobile staging   
            BEGIN 
                SELECT 
            [dbo].[creativedetailstagingmob].[CreativeDetailStagingID] 
            AS 
            CreativeDetailID, 
            [dbo].[creativedetailstagingmob].CreativeStagingID 
            AS 
            CreativeMasterID, 
            creativeassetname, 
            [dbo].[creativedetailstagingmob].[creativerepository] 
            + creativeassetname 
            AS 
            CreativeRepository, 
            [dbo].[creativedetailstagingmob].[creativefiletype], 
            0 
            AS 
            Deleted, 
            1 
            AS 
            PageNumber 
            , 
            '' 
            AS 
            PageTypeId, 
            '' 
            AS 
            PixelHeight, 
            '' 
            AS 
            PixelWidth 
            , 
            0 
            AS 
            FK_SizeID, 
            '' 
            AS 
            FormName, 
            Getdate() 
            AS 
            PageStartDt, 
            Getdate() 
            AS 
            PageEndDt, 
            '' 
            AS 
            PageName, 
            1 
            AS 
            PubPageNumber, 
            '' 
            AS 
            Descrip 
                FROM   [dbo].[PatternStaging] 
                       INNER JOIN [dbo].[creativedetailstagingmob] 
                               ON 
            [dbo].[creativedetailstagingmob].CreativeStagingID 
            = 
            [dbo].[PatternStaging].[CreativeStgID] 
                WHERE  [dbo].[creativedetailstagingmob] .signaturedefault = 
                       @CreativeSignature 
            END 

          IF( @MediaStreamVal = 'MOB' 
              AND (@CreativeSignature = '' or @CreativeSignature is null) ) --Mobile After Mapping   
            BEGIN 
                SELECT [dbo].[creativedetailmob].[CreativeDetailMOBID]        AS 
                       CreativeDetailID, 
                       [dbo].[creativedetailmob].[CreativeMasterID], 
                       creativeassetname, 
                       creativerepository + creativeassetname AS 
                       CreativeRepository, 
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
                       INNER JOIN [dbo].[creativedetailmob] 
                               ON [Creative].pk_id = 
                                  [dbo].[creativedetailmob].[CreativeMasterID] 
                                  AND [Creative].pk_id = @CreativeMasterID 
                                  AND [Creative].primaryindicator = 1 
            END 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetCreativedata: %d: %s',16,1,@error,@message,@lineNo); 
      END catch 
  END