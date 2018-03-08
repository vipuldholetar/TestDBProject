-- ===========================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   01/19/2016  
-- Description           :   This stored procedure is used to Get Data for Package Expectation - Location  Data
-- Execution Process     : [dbo].[sp_PackageExpectation_Location]   
-- Updated By            :   
-- ============================================================================================
CREATE PROCEDURE [dbo].[Sp_packageexpectation_location] 
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
          SELECT DISTINCT [Code].InternalDescrip, [Code].Descrip
          FROM   [user] 
                 INNER JOIN [Code] 
                         ON [user].LocationID = [Code].CodeId and [Code].CodeTypeID = 8
      END try 
      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 
          RAISERROR ('[sp_PackageExpectation_Location]: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch 
  END