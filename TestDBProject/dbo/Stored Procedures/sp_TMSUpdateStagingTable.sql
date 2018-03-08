
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/24/2014 
-- Description:  Align the Quarter Hours and updates empty schedule program names 
-- Query : exec sp_TMSUpdateStagingTable  'D:\POCDemo\TMSData\sunday1.txt'
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_TMSUpdateStagingTable] 
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
		SELECT @ProgramScheduleRecCountBefore =COUNT([TVProgramScheduleID])
		FROM [TVProgramSchedule]
	
		   SET @Dated = (SELECT TOP 1 [MTAirDT] 
                        FROM   TempTMSSchedule) 

		  --- Inserting into mt_tv_program_schedule table   
		INSERT INTO [TVProgramSchedule]  
		SELECT	(select [MTProgID] from [ProgramMap] where [TMSSeqID]=TTS.[TMSSeqID]) AS MTProgramId,
			 	(select [TVStationID] from StationMapMaster where [TMSStationID]=TTS.[TMSStationID])  AS MTStationId,
				[MTAirDT],
				[TMSEpisodeID],
				[QtrScheduleID],
				SrcType

		from TempTMSSchedule TTS
		
                 

		 --Taking the count of MT Program schedule table after the update
		DECLARE @ProgramScheduleRecCountAfter INT
		SELECT @ProgramScheduleRecCountAfter =COUNT([TVProgramScheduleID])
		FROM [TVProgramSchedule]

		DECLARE @TMSRecoCount int
		SET @TMSRecoCount=@ProgramScheduleRecCountAfter-@ProgramScheduleRecCountBefore
		DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
		--updating the Final count from MT Program shcedule table to log table
		
		UPDATE TMSFileLogs SET FinalCount=@TMSRecoCount WHERE [FileName]=@FileName and [AirDT]=@Dated

	  COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(MAX), 
                  @LineNo  INT 

          SELECT @Error = ERROR_NUMBER(), 
                 @Message = ERROR_MESSAGE(), 
                 @LineNo = ERROR_LINE() 

          RAISERROR ('sp_TMSUpdateStagingTable: %d: %s',16,1,@Error,@Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;