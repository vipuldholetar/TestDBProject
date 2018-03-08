-- ============================================= 
-- AUTHOR:    Ramesh Bangi
-- CREATE DATE: 05/07/2015 
-- DESCRIPTION:  get Schedule details for Spend and Ingestion
-- QUERY : EXEC [usp_GetSchedule] '2015-05-19 00:00:00.000','2111','Spend Methodology',
--select * from scheduler
--delete from scheduler where type='Job Package'
-- ============================================= 

CREATE PROC [dbo].[usp_GetSchedule]

@endDate varchar(max),
@oocurTime varchar(max),
@processGroup varchar(200)

AS 
  BEGIN 
      SET NOCOUNT ON 
              BEGIN TRY 
                       Declare @scheduleType varchar(50)

                     if (EXISTS( SELECT  TYPE FROM scheduler WHERE TYPE='Job Step' and processgroup = @processGroup and  ([EndDT] > CAST(@endDate AS datetime) or ([EndDT]= CAST(@endDate AS datetime) and CAST(@oocurTime AS int) <=(SELECT Max(CAST(Item AS INTEGER)) FROM dbo.SplitString([OccurrenceTime], ',')) ))))
                           begin
                           select  ProcessGroup,
                                         [ProcessID],
                                         SC.Type,
                                         CurrentScheduleType,
                                         ProcessName,
                                         [StartDT],
                                         [EndDT],
                                         [OccurrenceTime],
                                         DayOfTheWeek,
                                         [Enabled],
                                         SC.[CreatedDT],
                                         [CreatedByID],
                                         [ModifiedDT],
                                         [ModifiedByID] 
                                         from scheduler SC INNER JOIN  [JobStep] JS
                                                                     ON SC.[ProcessID]=[JobStepCODE]
                                         where  processgroup = @processGroup
                                                                     and [Status]='Active'
                           end 
                           ELSE
                                  IF(EXISTS( SELECT  TYPE FROM scheduler WHERE TYPE='Job Package' and processgroup = @processGroup and  ([EndDT] > CAST(@endDate AS datetime) or ([EndDT]= CAST(@endDate AS datetime) and CAST(@oocurTime AS int) <=(SELECT Max(CAST(Item AS INTEGER)) FROM dbo.SplitString([OccurrenceTime], ',')) ))))
                                         BEGIN
                                         select  ProcessGroup,
                                         [ProcessID],
                                         SC.Type,
                                         CurrentScheduleType,
                                         ProcessName,
                                         [StartDT],
                                         [EndDT],
                                         [OccurrenceTime],
                                         DayOfTheWeek,
                                         [Enabled],
                                         SC.[CreatedDT],
                                         [CreatedByID],
                                         [ModifiedDT],
                                         [ModifiedByID] 
                                          from scheduler SC INNER JOIN  [JobPackage] JP
                                                                     ON SC.[ProcessID]=[JobPackageCODE]
                                         where  processgroup = @processGroup
                                                                     and [Status]='Active'
                                         END
                                         ELSE
                                                select  ProcessGroup,
                                         [ProcessID],
                                         SC.Type,
                                         CurrentScheduleType,
                                         ProcessName,
                                         [StartDT],
                                         [EndDT],
                                         [OccurrenceTime],
                                         DayOfTheWeek,
                                         [Enabled],
                                         [CreatedDT],
                                         [CreatedByID],
                                         [ModifiedDT],
                                         [ModifiedByID] 
                                          from scheduler SC INNER JOIN  [Job] JP
                                                                     ON SC.[ProcessID]=[JobCODE]
                                         where  processgroup = @processGroup
                                                                     and [Status]='Active'


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
