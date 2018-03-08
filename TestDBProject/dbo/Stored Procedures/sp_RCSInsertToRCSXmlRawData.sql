
-- =============================================   
-- Author:    Govardhan   
-- Create date: 03/23/2015   
-- Description:  Insert the data to the RCSRawData table.  
-- Query :   
/*  
exec sp_RCSInsertToRCSXmlRawData '', 
*/ 
-- =============================================   
CREATE PROCEDURE [sp_RCSInsertToRCSXmlRawData] (@RCSData dbo.RCSXmlData 
readonly, 
                                                       @BatchId INT) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          INSERT INTO RCSRawData 
                      (MediaType, 
                       [StationID], 
                       [StartDT], 
                       [EndDT], 
                       [TitleID], 
                       [AcID], 
                       [MetaTitleID], 
                       [CreativeID], 
                       [PaID], 
                       [ClassID], 
                       [Action], 
                       [SeqID], 
                       [BatchID], 
                       [ParsedDT], 
                       IngestionStatus, 
                       [CreatedDT], 
                       [CreatedByID], 
                       ClassName, 
                       AcctName, 
                       AdvName) 
          SELECT MediaType, 
                 StationId, 
                 StartTime, 
                 EndTime, 
                 TitleId, 
                 AcId, 
                 MetaTitleId,
                 CreativeId, 
                 PaId, 
                 ClassId, 
                 [Action], 
                 SeqId, 
                 @BatchId, 
                 Getdate(), 
                 0, 
                 Getdate(), 
                 1, 
                 ClassName, 
                 AcctName, 
                 AdvName 
          FROM   @RCSData 

          UPDATE RCSXmlDocs 
          SET    ParsedStatus = 1 
          WHERE  [RCSXmlDocsID] = @BatchId 

          SELECT Count(*)[ImportedRecCount] 
          FROM   RCSRawData 
          WHERE  [BatchID] = @BatchId 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSInsertToRCSXmlRawData: %d: %s',16,1,@Error,@Message, 
                     @LineNo 
          ); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
