
-- =============================================  
-- Author:    Nagarjuna  
-- Create date: 2/17/2015  
-- Description:  Fetch current time period from the table COMS_TIME_PERIODS
-- Query : exec [usp_COMS_FetchCurrentTimePeriod]  
-- =============================================  
CREATE PROC [dbo].[usp_COMS_FetchCurrentTimePeriod] 
AS 
  BEGIN 
      SET NOCOUNT ON 

      BEGIN TRY 
          Select TimePeriodId from COMS_TIME_PERIODS where DATEDIFF(day,TimePeriod_StartDate,getdate()) IN
		(Select MAX(DATEDIFF(day,TimePeriod_StartDate,GETDATE())) DiffYear from COMS_TIME_PERIODS WHERE IngestionComplete='0')  

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_COMS_FetchCurrentTimePeriod: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH; 
  END;
