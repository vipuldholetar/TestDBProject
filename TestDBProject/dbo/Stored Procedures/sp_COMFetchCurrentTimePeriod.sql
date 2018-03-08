
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/17/2015  
-- Description:  Fetch current time period from the table COMS_TIME_PERIODS
-- Query : exec [sp_COMFetchCurrentTimePeriod]  
-- =============================================  
CREATE PROC [dbo].[sp_COMFetchCurrentTimePeriod] 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          Select [COMTimePeriodID] from [COMTimePeriod] where DATEDIFF(day,[StartDT],getdate()) IN
		(Select MAX(DATEDIFF(day,[StartDT],GETDATE())) DiffYear from [COMTimePeriod] WHERE [IngestionComplete]='0')  

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_COMFetchCurrentTimePeriod]: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH; 
  END; 

-----------------------------------------------------------
