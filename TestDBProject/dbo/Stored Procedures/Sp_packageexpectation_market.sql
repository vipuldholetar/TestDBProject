-- ===========================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   01/19/2016  
-- Description           :   This stored procedure is used to Get Data for "Package Expectation - Package Received" Report Dataset
-- Execution Process     : [dbo].[sp_PackageExpectation_Market]   
-- Updated By            :   
-- ============================================================================================
CREATE PROCEDURE [dbo].[Sp_packageexpectation_market] 
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
          SELECT DISTINCT [Descrip],[MarketID] 
          FROM   [Market] order by [Descrip]
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
