-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/24/2014 
-- Description:  Align the Quarter Hours and updates empty schedule program names 
-- Query : exec usp_TMS_10_UpdateStagingTable  'D:\POCDemo\TMSData\sunday1.txt'
-- ============================================= 
CREATE PROC [dbo].[usp_TMS_10_UpdateStagingTable] 
(
	@FilePath AS NVARCHAR(250)
)
AS 
    DECLARE @Dated DATETIME 

  BEGIN 
  set nocount on
      BEGIN try 
          BEGIN TRANSACTION 

         -- Get the TV_Program_Schedule table record count before inserting data from TMS Translation
		DECLARE @ProgramScheduleRecCountBefore INT
		SELECT @ProgramScheduleRecCountBefore =COUNT(MT_PROG_SCHEDULE_ID)
		FROM TV_PROGRAM_SCHEDULE
	
		   SET @Dated = (SELECT TOP 1 MtAirDT 
                        FROM   tempTMSSchedule) 

		  --- Inserting into mt_tv_program_schedule table   
		INSERT INTO TV_PROGRAM_SCHEDULE  
		SELECT	(select MT_PROG_ID from PROGRAM_MAP where TMS_SEQID=TTS.TMS_SEQ_ID) AS MT_PROGRAM_ID,
			 	(select MT_STATION_ID from STATION_MAP where TMS_STATION_ID=TTS.TMS_STATION_ID)  AS MT_STATION_ID,
				MT_AIR_DT,
				TMS_EPISODE_ID,
				QTR_SCHEDULE_ID,
				SOURCE_TYPE

		from tempTMSSchedule TTS
		
                 

		 --Taking the count of MT Program schedule table after the update
		DECLARE @ProgramScheduleRecCountAfter INT
		SELECT @ProgramScheduleRecCountAfter =COUNT(MT_PROG_SCHEDULE_ID)
		FROM TV_PROGRAM_SCHEDULE

		DECLARE @TMSRecoCount int
		SET @TMSRecoCount=@ProgramScheduleRecCountAfter-@ProgramScheduleRecCountBefore
		DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
		--updating the Final count from MT Program shcedule table to log table
		
		UPDATE TMS_FILE_LOGS SET MTFinalCount=@TMSRecoCount WHERE [FileName]=@FileName and AirDate=@Dated

	  COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(MAX), 
                  @lineNo  INT 

          SELECT @error = ERROR_NUMBER(), 
                 @message = ERROR_MESSAGE(), 
                 @lineNo = ERROR_LINE() 

          RAISERROR ('usp_TMS_10_UpdateStagingTable: %d: %s',16,1,@error,@message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
