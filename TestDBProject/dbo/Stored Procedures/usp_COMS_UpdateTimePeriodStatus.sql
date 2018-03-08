 -- =============================================  

-- Author:    Govardhan  

-- Create date: 2/20/2015  

-- Description:  Update Status Of Time Period after processing .

-- Query : exec [usp_COMS_UpdateTimePeriodStatus]  

-- =============================================  

CREATE PROC [dbo].[usp_COMS_UpdateTimePeriodStatus] 
@chvTimePeriod varchar(25)
AS 

  BEGIN 

      SET NOCOUNT ON 



      BEGIN TRY 

      updATE COMS_TIME_PERIODS SET ingestioncomplete=1 where timeperiodid=convert(int,@chvTimePeriod)

      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('usp_COMS_FetchActiveWebsites: %d: %s',16,1,@error,@message,@lineNo); 

      END CATCH; 

  END;
