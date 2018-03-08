
-- ============================================= 
-- AUTHOR:    Ramesh Bangi
-- CREATE DATE: 05/07/2015 
-- DESCRIPTION:  INSERT Schedule
-- QUERY : EXEC [usp_InsertSchedule]
-- ============================================= 

CREATE PROC [dbo].[usp_InsertSchedule]

@Id VARCHAR(200),
@Type VARCHAR(200),
@CurrentScheduleType VARCHAR(200),
@ProcessName VARCHAR(200),
@StartDate datetime,
@EndDate datetime,
@OccurTime VARCHAR(200),
@DayOfTheWeek VARCHAR(1000),
@IsEnabled bit,
@CreatedBy VARCHAR(200),
@ModifiedBy VARCHAR(200)

AS 
  BEGIN 
      SET NOCOUNT ON 
		BEGIN TRY 
		Declare @processgroupname varchar(200)
		Declare @ProcessId varchar(200)
		if(@type = 'Job')
		begin
			set @processgroupname = (select distinct([ProcessGroup]) from [ProcessInventory] A inner join [Job] B on A.[ProcessCODE] = B.[ProcessCODE] where [JobCODE] = @Id)
		end
		else if(@type = 'Job Package')
		begin
			set @processgroupname = (select distinct([ProcessGroup]) from [ProcessInventory] A inner join [JobPackage] B on A.[ProcessCODE] = B.[ProcessCODE] where [JobPackageCODE] = @Id)
		end
		else if(@type = 'Job Step')
		begin
			set @processgroupname = (select distinct([ProcessGroup]) from [ProcessInventory] A inner join [JobStep] B on A.[ProcessCODE] = B.[ProcessCODE] where [JobStepCODE] = @Id)
		end
		
			if exists(select [ProcessID] from scheduler where [ProcessID] = @Id)
				begin
				-- Update existing Schedule, if the process exist in scheduler table
				Update [DBO].[scheduler] set 
						[StartDT] = @StartDate,
						[EndDT] = @EndDate,
						[OccurrenceTime] = @OccurTime,
						DayOfTheWeek = @DayOfTheWeek,
						[Enabled] = @IsEnabled,
						[ModifiedDT] = getdate(),
						[ModifiedByID] = @ModifiedBy
				where [ProcessID] = @Id
				end 
			else
			begin
			-- Inserting new Schedule if the process is not exist in scheduler table
					INSERT INTO [DBO].[scheduler]
						(ProcessGroup,
						[ProcessID],
						Type,
						CurrentScheduleType,
						ProcessName,
						[StartDT],
						[EndDT],
						[OccurrenceTime],
						DayOfTheWeek,
						[Enabled],
						[CreatedDT],
						[CreatedByID])
					VALUES
						(@processgroupname,
						 @Id,
						 @Type,
						 @CurrentScheduleType,
						 @ProcessName,
						 @StartDate,
						 @EndDate,
						 @OccurTime,
						 @DayOfTheWeek,
						 @IsEnabled,
						 getdate(),
						 @CreatedBy)
			end
				-- Updating Current Schedule Type (Job or job Package or Job Step)
				Update [DBO].[scheduler] set CurrentScheduleType = @CurrentScheduleType
		END TRY 
			  BEGIN CATCH 
				DECLARE @ERROR   INT, 
                    @MESSAGE VARCHAR(4000), 
                    @LINENO  INT 

				SELECT @ERROR = ERROR_NUMBER(), 
						@MESSAGE = ERROR_MESSAGE(), 
						@LINENO = ERROR_LINE() 

				RAISERROR ('usp_InsertSchedule: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
			  END CATCH; 
	 END;