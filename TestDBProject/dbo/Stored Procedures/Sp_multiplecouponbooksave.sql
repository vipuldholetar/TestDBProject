
-- ===================================================================================    
-- Author    : S Dinesh KArthick    
-- Create date  : 01/25/2016    
-- Description  : Save Multiple Couponbook    
-- EXEC      : [sp_MultipleCouponBookSave] '01/27/16','',31794,1080087,0,0,29712224,'108008722'
-- Updated By   :   
-- ======================================================================================    
CREATE PROCEDURE [dbo].[Sp_multiplecouponbooksave] (@IssueDate VARCHAR(50), 
@PublicationList VARCHAR(max),@AdID INTEGER,@OccurrenceID BIGINT,@PublicationID 
INTEGER,@FirstPubIssueID INTEGER,@UserID INTEGER,@PublicationOccurrenceXmlList 
XML) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          --   /// create PubIssue for each newly checked Market    
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @PubIssueID AS INT=0 
          --DECLARE @PublicationID AS INT=0   
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @NewCreativeMasterID AS INT=0 
          DECLARE @CreativeDetailID AS INT=0 
          DECLARE @Primaryoccurrenceid AS BIGINT=0 
          DECLARE @NewOccurrenceId AS BIGINT=0 

          CREATE TABLE #tempnewpubissuepublication 
            ( 
               rowid INT IDENTITY(1, 1),primaryoccurrenceid BIGINT, 
               publicationid INT, 
               pubissueid INT 
            ) 

          -- Retreive data from XML publication and insert into temp table   
          INSERT INTO #tempnewpubissuepublication 
                      (primaryoccurrenceid,publicationid) 
          SELECT publicationoccurrencedata.value('(OccurrenceID)[1]', 'bigint') 
                 AS 
                 primaryoccurrenceid, 
                 publicationoccurrencedata.value('(PublicationID)[1]', 
                 'int') AS publicationid 
          FROM 
