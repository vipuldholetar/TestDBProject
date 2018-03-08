
-- =============================================  
-- Author:    SURESH N  
-- Create date: 28/01/2016  
-- Description:    
-- Exec      : EXEC sp_CreatingPubIssueInSearchandMap  22,20,'01/25/16',29712041  
-- =============================================  
CREATE PROCEDURE Sp_creatingpubissueinsearchandmap (@PublicationID INT, 
@PubEditionID INT,@issueDate VARCHAR(30),@UserID INTEGER) 
AS 
  BEGIN 
      -- SET NOCOUNT ON added to prevent extra result sets from  
      -- interfering with SELECT statements.  
      SET nocount ON; 

      DECLARE @PubIssueID INT 

      BEGIN try 
          INSERT INTO pubissue 
                      ([EnvelopeID],[SenderID],[PubEditionID], 
                       [ShippingMethodID], 
                       [PackageTypeID], 
                       issuedate,trackingnumber,printedweight,actualweight, 
                       packageassignment,cpnoccurrenceid,status,fk_pubsection, 
                       createdtm, 
                       createby) 
          SELECT NULL,4752,@PubEditionID,NULL,NULL,@issueDate,NULL,NULL,NULL, 
                 NULL, 
                 NULL 
                 , 
                 'In Progress',NULL,Getdate(),@UserID; 

          --we are passing sender id as static where it is not an Null  
          SET @PubIssueID=Scope_identity() 

          SELECT @PubIssueID AS PubIssueID 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_CreatingPubIssueInSearchandMap: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch 
  END
