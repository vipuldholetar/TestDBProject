CREATE PROCEDURE [dbo].[sp_TVInsertRawMasterData]
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
	  BEGIN TRANSACTION 

DECLARE @Weekdays TABLE
(
  [RowId] [INT] IDENTITY(1,1) NOT NULL,
  [PK_Id] [bigint],
  [CaptureStationCode] varchar(200),
  [EffectiveStartDate] datetime,
  [EffectiveEndDate] datetime,
  [StartTime] TIME,
  [EndTime] TIME,
  [TotalRowCount] INT,
  [WeekDays] varchar(10) null
)

DECLARE @StationMapping TABLE
(
[RowId] [INT] IDENTITY(1,1) NOT NULL,
[PK_Id] [bigint],
WEEKDAYS varchar(10),
CAPTURESTATIONCODE varchar(200),
EFFECTIVESTARTDATE datetime,
EFFECTIVEENDDATE datetime,
STARTTIME TIME,
ENDTIME TIME 
  
)

DECLARE @WeekdaysSplit TABLE
(
	[RowId] [INT] IDENTITY(1,1) NOT NULL,
	[Weekday] [VARCHAR] (200),
	[EffectiveStartDate] DATETIME,
	[StartTime] TIME,
	[EndTime] TIME 
)

DECLARE @RowCount  INT, 
        @TotalRows  INT,
		@PK_Id	 INT,				
		@StartTime TIME,
		@EndTime TIME,
		@RowSplitCount  INT, 
        @TotalSplitRows  INT,
		@WeekDay VARCHAR(5),
		@Monday INT,
		@Tuesday INT,
		@Wednesday INT,
		@Thursday INT,
		@Friday INT,
		@Saturday INT,
		@Sunday INT,
		@FinalWeekDays VARCHAR(10)

SELECT @RowCount = 1, 
       @TotalRows = 0,
	   @RowSplitCount = 1,
	   @TotalSplitRows = 0
	   

INSERT INTO @Weekdays
(
[PK_Id],
[CaptureStationCode],
[EffectiveStartDate],
[EffectiveEndDate],
[StartTime],
[EndTime],
[TotalRowCount]
)
SELECT 
SM.[TVStationID],
rs.[CaptureStationCode],
rs.[EffectiveStartDT],
rs.[EffectiveEndDT],
cast(RS.[StartDT] as time),
cast(RS.[EndDT] as time),
COUNT(*) AS TOTALROWCOUNT
FROM [TVRecordingScheduleBA] RS
INNER JOIN [TVStation] SM ON SM.StationShortName = RS.[MTStationID]
GROUP BY SM.[TVStationID],RS.[CaptureStationCode],RS.[EffectiveStartDT],RS.[StartDT],RS.[EndDT],rs.[EffectiveEndDT]
ORDER BY SM.[TVStationID],RS.[CaptureStationCode],RS.[EffectiveStartDT],RS.[StartDT],RS.[EndDT],rs.[EffectiveEndDT]

--SELECT * FROM @Weekdays

INSERT INTO @StationMapping
(
[PK_Id],
WEEKDAYS,
CAPTURESTATIONCODE,
EFFECTIVESTARTDATE,
EFFECTIVEENDDATE, 
STARTTIME,
ENDTIME 
)
SELECT 
--FK_MTSTATIONID,
SM.[TVStationID],
RS.[Weekdays],
RS.[CaptureStationCode],
RS.[EffectiveStartDT],
RS.[EffectiveEndDT],
RS.[StartDT],
RS.[EndDT]
FROM [TVRecordingScheduleBA] RS
INNER JOIN [TVStation] SM ON SM.StationShortName = RS.[MTStationID]


SELECT @TotalRows = COUNT(*) FROM @Weekdays
--SET @TotalRows =  10

