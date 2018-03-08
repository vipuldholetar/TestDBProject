-- ================================================================================  
-- Author    : S Dinesh Karthick  
-- Create date  : 12th jan 2015  
-- Description  : This Procedure is Used to get the values coupon book   
-- Updated By  :   
-- Execution  : [sp_GetMultiCouponData] '01/30/2016','RedPlum'  
-- =========================================================================  
CREATE PROCEDURE [dbo].[Sp_getmulticoupondata] (@IssueDate AS VARCHAR(50)='', 
@Section AS VARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @SectionList VARCHAR(max) 
          DECLARE @AdvertiserIDList VARCHAR(max) 
          DECLARE @PublicationList VARCHAR(max) 
          DECLARE @BasePath AS NVARCHAR(max) 
          DECLARE @OccurrenceStatus AS NVARCHAR(10) 

          SET @OccurrenceStatus= (SELECT valuetitle 
                                  FROM   [Configuration] 
                                  WHERE  systemname = 'All' 
                                         AND componentname = 'Occurrence Status' 
                                         AND value = 'NT') 
          SET @BasePath= (SELECT value 
                          FROM   [Configuration] 
                          WHERE  systemname = 'All' 
                                 AND componentname = 'Creative Repository') 

          CREATE TABLE #tempdata 
            ( 
               id INT IDENTITY(1, 1) NOT NULL,adid INT NULL, 
               publicationlist VARCHAR(100) NULL 
            ) 

          SELECT @SectionList = ( COALESCE(@SectionList + ', ', '') 
                                  + Cast(value AS VARCHAR(max)) ) 
          FROM   [Configuration] 
          WHERE  systemname = 'All' 
                 AND componentname = 'Coupon Book to PUB' 
                 AND valuetitle = @Section 

          SELECT @AdvertiserIDList = COALESCE(@AdvertiserIDList + ', ', '') 
                                     + Cast(valuegroup AS VARCHAR(10)) 
          FROM   [Configuration] 
          WHERE  systemname = 'All' 
                 AND componentname = 'Coupon Book to PUB' 

          SELECT @PublicationList = COALESCE(@PublicationList + ', ', '') 
                                    + Cast(publication.[PublicationID] AS VARCHAR(10)) 
          FROM   pubsection 
                 INNER JOIN publication 
                         ON publication.[PublicationID] = pubsection.[PublicationID] 
          WHERE  [PubSectionID] IN (SELECT DISTINCT id 
                                     FROM   [dbo].[Fn_csvtotable](@SectionList)) 

          SELECT [row], [AdID], descrip, /*scanstatus*/'' as scanstatus, occurrenceid, [pagecount], color 
                 , 
                 [PublicationID] 
                 ,[PubSectionID],imagepath,languageid,[language],pubissueid, 
                 advertiserid, 
                 issuedate, /*occurrencestatus*/'' as occurrencestatus, checkedpublications 
          FROM   (
				SELECT Row_number() 
                           OVER( 
                             partition BY c.[AdID] 
                             ORDER BY a.[PubIssueID]) AS Row,c.[AdID], 
							 e.descrip, 
							 --c.scanstatus, 
							 (select [Status] from ScanStatus where ScanStatusID = c.ScanStatusID) as scanstatus,
									c.[OccurrenceDetailPUBID] AS OccurrenceID, 
							 --d.PK_Id,  
							 c.pagecount,c.color,b.[PublicationID], 
							 c.[PubSectionID], 
                                        CASE 
                                          WHEN ( 
                         g.creativerepository + g.creativeassetname ) IS 
                                               NULL THEN NULL 
                                          ELSE 
                         @BasePath + '\' + ( g.creativerepository + 
                                             g.creativeassetname ) 
                                        END AS ImagePath, 
                         [Language].languageid, 
                                [Language].description AS Language, 
                                a.[PubIssueID] AS PubIssueId, 
                                e.advertiserid, a.issuedate, (select [Status] from OccurrenceStatus where OccurrenceStatusID = c.OccurrenceStatusID) as occurrencestatus, 
                                        (SELECT 
          [dbo].[Fn_publicationlist](c.[AdID], 
          d.[AdvertiserID], 
          c.[PubSectionID], 
          CONVERT(VARCHAR, Cast( 
          @IssueDate AS DATE), 110) 
          )) AS CheckedPublications 
          FROM   ad d 
          INNER JOIN [OccurrenceDetailPUB] c 
          ON c.[AdID] = d.[AdID] 
          INNER JOIN pubissue a 
          ON a.[PubIssueID] = c.[PubIssueID] 
          INNER JOIN [Advertiser] e 
          ON e.advertiserid = d.[AdvertiserID] 
          INNER JOIN pubedition b 
          ON b. [PubEditionID] = a.[PubEditionID] 
          INNER JOIN [Language] 
          ON [Language].languageid = b.[LanguageID] 
          INNER JOIN [Pattern] f 
          ON f.[PatternID] = c.[PatternID] 
          INNER JOIN [Creative] 
          ON [Creative].pk_id = f.[CreativeID] 
          INNER JOIN creativedetailpub g 
          ON g.creativemasterid = [Creative].pk_id 
          WHERE  b.[PublicationID] IN (SELECT DISTINCT id 
          FROM   [dbo].[Fn_csvtotable](@PublicationList)) 
          AND a.issuedate = CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110) 
          AND (select [Status] from OccurrenceStatus where OccurrenceStatusID = c.OccurrenceStatusID) != @OccurrenceStatus 
          AND g.deleted = 0 
          AND c.[PubSectionID] IN (SELECT DISTINCT id 
          FROM   [dbo].[Fn_csvtotable](@SectionList))) a 
          WHERE  a.row = 1 

          SELECT CASE 
                   WHEN pubcode IS NULL THEN descrip 
                   ELSE pubcode 
                 END AS PubCode,[PublicationID] 
          FROM   publication 
          WHERE  [PublicationID] IN (SELECT DISTINCT id 
                                      FROM 
                 [dbo].[Fn_csvtotable](@PublicationList)) 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_GetMultiCouponData]: %d: %s',16,1,@error,@message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch 
  END