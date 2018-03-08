
-- ===================================================================================  
-- Author    : RP  
-- Create date  : 01/01/2016  
-- Description  : Save Multi Edition  
-- EXEC      :  
--[sp_PublicationSaveMultiEdition] '01/08/2016','86,70',0,25651,1040024,1,16352,29712031 , 
--' 
--   
--    1040048 
--    86 
--   
--   
--    1040044 
--    6 
--   
--' 
-- Updated By  : select * from [user] select * from marketmaster 
-- ======================================================================================  
CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionSave] (@IssueDate 
VARCHAR(50), 
                                                        @MarketList 
VARCHAR(max), 
                                                        @MNIIndicator 
BIT, 
                                                        @AdID 
INTEGER, 
                                                        @OccurrenceID 
BIGINT, 
                                                        @PublicationID 
INTEGER, 
                                                        @FirstPubIssueID 
INTEGER, 
                                                        @UserID 
INTEGER, 
                                                        @MarketOccurrenceXmlList 
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
          DECLARE @MarketID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @NewCreativeMasterID AS INT=0 
          DECLARE @CreativeDetailID AS INT=0 
          DECLARE @Primaryoccurrenceid AS BIGINT=0 
          DECLARE @NewOccurrenceId AS BIGINT=0 

          CREATE TABLE #tempnewpubissuemarkets 
            ( 
               rowid               INT IDENTITY(1, 1), 
               primaryoccurrenceid BIGINT, 
               marketid            INT, 
               pubissueid          INT 
            ) 

          -- Retreive data from XML and insert into temp table 
          INSERT INTO #tempnewpubissuemarkets 
                      (primaryoccurrenceid, 
                       marketid) 
          SELECT marketoccurrencedata.value('(OccurrenceID)[1]', 'bigint') AS 
                 primaryoccurrenceid 
                 , 
                 marketoccurrencedata.value('(MarketID)[1]', 'int')        AS 
                 marketid 
          FROM 
      @MarketOccurrenceXmlList.nodes('/DocumentElement/MarketOccurrenceData') AS 
      MarketOccurrenceProc(marketoccurrencedata) 

          SELECT * 
          FROM   #tempnewpubissuemarkets 

          SELECT @NumberRecords = Count(*) 
          FROM   #tempnewpubissuemarkets 

          SET @RowCount = 1 

          WHILE @RowCount <= @NumberRecords 
            BEGIN 
                SELECT @MarketID = marketid, 
                       @primaryoccurrenceid = primaryoccurrenceid 
                FROM   #tempnewpubissuemarkets 
                WHERE  rowid = @RowCount 

                PRINT( 'RowCOunt - ' + Cast(@RowCount AS VARCHAR) ) 

                PRINT( 'Market - ' + Cast(@MarketID AS VARCHAR) ) 

                PRINT( 'OccurrenceID - ' 
                       + Cast(@primaryoccurrenceid AS VARCHAR) ) 

                SET @PubIssueID=0 

                SELECT TOP 1 @PubIssueID = [PubIssueID] 
                FROM   pubissue a 
                       INNER JOIN pubedition b 
                               ON b.[PubEditionID] = a.[PubEditionID] 
                                  AND a.issuedate = @IssueDate 
                                  AND b.[PublicationID] = @PublicationID 
                                  AND b.[MarketID] = @MarketID 
                                  AND a.notakereason IS NULL 
                                  -- excludes Pub Issue No Take  
                                  AND b.[MNIInd] = @MNIIndicator 

                PRINT( 'Pubissueid' 
                       + Cast(@PubIssueID AS VARCHAR) ) 

                IF @PubIssueID = 0 
                  BEGIN 
                      INSERT INTO pubissue 
                                  ([EnvelopeID], 
                                   [SenderID], 
                                   [PubEditionID], 
                                   [ShippingMethodID], 
                                   [PackageTypeID], 
                                   issuedate, 
                                   trackingnumber, 
                                   printedweight, 
                                   actualweight, 
                                   packageassignment, 
                                   receiveon, 
                                   receiveby, 
                                   status, 
                                   createdtm, 
                                   createby) 
                      SELECT [EnvelopeID], 
                             [SenderID], 
                             (SELECT [PubEditionID] 
                              FROM   pubedition 
                              WHERE  [PublicationID] = @PublicationID 
                                     AND [MarketID] = @MarketID 
                                     AND [MNIInd] = @MNIIndicator), 
                             [ShippingMethodID], 
                             [PackageTypeID], 
                             issuedate, 
                             trackingnumber, 
                             printedweight, 
                             actualweight, 
                             packageassignment, 
                             receiveon, 
                             receiveby, 
                             status, 
                             Getdate(), 
                             @UserID 
                      FROM   pubissue 
                      WHERE  [PubIssueID] = @FirstPubIssueID 

                      SET @PubIssueID=Scope_identity(); 
                  END 

                UPDATE #tempnewpubissuemarkets 
                SET    pubissueid = @PubissueID 
                WHERE  marketid = @MarketID 
                       AND primaryoccurrenceid = @primaryoccurrenceid 

                INSERT INTO [Pattern] 
                            ([CreativeID], 
                             [AdID], 
                             mediastream, 
                             [Exception], 
                             priority, 
                             exceptiontext, 
                             [Query], 
                             querycategory, 
                             querytext, 
                             queryanswer, 
                             takereasoncode, 
                             notakereasoncode, 
                             status, 
                             [EventID], 
                             [ThemeID], 
                             [SalesStartDT], 
                             [SalesEndDT], 
                             [FlashInd], 
                             nationalindicator, 
                             editinits, 
                             lastmappeddate, 
                             lastmapperinits, 
                             couponindicator) 
                SELECT NULL, 
                       b.[AdID], 
                       b.mediastream, 
                       b.[Exception], 
                       b.priority, 
                       b.exceptiontext, 
                       b.[Query], 
                       b.querycategory, 
                       b.querytext, 
                       b.queryanswer, 
                       b.takereasoncode, 
                       b.notakereasoncode, 
                       b.status, 
                       b.[EventID], 
                       b.[ThemeID], 
                       b.[SalesStartDT], 
                       b.[SalesEndDT], 
                       b.[FlashInd], 
                       b.nationalindicator, 
                       b.editinits, 
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

                INSERT INTO [OccurrenceDetailPUB] 
                            ([AdID], 
                             [MediaTypeID], 
                             [MarketID], 
                             [PubIssueID], 
                             [PatternID], 
                             [SubSourceID], 
                             [SizeID], 
                             [PubSectionID], 
                             size, 
                             [AdDT], 
                             priority, 
                             internalrefencenotes, 
                             color, 
                             sizingmethod, 
                             pubpagenumber, 
                             pagecount, 
                             mniindicator, 
                             [CreatedDT], 
                             [CreatedByID], 
                             MapStatusID, 
                             IndexStatusID) 
                SELECT [AdID], 
                       [MediaTypeID], 
                       @marketid, 
                       @PubIssueID, 
                       @PatternMasterID, 
                       [SubSourceID], 
                       [SizeID], 
                       [PubSectionID], 
                       size, 
                       [AdDT], 
                       priority, 
                       internalrefencenotes, 
                       color, 
                       sizingmethod, 
                       pubpagenumber, 
                       pagecount, 
                       @Mniindicator, 
                       Getdate(), 
                       @Userid, 
                       MapStatusID, 
                       IndexStatusID 
                FROM   [OccurrenceDetailPUB] 
                WHERE  [OccurrenceDetailPUBID] = @primaryoccurrenceid 

                SET @NewOccurrenceId=Scope_identity(); 

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
                            ([AdId], 
                             [SourceOccurrenceId], 
                             envelopid, 
                             primaryindicator, 
                             primaryquality) 
                SELECT [AdId], 
                       @NewOccurrenceId, 
                       envelopid, 
                       primaryindicator, 
                       primaryquality 
                FROM   [Creative] 
                WHERE  pk_id = @CreativeMasterid 

                SET @NewCreativeMasterid=Scope_identity(); 

                UPDATE [Pattern] 
                SET    [CreativeID] = @NewCreativeMasterid 
                WHERE  [PatternID] = @PatternMasterID 

                -- Insert into Creative Details 
                INSERT INTO creativedetailpub 
                            (creativemasterid, 
                             deleted, 
                             pagenumber, 
                             [PageTypeID], 
                             fk_sizeid, 
                             pagename, 
                             pubpagenumber) 
                SELECT @NewCreativeMasterID, 
                       0, 
                       pagenumber, 
                       [PageTypeID], 
                       fk_sizeid, 
                       pagename, 
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

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_PublicationMultiEditionSave]: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch 
  END