-- ============================================= 
-- AUTHOR:    Ramesh Bangi
-- CREATE DATE: 05/08/2015 
-- DESCRIPTION:  Deletes Schedule details for Spend and Ingestion
-- QUERY : EXEC [usp_DeleteScheduleDetails]
-- ============================================= 

CREATE PROC [dbo].[usp_DeleteScheduleDetails]

@processId varchar(200)
AS 
  BEGIN 
      SET NOCOUNT ON 
		BEGIN TRY 
				begin
				delete 
						from scheduler 
						where [ProcessID] = @processId
				end 
		END TRY 
			  BEGIN CATCH 
				DECLARE @ERROR   INT, 
                    @MESSAGE VARCHAR(4000), 
                    @LINENO  INT 

				SELECT @ERROR = ERROR_NUMBER(), 
						@MESSAGE = ERROR_MESSAGE(), 
						@LINENO = ERROR_LINE() 

				RAISERROR ('usp_DeleteScheduleDetails: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;
