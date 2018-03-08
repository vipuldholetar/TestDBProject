 -- =============================================  

-- Author:    Govardhan  

-- Create date: 2/20/2015  

-- Description:  Update Status Of Time Period after processing .

-- Query : exec [sp_COMUpdateTimePeriodStatus]  

-- =============================================  

CREATE PROC [dbo].[sp_COMUpdateTimePeriodStatus] 
@chvTimePeriod varchar(25)
AS 

  BEGIN 

      SET NOCOUNT ON 



      BEGIN TRY 

      updATE [COMTimePeriod] SET [IngestionComplete]=1 where [COMTimePeriodID]=convert(int,@chvTimePeriod)

      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('sp_COMUpdateTimePeriodStatus: %d: %s',16,1,@error,@message,@lineNo); 

      END CATCH; 

  END; 
---------------------------------------------------------------
