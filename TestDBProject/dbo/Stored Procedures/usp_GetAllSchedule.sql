
-- ============================================= 
-- AUTHOR:    Murali Jaganathan
-- CREATE DATE: 05/08/2015 
-- DESCRIPTION:  get current schedule details for Spend and Ingestion
-- QUERY : EXEC [usp_GetAllSchedule]
-- ============================================= 

CREATE PROC [dbo].[usp_GetAllSchedule]

AS 
  BEGIN 
      SET NOCOUNT ON 
		BEGIN TRY 
				begin
				select * from scheduler --where isenabled = 1
				end 
		END TRY 
			  BEGIN CATCH 
				DECLARE @ERROR   INT, 
                    @MESSAGE VARCHAR(4000), 
                    @LINENO  INT 

				SELECT @ERROR = ERROR_NUMBER(), 
						@MESSAGE = ERROR_MESSAGE(), 
						@LINENO = ERROR_LINE() 

				RAISERROR ('usp_GetAllSchedule: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;
