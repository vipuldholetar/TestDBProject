
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/24/2014 
-- Description:  Align the Quarter Hours and updates empty schedule program names 
-- Query : exec usp_TMS_08_UpdateTempSchedule 
-- ============================================= 
CREATE PROC [dbo].[usp_TMS_08_UpdateTempSchedule] 

AS 
DECLARE @Dated DATETIME 
BEGIN 
	SET NOCOUNT ON
	BEGIN try 
		BEGIN TRANSACTION 
			--- Retreiving TMS transaltion data and merging the date and the start time to get it in datetime format for further processing   
          --- if the duration is beyond 12 am then prog_air_dt is incremented by 1
		  --- (for ref : airdate is 1/1/2014 and start time is 02:00 then the prog_air_dt is changed to 1/2/2014).
		 truncate table tempTMSSchedule
		  SELECT TT.[SeqID],
				 TT.prog_id, 
                 ts.tv_station_id, 
                 prog_air_dt, 
                 prog_start_time, 
                 prog_duration, 
                 prog_episode_id,
				 CASE
						When DATEPART(HOUR, Cast(Cast(prog_air_dt AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(prog_start_time, 0, 3) + ':' 
							 + Substring(prog_start_time, 3, 3) + 'M') AS DATETIME)) between 0 and 5
						then         
							DateAdd(Day,1,Cast(Cast(prog_air_dt AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(prog_start_time, 0, 3) + ':' 
							 + Substring(prog_start_time, 3, 3) + 'M') AS DATETIME))
						else
							Cast(Cast(prog_air_dt AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(prog_start_time, 0, 3) + ':' 
							 + Substring(prog_start_time, 3, 3) + 'M') AS DATETIME)
						end
				 AS 
                 programstarttime,
				 prog_source_type ,
				 PROG_TMS_CHANNEL
          INTO   #concatDateandTime 
          FROM   TempTranslation TT 
                 INNER JOIN tms_tv_station ts 
                         ON Ts.tv_station_name = tt.SOURCE 
				 INNER JOIN tms_tv_prog_mst TPM 
                         ON TT.prog_name = TPM.prog_desc  
	
		---Generating program end time by adding program start time and duration
		Select
			a.[SeqID],
			a.PROG_AIR_DT,
			a.PROG_DURATION,
			a.PROG_EPISODE_ID,
			a.PROG_ID,
			a.PROG_SOURCE_TYPE,
			a.PROG_START_TIME,
			a.PROG_TMS_CHANNEL,
			a.programstarttime,
			a.TV_STATION_ID,
			DATEADD(SECOND,-1, DATEADD(MINUTE,a.PROG_DURATION,a.programstarttime)) as programendtime
		into
			#temptmstransalation
		from
			#concatDateandTime a
	
		--- Manipulaitng starttime to align with quarter hours
		SELECT  [SeqID],
				prog_id, 
				tv_station_id, 
				prog_air_dt, 
				prog_start_time, 
				prog_duration, 
				prog_episode_id,
				programstarttime,
				programendtime,
				DATEADD(MINUTE, ( DATEPART(MINUTE, CONVERT(VARCHAR(16), 
														programstarttime, 
														121)) 
												% 15 ) *- 1, 
					CONVERT(VARCHAR(16), programstarttime, 121 
					))
				AS newprogramstarttime ,
				prog_source_type,
				PROG_TMS_CHANNEL

		INTO   #finaltmstransalation 
		FROM   #temptmstransalation 

		 SET @Dated = (SELECT TOP 1 prog_air_dt 
                        FROM   #finaltmstransalation) 

--Building temporary quarter hour table to accomodate porgrams ending on next day

 SET @Dated = (SELECT TOP 1 prog_air_dt 
                        FROM   #finaltmstransalation) 

          SELECT [qtr_schedule_id], 
                 [qtr_start_time], 
                 [qtr_end_time], 
                 [create_dt], 
                 CASE 
                   WHEN DATEPART(HOUR, qtr_start_time) BETWEEN 0 AND 5 THEN 
                   DATEADD(DAY, 1, CAST(@Dated AS DATETIME) 
                                   + CAST(qtr_start_time AS DATETIME)) 
                   ELSE CAST(@Dated AS DATETIME) 
                        + CAST(qtr_start_time AS DATETIME) 
                 END AS quarterstarttime, 
                 CASE 
                   WHEN DATEPART(HOUR, qtr_end_time) BETWEEN 0 AND 5 THEN 
                   DATEADD(DAY, 1, CAST(@Dated AS DATETIME) 
                                   + CAST(qtr_end_time AS DATETIME)) 
                   ELSE CAST(@Dated AS DATETIME) 
                        + CAST(qtr_end_time AS DATETIME) 
                 END AS quarterendtime 
          INTO   #tempquarterhour 
          FROM   quarter_hours 

		 	   
		  --Align the Programs to quarter hours
		   SELECT ftt.[SeqID] AS TMS_SEQ_ID, 
			 	  ftt.TV_STATION_ID  AS TMS_STATION_ID, 
				  FTT.prog_air_dt, 
                  FTT.prog_episode_id, 
                  TQH.qtr_schedule_id,
				  ftt.prog_source_type
                  into #updatesource
          FROM   #finaltmstransalation FTT 
                 INNER JOIN #tempquarterhour TQH 
                        ON TQH.quarterstarttime BETWEEN 
                           FTT.newprogramstarttime AND FTT.programendtime
          ORDER  BY FTT.prog_id 

		  INSERT INTO tempTMSSchedule 
		  SELECT  TMS_SEQ_ID,
				TMS_STATION_ID,
				prog_air_dt,
				prog_episode_id,
				qtr_schedule_id,
				CASE  
					WHEN (SELECT c.DMA
					  FROM   station_map a,TV_STATIONS c
					  WHERE  a.tms_station_id =us.TMS_STATION_ID and c.MT_STATION_ID=a.MT_STATION_ID)='CAB' THEN
					  (select MT_STATION_CODE FROM   station_map a,TV_STATIONS c
					  WHERE  a.tms_station_id = us.TMS_STATION_ID and c.MT_STATION_ID=a.MT_STATION_ID ) 
				   WHEN prog_source_type ='N' THEN 
				   (select network_affiliation FROM   station_map a,TV_STATIONS c
					  WHERE  a.tms_station_id = us.TMS_STATION_ID and c.MT_STATION_ID=a.MT_STATION_ID ) 
                   WHEN prog_source_type='S' THEN 'SYN' 
                   WHEN prog_source_type='L' THEN 'LOC' 
				   
                 END   AS SOURCE_TYPE

		from #updatesource us

		COMMIT TRANSACTION 
	END try 

	BEGIN catch 
		DECLARE @error   INT, 
		@message VARCHAR(MAX), 
		@lineNo  INT 

		SELECT @error = ERROR_NUMBER(), 
		@message = ERROR_MESSAGE(), 
		@lineNo = ERROR_LINE() 

		RAISERROR ('usp_TMS_08_UpdateTempSchedule: %d: %s',16,1,@error,@message, 
			@lineNo); 

		ROLLBACK TRANSACTION 
	END catch; 
END;
