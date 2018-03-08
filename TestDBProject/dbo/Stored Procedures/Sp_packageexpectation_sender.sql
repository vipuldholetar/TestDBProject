-- ===========================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   01/19/2016  
-- Description           :   This stored procedure is used to Get Data for "Package Expectation Sender"  Dataset
-- Execution Process     : [dbo].[sp_PackageExpectation_Sender]  
-- Updated By            :   
-- ============================================================================================
CREATE PROCEDURE [dbo].[Sp_packageexpectation_sender] 
AS 
  BEGIN 
      BEGIN try 
          SELECT DISTINCT [SenderID],NAME 
          FROM   sender order by name
      END try 
      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 
          RAISERROR ('[sp_PackageExpectation_Sender]: %d: %s',16,1,@error, 
                     @message 
                     , 
                     @lineNo); 
      END catch 
  END