WHILE @TotalRows > 0
BEGIN
	SELECT @TotalRows = @TotalRows - 1

	SELECT @Monday = 0,
	   @Tuesday = 0,
	   @Wednesday = 0,
	   @Thursday = 0,
	   @Friday = 0,
	   @Saturday = 0,
	   @Sunday = 0

	SELECT @PK_Id = PK_Id FROM @Weekdays WHERE [RowId] = @RowCount
	SELECT @StartTime = StartTime FROM @Weekdays WHERE [RowId] = @RowCount
	SELECT @EndTime = EndTime FROM @Weekdays WHERE [RowId] = @RowCount

	INSERT INTO @WeekdaysSplit
	(
	[Weekday],
	[EffectiveStartDate],
	[StartTime],
	[EndTime]
	)
	SELECT WeekDays, [EffectiveStartDate], [StartTime], [EndTime]
	FROM @StationMapping 
	WHERE  [PK_Id]= @PK_Id AND STARTTIME = @StartTime and ENDTIME = @EndTime

	--select * from @WeekdaysSplit

	SELECT @TotalSplitRows = COUNT(*) FROM @WeekdaysSplit

	WHILE @TotalSplitRows > 0
	BEGIN
		SELECT @TotalSplitRows = @TotalSplitRows - 1
			SELECT @WeekDay = [Weekday] FROM @WeekdaysSplit WHERE [RowId] = @RowSplitCount;
			--SELECT CASE 
			--	WHEN @WeekDay = 'M' THEN @Monday + 1
			--	WHEN @WeekDay = 'T' THEN @Tuesday + 1
			--	WHEN @WeekDay = 'W' THEN @Wednesday + 1
			--	WHEN @WeekDay = 'H' THEN @Thursday + 1
			--	WHEN @WeekDay = 'F' THEN @Friday + 1
			--	WHEN @WeekDay = 'S' THEN @Saturday + 1
			--	WHEN @WeekDay = 'U' THEN @Sunday + 1
			--END
			IF(@WeekDay = 'M')
			BEGIN
				SET @Monday = @Monday + 1
			END
			IF(@WeekDay = 'T')
			BEGIN
				SET @Tuesday = @Tuesday + 1
			END
			IF(@WeekDay = 'W')
			BEGIN
				SET @Wednesday = @Wednesday + 1
			END
			IF(@WeekDay = 'H')
			BEGIN
				SET @Thursday = @Thursday + 1
			END
			IF(@WeekDay = 'F')
			BEGIN
				SET @Friday = @Friday + 1
			END
			IF(@WeekDay = 'S')
			BEGIN
				SET @Saturday = @Saturday + 1
			END
			IF(@WeekDay = 'U')
			BEGIN
				SET @Sunday = @Sunday + 1
			END
			SET @FinalWeekDays = CONCAT(@Monday, @Tuesday, @Wednesday, @Thursday, @Friday, @Saturday, @Sunday)			
		SELECT @RowSplitCount = @RowSplitCount + 1
	END

	UPDATE @Weekdays SET [WeekDays] = @FinalWeekDays WHERE [RowId] = @RowCount
	DELETE FROM @WeekdaysSplit 
	--SELECT * FROM TVRecordingSchedule WHERE FK_MTStationId = @PK_Id AND CAST(StartTime AS TIME) between @StartTime AND @EndTime

	SELECT @RowCount = @RowCount + 1

END
	SELECT * FROM @Weekdays

	INSERT INTO TVRecordingSchedule
(
[TVStationID],
WeekDays,
CaptureStationCode,
[EffectiveStartDT],
[EffectiveEndDT],
[StartDT],
[EndDT]
)
SELECT 
PK_Id,
WEEKDAYS,
CAPTURESTATIONCODE,
EFFECTIVESTARTDATE,
EFFECTIVEENDDATE,
STARTTIME,
ENDTIME
FROM @Weekdays

select * from TVRecordingSchedule

	  COMMIT TRANSACTION 
	  END try 
      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVInsertRawMasterData: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;