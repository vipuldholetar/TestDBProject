-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/24/2014 
-- Description:  Align the Quarter Hours and updates empty schedule program names 
-- Query : exec sp_TMSUpdateTempSchedule 
-- ============================================= 
CREATE PROC [dbo].[sp_TMSUpdateTempSchedule] 

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
				 TT.[ProgID], 
                 ts.[TMSTvStationID], 
                 [ProgAirDT], 
                 ProgStartTime, 
                 ProgDuration, 
                 [ProgEpisodeID],
				 CASE
						When DATEPART(HOUR, Cast(Cast([ProgAirDT] AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(ProgStartTime, 0, 3) + ':' 
							 + Substring(ProgStartTime, 3, 3) + 'M') AS DATETIME)) between 0 and 5
						then         
							DateAdd(Day,1,Cast(Cast([ProgAirDT] AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(ProgStartTime, 0, 3) + ':' 
							 + Substring(ProgStartTime, 3, 3) + 'M') AS DATETIME))
						else
							Cast(Cast([ProgAirDT] AS DATE) AS DATETIME) + Cast(CONVERT(TIME, Substring(ProgStartTime, 0, 3) + ':' 
							 + Substring(ProgStartTime, 3, 3) + 'M') AS DATETIME)
						end
				 AS 
                 ProgramStartTime,
				 ProgSrcType ,
				 ProgTMSChannel
          INTO   #ConcatDateAndTime 
          FROM   TempTranslation TT 
                 INNER JOIN [TMSTvStation] ts 
                         ON Ts.TvStationName = tt.Src 
				 INNER JOIN [TMSTvProg] TPM 
                         ON TT.ProgName = TPM.ProgDescrip
	
		---Generating program end time by adding program start time and duration
		Select
			a.[SeqID],
			a.[ProgAirDT],
			a.ProgDuration,
			a.[ProgEpisodeID],
			a.[ProgID],
			a.ProgSrcType,
			a.ProgStartTime,
			a.ProgTMSChannel,
			a.ProgramStartTime,
			a.[TMSTvStationID],
			DATEADD(SECOND,-1, DATEADD(MINUTE,a.ProgDuration,a.ProgramStartTime)) as ProgramEndTime
		into
			#TempTMSTransalation
		from
			#ConcatDateAndTime a
	
		--- Manipulaitng starttime to align with quarter hours
		SELECT  [SeqID],
				[ProgID], 
				[TMSTvStationID], 
				[ProgAirDT], 
				ProgStartTime, 
				ProgDuration, 
				[ProgEpisodeID],
				ProgramStartTime,
				ProgramEndTime,
				DATEADD(MINUTE, ( DATEPART(MINUTE, CONVERT(VARCHAR(16), 
														ProgramStartTime, 
														121)) 
												% 15 ) *- 1, 
					CONVERT(VARCHAR(16), ProgramStartTime, 121 
					))
				AS NewProgramStartTime ,
				ProgSrcType,
				ProgTMSChannel

		INTO   #FinalTMSTransalation 
		FROM   #TempTMSTransalation 

		 SET @Dated = (SELECT TOP 1 [ProgAirDT] 
                        FROM   #FinalTMSTransalation) 

--Building temporary quarter hour table to accomodate porgrams ending on next day

 SET @Dated = (SELECT TOP 1 [ProgAirDT] 
                        FROM   #FinalTMSTransalation) 

          SELECT [QuarterHourID], 
                 [StartTime], 
                 [EndTime], 
                 [CreatedDT], 
                 CASE 
                   WHEN DATEPART(HOUR, [StartTime]) BETWEEN 0 AND 5 THEN 
                   DATEADD(DAY, 1, CAST(@Dated AS DATETIME) 
                                   + CAST([StartTime] AS DATETIME)) 
                   ELSE CAST(@Dated AS DATETIME) 
                        + CAST([StartTime] AS DATETIME) 
                 END AS quarterstarttime, 
                 CASE 
                   WHEN DATEPART(HOUR, [EndTime]) BETWEEN 0 AND 5 THEN 
                   DATEADD(DAY, 1, CAST(@Dated AS DATETIME) 
                                   + CAST([EndTime] AS DATETIME)) 
                   ELSE CAST(@Dated AS DATETIME) 
                        + CAST([EndTime] AS DATETIME) 
                 END AS QuarterEndTime 
          INTO   #TempQuarterHour 
          FROM   [QuarterHour] 

		 	   
		  --Align the Programs to quarter hours
		   SELECT ftt.[SeqID] AS TMSSeqId, 
			 	  ftt.[TMSTvStationID]  AS TMSStationId, 
				  FTT.[ProgAirDT], 
                  FTT.[ProgEpisodeID], 
                  TQH.[ScheduleID],
				  ftt.ProgSrcType
                  into #UpdateSource
          FROM   #FinalTMSTransalation FTT 
                 INNER JOIN #TempQuarterHour TQH 
                        ON TQH.QuarterStartTime BETWEEN 
                           FTT.NewProgramStartTime AND FTT.ProgramEndTime
          ORDER  BY FTT.[ProgID] 

		  INSERT INTO tempTMSSchedule 
		  SELECT  TMSSeqId,
				TMSStationId,
				[ProgAirDT],
				[ProgEpisodeID],
				[ScheduleID],
				CASE  
					WHEN (SELECT c.Dma
					  FROM   StationMapMaster a,[TVStation] c
					  WHERE  a.[TMSStationID] =us.TMSStationId and c.[TVStationID]=a.[TVStationID])='CAB' THEN
					  (select MTStationCode FROM   StationMapMaster a,[TVStation] c
					  WHERE  a.[TMSStationID] = us.TMSStationId and c.[TVStationID]=a.[TVStationID] ) 
				   WHEN ProgSrcType ='N' THEN 
				   (select NetworkAffiliation FROM   StationMapMaster a,[TVStation] c
					  WHERE  a.[TMSStationID] = us.TMSStationId and c.[TVStationID]=a.[TVStationID] ) 
                   WHEN ProgSrcType='S' THEN 'SYN' 
                   WHEN ProgSrcType='L' THEN 'LOC' 
				   
                 END   AS SourceType

		from #UpdateSource us

		COMMIT TRANSACTION 
	END try 

	BEGIN catch 
		DECLARE @Error   INT, 
		@Message VARCHAR(MAX), 
		@LineNo  INT 

		SELECT @Error = ERROR_NUMBER(), 
		@Message = ERROR_MESSAGE(), 
		@LineNo = ERROR_LINE() 

		RAISERROR ('sp_TMSUpdateTempSchedule: %d: %s',16,1,@Error,@Message, 
			@LineNo); 

		ROLLBACK TRANSACTION 
	END catch; 
END;