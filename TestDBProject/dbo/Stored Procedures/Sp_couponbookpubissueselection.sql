-- =============================================  
-- Author    :Amrutha  
-- Create date  : 25th jan 2015  
-- Description  : This Procedure is Used to get the values PubIssue Selection  
-- Execution  : [sp_CouponBookPubIssueSelection] '01/25/2016','RedPlum'  
-- =============================================  
CREATE PROCEDURE [dbo].[Sp_couponbookpubissueselection] @IssueDate VARCHAR(50), 
@Section VARCHAR(150) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          DECLARE @SectionList VARCHAR(max) 
          DECLARE @PublicationList NVARCHAR(100) 

          SELECT @SectionList = ( COALESCE(@SectionList + ', ', '') 
                                  + Cast(value AS VARCHAR(max)) ) 
          FROM   [Configuration] 
          WHERE  systemname = 'All' 
                 AND componentname = 'Coupon Book to PUB' 
                 AND valuetitle = @Section 

          --print(@SectionList)  
          PRINT( @PublicationList ) 

          SELECT @PublicationList = COALESCE(@PublicationList + ', ', '') 
                                    + Cast(pubsection.[PublicationID] AS VARCHAR(10)) 
          FROM   pubsection 
                 INNER JOIN publication 
                         ON publication.[PublicationID] = pubsection.[PublicationID] 
          WHERE  [PubSectionID] IN (SELECT DISTINCT id 
                                     FROM   [dbo].[Fn_csvtotable](@SectionList)) 

          PRINT( @PublicationList ) 

          SELECT d.descrip AS Publication,d.pubcode AS PubCode, 
                 b.editionname AS PubEdition 
                 , 
                 a.[PubIssueID] AS PubIssueID, 
                 d.[PublicationID] AS PublicationID 
                 , 
                 b.[PubEditionID] AS PubEditionID,b.[LanguageID] AS LanguageID 
                 , 
                 z.description AS Language,@IssueDate AS IssueDate 
          FROM   pubedition b 
                 INNER JOIN publication d 
                         ON d.[PublicationID] = b.[PublicationID] 
                 INNER JOIN [Language] z 
                         ON z.languageid = b.[LanguageID] 
                 INNER JOIN pubissue a 
                         ON a.[PubEditionID] = b.[PubEditionID] 
          WHERE  a.notakereason IS NULL 
                 AND a.issuedate = @IssueDate 
                 AND b.[PublicationID] IN 
                     (SELECT DISTINCT id 
                      FROM   [dbo].[Fn_csvtotable](@PublicationList)) 
          UNION 
          SELECT b.descrip AS Publication,b.pubcode AS PubCode, 
                 a.editionname AS PubEdition 
                 ,NULL 
                 AS PubIssueID,b.[PublicationID] AS PublicationID, 
                 a.[PubEditionID] AS PubEditionID,a.[LanguageID] AS LanguageID 
                 , 
                 z.description AS Language,@IssueDate AS IssueDate 
          FROM   pubedition a 
                 INNER JOIN publication b 
                         ON b.[PublicationID] = a.[PublicationID] 
                 INNER JOIN [Language] z 
                         ON z.languageid = a.[LanguageID] 
          WHERE  a.[PublicationID] IN 
                 (SELECT DISTINCT id 
                  FROM   [dbo].[Fn_csvtotable](@PublicationList)) 
                 AND a.[DefaultInd] = 1 
                 AND (SELECT Count(*) 
                      FROM   pubissue x 
                             INNER JOIN pubedition y 
                                     ON y.[PublicationID] = a.[PublicationID] 
                                        AND x.[PubEditionID] = 
                                            y.[PubEditionID] 
                      WHERE  x.issuedate = @IssueDate) = 0 
          ORDER  BY publication 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_CouponBookPubIssueSelection: %d: %s',16,1,@error, 
                     @message 
                     , 
                     @lineNo); 
      END catch 
  END
