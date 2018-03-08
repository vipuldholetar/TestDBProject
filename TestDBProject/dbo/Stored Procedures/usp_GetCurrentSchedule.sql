
-- ============================================= 
-- AUTHOR:    Ramesh Bangi
-- CREATE DATE: 05/08/2015 
-- DESCRIPTION:  get current schedule details for Spend and Ingestion
-- QUERY : EXEC [usp_GetCurrentSchedule] 'process group'
-- ============================================= 

CREATE PROC [dbo].[usp_GetCurrentSchedule]

@processgroup varchar(200)

AS 
  BEGIN 
      SET NOCOUNT ON 
		BEGIN TRY 
				begin
				select  ProcessGroup,
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
						where processgroup=@processgroup
						and [type] = CurrentScheduleType
				end 
		END TRY 
			  BEGIN CATCH 
				DECLARE @ERROR   INT, 
                    @MESSAGE VARCHAR(4000), 
                    @LINENO  INT 

				SELECT @ERROR = ERROR_NUMBER(), 
						@MESSAGE = ERROR_MESSAGE(), 
						@LINENO = ERROR_LINE() 

				RAISERROR ('usp_GetSchedule: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;