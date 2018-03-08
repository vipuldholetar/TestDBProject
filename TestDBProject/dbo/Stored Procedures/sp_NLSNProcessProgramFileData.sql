
-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 11/03/2015   
-- Description: Insert spot files data into database tables.  
-- Query :   
/*  
drop procedure sp_NLSNProcessProgramFileData
*/ 
-- =============================================  

CREATE PROCEDURE [dbo].[sp_NLSNProcessProgramFileData] (@NLSNTSData dbo.NLSNTSData readonly, @NLSNPFData dbo.NLSNPFData readonly) 
AS 
  BEGIN 
     -- SET nocount ON; 
      BEGIN TRY 
        BEGIN TRANSACTION 
		

		COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSNProcessProgramFileData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;
