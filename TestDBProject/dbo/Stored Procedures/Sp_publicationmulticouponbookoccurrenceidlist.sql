
-- ===================================================================================================
-- Author            : Arun Nair  
-- Create date       : 01/29/2015  
-- Description       : Get Occurrences in MultiCoupon   
-- EXEC              :   
-- Updated By     :   
-- ====================================================================================================
CREATE PROCEDURE [dbo].[Sp_publicationmulticouponbookoccurrenceidlist] 
  --'2016-01-25','1',31800  
  @IssueDate VARCHAR(50),@Publicationlist VARCHAR(max),@AdID INT 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          SELECT Stuff((SELECT ', ' 
                               + CONVERT(NVARCHAR(max), 
                               [OccurrenceDetailPUB].[OccurrenceDetailPUBID] ) 
                        FROM   [OccurrenceDetailPUB] 
                               INNER JOIN pubissue 
                                       ON pubissue.[PubIssueID] = 
                                          [OccurrenceDetailPUB].[PubIssueID] 
                               INNER JOIN pubedition 
                                       ON pubedition.[PubEditionID] = 
                                          pubissue.[PubEditionID] 
                        --INNER JOIN  Publication ON Publication.PK_PublicationId=PubEdition.FK_PublicationID  
                        WHERE  pubissue.issuedate = @IssueDate 
                               AND pubedition.[PublicationID] IN 
                                   (SELECT DISTINCT id 
                                    FROM 
                                   [dbo].[Fn_csvtotable](@Publicationlist)) 
                               AND [OccurrenceDetailPUB] .[AdID] = @AdID 
                        ORDER  BY [OccurrenceDetailPUB].[OccurrenceDetailPUBID] ASC 
                        FOR xml path('')), 1, 2, '') AS OccurrenceIdlist 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_PublicationMultiCouponBookOccurrenceIdList]: %d: %s', 
                     16, 
                     1, 
                     @error,@message, 
                     @lineNo); 
      END catch 
  END