@PublicationOccurrenceXmlList.nodes('DocumentElement/PublicationOccurrenceData') 
AS PublicationOccurrenceProc(publicationoccurrencedata) 

    SELECT * 
    FROM   #tempnewpubissuepublication 

    SELECT @NumberRecords = Count(*) 
    FROM   #tempnewpubissuepublication 

    SET @RowCount = 1 

    WHILE @RowCount <= @NumberRecords 
      BEGIN 
          SELECT @PublicationID = publicationid, 
                 @primaryoccurrenceid = primaryoccurrenceid 
          FROM   #tempnewpubissuepublication 
          WHERE  rowid = @RowCount 

          PRINT( 'RowCount - ' + Cast(@RowCount AS VARCHAR) ) 

          PRINT( 'PublicationID  - ' 
                 + Cast(@PublicationID AS VARCHAR) ) 

          PRINT( 'OccurrenceID - ' 
                 + Cast(@primaryoccurrenceid AS VARCHAR) ) 

          SET @PubIssueID=0 

          SELECT TOP 1 @PubIssueID = [PubIssueID] 
          FROM   pubissue a 
                 INNER JOIN pubedition b 
                         ON b.[PubEditionID] = a.[PubEditionID] 
                            AND a.issuedate = @IssueDate 
                            AND b.[PublicationID] = @PublicationID 
                            AND a.notakereason IS NULL 

          --PRINT( 'Pubissueid' + Cast(@PubIssueID AS VARCHAR) )   
          PRINT Cast(@PubIssueID AS VARCHAR) 
                + 'Before Insert' 

          IF @PubIssueID = 0 
            BEGIN 
                INSERT INTO pubissue 
                            ([EnvelopeID],[SenderID],[PubEditionID], 
                             [ShippingMethodID] 
                             , 
                             [PackageTypeID], 
                             issuedate,trackingnumber,printedweight,actualweight 
                             , 
                             packageassignment,receiveon,receiveby,status, 
                             createdtm, 
                             createby 
                ) 
                SELECT [EnvelopeID],[SenderID],(SELECT [PubEditionID] 
                                                  FROM   pubedition 
                                                  WHERE 
                       [PublicationID] = @PublicationID 
                                                 ), 
                       [ShippingMethodID],[PackageTypeID],issuedate, 
                       trackingnumber 
                       , 
                       printedweight,actualweight,packageassignment,receiveon, 
                       receiveby, 
                       status, 
                       Getdate(),@UserID 
                FROM   pubissue 
                WHERE  [PubIssueID] = @FirstPubIssueID 

                SET @PubIssueID=Scope_identity(); 
            END 

          PRINT Cast(@PubIssueID AS VARCHAR) 
                + 'After Insert' 

          UPDATE #tempnewpubissuepublication 
          SET    pubissueid = @PubissueID 
          WHERE  publicationid = @PublicationID 
                 AND primaryoccurrenceid = @primaryoccurrenceid 

          INSERT INTO [Pattern] 
                      ([CreativeID],[AdID],mediastream,[Exception],priority, 
                       exceptiontext,[Query], 
                       querycategory,querytext,queryanswer,takereasoncode, 
                       notakereasoncode 
                       ,status,[EventID],[ThemeID],[SalesStartDT],[SalesEndDT], 
                       [FlashInd], 
                       nationalindicator,editinits,lastmappeddate, 
                       lastmapperinits, 
                       couponindicator) 
          SELECT NULL,b.[AdID],b.mediastream,b.[Exception],b.priority, 
                 b.exceptiontext, 
                 b.[Query], 
                 b.querycategory,b.querytext,b.queryanswer,b.takereasoncode, 
                 b.notakereasoncode,b.status,b.[EventID],b.[ThemeID], 
                 b.[SalesStartDT], 
                 b.[SalesEndDT], 
                 b.[FlashInd],b.nationalindicator,b.editinits, 
                 b.lastmappeddate, 
                 b.lastmapperinits, 
                 b.couponindicator 
          FROM   [OccurrenceDetailPUB] a 
                 INNER JOIN [Pattern] b 
                         ON a.[PatternID] = b.[PatternID] 
                            AND a.[OccurrenceDetailPUBID] = @primaryoccurrenceid 

          SET @PatternMasterID = Scope_identity(); 

          PRINT( 'PatternMasterid -' 
                 + Cast(@PatternMasterID AS VARCHAR) ) 

          PRINT Cast(@PubIssueID AS VARCHAR) 
                + 'After Occc Insert' 

          INSERT INTO [OccurrenceDetailPUB] 
                      ([AdID],[MediaTypeID],[MarketID],[PubIssueID], 
                       [PatternID], 
                       [SubSourceID],[SizeID],[PubSectionID],size,[AdDT], 
                       priority 
                       , 
                       internalrefencenotes,color,sizingmethod,pubpagenumber, 
                       pagecount 
                       , 
                       mniindicator, [CreatedDT], [CreatedByID], MapStatusID, IndexStatusID) 
          SELECT [AdID],[MediaTypeID],[MarketID],@PubIssueID,@PatternMasterID 
                 , 
                 [SubSourceID], 
                 [SizeID],[PubSectionID],size,[AdDT],priority, 
                 internalrefencenotes 
                 , 
                 color 
                 ,sizingmethod,pubpagenumber,pagecount,mniindicator,Getdate(), 
                 @Userid, 
                 MapStatusID, IndexStatusID 
          FROM   [OccurrenceDetailPUB] 
          WHERE  [OccurrenceDetailPUBID] = @primaryoccurrenceid 

          SET @NewOccurrenceId=Scope_identity(); 

          --print ' inserted into occurances'  
          PRINT( 'NewOccurrenceid-' 
                 + Cast(@NewOccurrenceID AS VARCHAR) ) 

          -- Insert into Creative Master   
          SELECT @CreativeMasterid = [CreativeID] 
          FROM   [OccurrenceDetailPUB] a 
                 INNER JOIN [Pattern] b 
                         ON a.[PatternID] = b.[PatternID] 
                            AND a.[OccurrenceDetailPUBID] = @primaryoccurrenceid 

          -- Insert into Creative Master   
          INSERT INTO [Creative] 
                      ([AdId],[SourceOccurrenceId],envelopid,primaryindicator, 
                       primaryquality) 
          SELECT [AdId],@NewOccurrenceId,envelopid,primaryindicator, 
                 primaryquality 
          FROM   [Creative] 
          WHERE  pk_id = @CreativeMasterid 

          SET @NewCreativeMasterid=Scope_identity(); 

          UPDATE [Pattern] 
          SET    [CreativeID] = @NewCreativeMasterid 
          WHERE  [PatternID] = @PatternMasterID 

          -- Insert into Creative Details   
          INSERT INTO creativedetailpub 
                      (creativemasterid,deleted,pagenumber,[PageTypeID],fk_sizeid, 
                       pagename,pubpagenumber) 
          SELECT @NewCreativeMasterID,0,pagenumber,[PageTypeID],fk_sizeid,pagename 
                 , 
                 pubpagenumber 
          FROM   creativedetailpub 
          WHERE  creativemasterid = @CreativeMasterid 

          EXEC Sp_publicationdpfoccurrencestatus 
            @NewOccurrenceId, 
            1 

          SET @RowCount=@RowCount + 1 
      END 

    COMMIT TRANSACTION 
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(),@message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('[sp_MultipleCouponBookSave]: %d: %s',16,1,@error,@message, 
                   @lineNo); 

        ROLLBACK TRANSACTION 
    END catch 
END