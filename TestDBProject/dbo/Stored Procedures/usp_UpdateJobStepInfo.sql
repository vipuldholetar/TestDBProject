
-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Job Step Info
-- Query : exec usp_UpdateJobStepInfo
-- ============================================= 
CREATE PROC [dbo].[usp_UpdateJobStepInfo] @jobstepid varchar(20),@source varchar(200),@target varchar(200),@order varchar(20),@predecessor varchar(20)

AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 

	 -- Update Job Configuration

      Update [JobStep] set [Source]=@source,[Target]=@target,[Order]=@order,[Predecessor]=@predecessor where [JobStepCODE]=@jobstepid

      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_UpdateJobStepInfo: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;
