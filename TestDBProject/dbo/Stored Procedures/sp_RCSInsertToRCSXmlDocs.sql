
-- =============================================   
-- Author:    Govardhan   
-- Create date: 03/23/2015   
-- Description:  Insert the data to the RCSXMLDocs table.  
-- Query :   
/*  
exec sp_RCSInsertToRCSXmlDocs '15648381142',  
*/ 
-- =============================================   
CREATE PROCEDURE [sp_RCSInsertToRCSXmlDocs] (@BiggestSeq AS BIGINT, 
                                                    @RCSXMLData      AS XML, 
                                                    @RCSXmlNodeCount AS INT) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          INSERT INTO RCSXmlDocs 
                      (BiggestSeqForAirplayChange, 
                       RCSXmlDoc, 
                       ParsedStatus, 
                       XmlNodeCount, 
                       [CreatedDT], 
                       [CreatedByID]) 
          VALUES      (@BiggestSeq, 
                       @RCSXMLData, 
                       0, 
                       @RCSXmlNodeCount, 
                       Getdate(), 
                       1) 

          SELECT @@IdENTITY[BatchId]; 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSInsertToRCSXmlDocs: %d: %s',16,1,@Error,@Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
