-- ============================================= 
-- AUTHOR:    Murali Jaganathan
-- CREATE DATE: 05/08/2015 
-- DESCRIPTION:  get Schedule details for Spend and Ingestion
-- QUERY : EXEC [usp_GetScheduleDetails]
-- ============================================= 

CREATE PROC [dbo].[usp_GetScheduleDetails]

@processId varchar(200)
AS 
  BEGIN 
      SET NOCOUNT ON 
		BEGIN TRY 
				begin
				select  ProcessGroup,
						[ProcessID],
						Type,
						CurrentScheduleType,
						ProcessName,
						[StartDT] StartDate,
						[EndDT] EndDate,
						[OccurrenceTime],
						DayOfTheWeek,
						[Enabled],
						[CreatedDT],
						[CreatedByID],
						[ModifiedDT],
						[ModifiedByID] 
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

				RAISERROR ('usp_GetScheduleDetails: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;