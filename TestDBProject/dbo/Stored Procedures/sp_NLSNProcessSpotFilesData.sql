
-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 11/03/2015   
-- Description: Insert spot files data into database tables.  
-- Query :   
/*  
exec sp_NLSNProcessSpotFilesData '',  
drop procedure sp_NLSNProcessSpotFilesData
*/ 
-- =============================================  

CREATE PROCEDURE [dbo].[sp_NLSNProcessSpotFilesData] (@NLSNTSData dbo.NLSNTSData readonly, @NLSNPFData dbo.NLSNPFData readonly) 
AS 
  BEGIN 
     -- SET nocount ON; 
      BEGIN TRY 
        BEGIN TRANSACTION 

		DECLARE @MarketCode varchar(10)
		DECLARE @AirDate Datetime
		DECLARE @StartTime time
		DECLARE @IsMarketCodeExists bit
		
		DECLARE @Region varchar(50)

		DECLARE @NLSNRatingStationCodes TABLE
		(
		  RowId INT IDENTITY (1, 1), 
		  [MarketCode] VARCHAR(50),
		  [City] VARCHAR(50),
		  [StationCode] VARCHAR(50),
		  [StationName] VARCHAR(50)
		);

		DECLARE @NLSNNoStations TABLE
		(
			RowId INT IDENTITY (1, 1), 
			StationName varchar(50),
			IsTracked bit
		)

		DECLARE @NLSNRatingData TABLE
		(
		  StationCode VARCHAR(50), 
		  StartTime datetime,
		  EndTime datetime,
		  HouseHold BIGINT,
		  C2_5 BIGINT,
		  C6_11 BIGINT,
		  M12_14 BIGINT,	  
		  M15_17 BIGINT,
		  M18_20 BIGINT,
		  M21_24 BIGINT,
		  M25_34 BIGINT,
		  M35_49 BIGINT,
		  M50_54 BIGINT,
		  M55_64 BIGINT,
		  M65P BIGINT,
		  F12_14 BIGINT,
		  F15_17 BIGINT,
		  F18_20 BIGINT,
		  F21_24 BIGINT,
		  F25_34 BIGINT,
		  F35_49 BIGINT,
		  F50_54 BIGINT,
		  F55_64 BIGINT,
		  F65P BIGINT
		  )

		SELECT @MarketCode = Column3, @AirDate = Column10, @StartTime = Column13, @Region = Column7 FROM NLSNTSData WHERE COLUMN1 = '01'
		print(@MarketCode)
		PRINT(@Region)

        IF(EXISTS( select distinct NLSNDMACode from NLSNMarketStationMap where NLSNDMACode = @MarketCode))
		BEGIN
		--print(@IsMarketCodeExists)
		--IF(@IsMarketCodeExists = 1)
		--BEGIN
			INSERT INTO @NLSNRatingStationCodes
			(
				[MarketCode],
				[City],
				[StationCode],
				[StationName]
			)
			SELECT Column7, Column8, column9, column10
			from NLSNTSData
			where column1 = '02' and column7 = @MarketCode and Column8 LIKE '%' + RTRIM(LTRIM(@Region))+ '%'

			SELECT * FROM @NLSNRatingStationCodes
			
			INSERT INTO @NLSNNoStations
			(
				StationName,
				IsTracked
			)
			SELECT DISTINCT NLSC.[StationName], 0
			FROM @NLSNRatingStationCodes NLSC
			LEFT OUTER JOIN NLSNMarketStationMap NLSM ON NLSC.[StationName] = NLSM.[NLSNStationID]
			where NLSM.[NLSNStationID] IS NULL

			SELECT * FROM @NLSNNoStations

			--INSERT INTO NLSNMarketStationMap
			--(
			--	NLSNDMACode,
			--	NLSNStationId,
			--	IsTracked,
			--	CreatedDate,
			--	CreatedBy
			--)
			SELECT  @MarketCode, StationName, IsTracked, GETDATE(), 1
			FROM @NLSNNoStations			

			INSERT INTO @NLSNRatingData
			(
				StationCode,
				StartTime,
				EndTime,
				HouseHold,
				C2_5,
				C6_11, 
				M12_14,
				M15_17,
				M18_20,
				M21_24,
				M25_34,
				M35_49,
				M50_54,
				M55_64,
				M65P,
				F12_14,
				F15_17,
				F18_20,
				F21_24,
				F25_34,
				F35_49,
				F50_54,
				F55_64,
				F65P
			)
			SELECT Column2, 
			Column4, 
			Column4, 
			Column6, 
			Column7, 
			Column8, 
			Column9, 
			Column10, 
			Column11, 
			Column12, 
			Column13, 
			Column14, 
			Column15, 
			Column16, 
			Column17, 
			Column18, 
			Column19, 
			Column20, 
			Column21, 
			Column22, 
			Column23, 
			Column24, 
			Column25, 
			Column26
			--FROM NLSNTSData NLSD 
			--INNER JOIN NLSNMarketStationMap NLSMS ON NLSD.Column2 = NLSMS.NLSNStationId
			--WHERE Column1 = '08'	
			FROM NLSNTSData
			WHERE Column1 = '08'
			AND COLUMN2 IN (SELECT [NLSNStationID]  FROM NLSNMarketStationMap)	
			
			--INSERT INTO NLSNSpotRating
			--(
			--	[FK_MTStationID],[AirDate],[StartTime],[EndTime],[HouseHold],
			--	[c2_5],	[c6_11],[m12_14],[m15_17],[m18_20],	[m21_24],[m25_34],[m35_49],
			--	[m50_54],[m55_64],[m65P],[f12_14],[f15_17],[f18_20],[f21_24],[f25_34],
			--	[f35_49],[f50_54],[f55_64],[f65P]
			--)
			SELECT 
				(SELECT [NLSNStationID] FROM NLSNMarketStationMap WHERE [NLSNStationID] = StationCode),
				@AirDate,
				StartTime,
				EndTime,
				HouseHold,
				C2_5,
				C6_11, 
				M12_14,
				M15_17,
				M18_20,
				M21_24,
				M25_34,
				M35_49,
				M50_54,
				M55_64,
				M65P,
				F12_14,
				F15_17,
				F18_20,
				F21_24,
				F25_34,
				F35_49,
				F50_54,
				F55_64,
				F65P
			FROM @NLSNRatingData

				
		--END
		END
		SELECT * FROM @NLSNRatingData
		SELECT * FROM NLSNSpotRating		

		--SELECT DISTINCT COLUMN2 FROM NLSNTSData WHERE COLUMN1 = '08' AND COLUMN2 IN (SELECT NLSNStationId  FROM NLSNMarketStationMap)

		--Ingestion of Program file data

		DECLARE @ProgramStationCode varchar(10)
		DECLARE @ProgramAirDate datetime
		DECLARE @ProgramStartTime VARCHAR(20)
		DECLARE @ProgramEndTime VARCHAR(20)
		DECLARE @TOTALROWS INT
		DECLARE @CURRENTROWCOUNT INT
		DECLARE @ModifiedStartTime time(7)
		DECLARE @ModifiedEndTime time(7)
		DECLARE @Count int
		DECLARE @RowCount int
		DECLARE @UPDATEDSTARTTIME VARCHAR(20)
		DECLARE @UPDATEDENDTIME VARCHAR(20)
		DECLARE @TotalMinutes INT

		SET @Count = 0
		SET @RowCount = 1
		SET @TOTALROWS = 0	

		DECLARE @NLSNProgramTemp TABLE
		(
			RowId INT IDENTITY (1, 1), 			
			ProgramName	varchar(50),
			ProgramSource	varchar(50),
			NielsenMarketCode	varchar(50),
			NielsenStationId	varchar(50),
			AirDate	DateTime,
			ProgramStartTime	VARCHAR(20),
			ProgramEndTime	VARCHAR(20)
		)
		
		DECLARE @NLSNSpotNoStations TABLE
		(
			RowId INT IDENTITY (1, 1), 
			StationName varchar(50),
			IsTracked bit
		)

		DECLARE @NLSNSpotProgramSchedule TABLE
		(
			[PK_Id] [int] IDENTITY(1,1) NOT NULL,
			[ProgramName] [varchar](50) NOT NULL,
			[ProgramSource] [varchar](50) NOT NULL,
			[NLSNMarketCode] [varchar](50) NULL,
			[MTMarketId] [int] NULL,
			[NLSNStationId] [varchar](50) NULL,
			[MTStationId] [int] NULL,
			[AirDate] [datetime] NULL,
			[FK_QuarterHourId] [int] NULL,
			[ProgramStartTime] [time](7) NOT NULL,
			[ProgramEndTime] [time](7) NOT NULL,
			[NLSNStartTime] [time](7) NOT NULL,
			[NLSNEndTime] [time](7) NOT NULL,
			[CreatedDate] [datetime] NOT NULL,
			[CreatedBy] [int] NOT NULL
		)

		select @ProgramStationCode = column2, @ProgramAirDate = column7
		from NLSNPFData where column1 = '11'

		Insert into @NLSNProgramTemp
		(
			ProgramName,
			ProgramSource,
			NielsenMarketCode,
			NielsenStationId,
			AirDate,
			ProgramStartTime,
			ProgramEndTime
		)
		select Column7,
		case when (Column13 = '' or column13 is null) then column12 else column13 end,
		(select NLSNMarketCode from NLSNMarketStationMap where [NLSNStationID] = column2),
		Column2,
		case when(cast(Column4 as time) >= cast('00:00AM' as time) and (cast(Column4 as time) < cast('05:00AM' as time))) then DATEADD(DAY, -1, cast(Column4 as date)) else cast(Column4 as date) END AIRDATE,
		Column4,
		Column5
		from NLSNPFData where column1 = '12'
		and column2 in (select distinct [NLSNStationID] from NLSNMarketStationMap)
		
		
		SELECT * FROM @NLSNProgramTemp

		INSERT INTO @NLSNSpotNoStations
			(
				StationName,
				IsTracked
			)
			SELECT DISTINCT NLSC.Column2, 0
			FROM NLSNPFData NLSC
			LEFT OUTER JOIN NLSNMarketStationMap NLSM ON NLSC.Column2 = NLSM.[NLSNStationID]
			where NLSM.[NLSNStationID] IS NULL

			SELECT * FROM @NLSNSpotNoStations

			--INSERT INTO NLSNMarketStationMap
			--(
			--	NLSNDMACode,
			--	NLSNStationId,
			--	IsTracked,
			--	CreatedDate,
			--	CreatedBy
			--)
			--SELECT  @ProgramStationCode, StationName, IsTracked, GETDATE(), 1
			--FROM @NLSNSpotNoStations

		
		Select @Count =  count(*) from @NLSNProgramTemp

		WHILE (@Count > 0)
		BEGIN
			if(@Count = 518)
			begin
			Print(@Count)
			end

			SET @CURRENTROWCOUNT = 1
			SELECT @Count = @Count - 1
			SELECT @ProgramStartTime = ProgramStartTime, @ProgramEndTime=ProgramEndTime from @NLSNProgramTemp where RowId = @RowCount
			SELECT @UPDATEDSTARTTIME = (SELECT CAST(CAST(SUBSTRING(@ProgramStartTime, 12,2)+':'+SUBSTRING(@ProgramStartTime, 15,4) AS TIME) AS VARCHAR))
			SELECT @UPDATEDENDTIME = (SELECT CAST(CAST(SUBSTRING(@ProgramEndTime, 12,2)+':'+SUBSTRING(@ProgramEndTime, 15,4) AS TIME) AS VARCHAR))

			SELECT @UPDATEDSTARTTIME = (SELECT REPLACE(@ProgramStartTime, SUBSTRING(@ProgramStartTime, 12,2), SUBSTRING(@UPDATEDSTARTTIME, 1,2)))
			SELECT @UPDATEDENDTIME = (SELECT REPLACE(@ProgramEndTime, SUBSTRING(@ProgramEndTime, 12,2), SUBSTRING(@UPDATEDENDTIME, 1,2)))

			SET @TOTALROWS = (SELECT DBO.NLSGetMinutesFromTime(CONVERT(VARCHAR, SUBSTRING(@UPDATEDSTARTTIME, 12,2) + SUBSTRING(@UPDATEDSTARTTIME, 15,2)),CONVERT(VARCHAR, SUBSTRING(@UPDATEDENDTIME, 12,2) + SUBSTRING(@UPDATEDENDTIME, 15,2))) )
			Print(@Count)
			PRINT(@TOTALROWS)
			WHILE(@TOTALROWS > 0)
			BEGIN
				SELECT @TOTALROWS = @TOTALROWS - 1


				--Print('naga')
				--print(@ProgramStartTime)
				--Print(@CURRENTROWCOUNT)
				SELECT @TotalMinutes = (@CURRENTROWCOUNT - 1)*15
				
				SELECT @ModifiedStartTime = (SELECT DATEADD(MINUTE, @TotalMinutes, @ProgramStartTime))
				SELECT @ModifiedEndTime = (SELECT DATEADD(SECOND, -1, (DATEADD(MINUTE, 15 + @TotalMinutes, @ProgramStartTime))))
				
				--SELECT @ModifiedStartTime = (SELECT CAST((SUBSTRING(@ProgramStartTime, 12,2)+':'+ CAST((SUBSTRING(@ProgramStartTime, 15,2)) + @TotalMinutes AS VARCHAR)) AS time) StartTime)
				--SELECT @ModifiedEndTime = (SELECT DATEADD(SECOND, -1, DATEADD(MINUTE,15,CAST((SUBSTRING(@ProgramStartTime, 12,2)+':'+ CAST((CAST(SUBSTRING(@ProgramStartTime, 15,2) AS INT) + CAST(@TotalMinutes AS INT)) AS VARCHAR)) AS TIME))) EndTime)
				
				--Print('naga')
				INSERT INTO @NLSNSpotProgramSchedule
				(
					ProgramName,
					ProgramSource,
					NLSNMarketCode,
					MTMarketId,
					NLSNStationId,
					MTStationId,
					AirDate,
					[FK_QuarterHourId],
					ProgramStartTime,
					ProgramEndTime,
					NLSNStartTime,
					NLSNEndTime,
					CreatedDate,
					CreatedBy
				)
				SELECT ProgramName,
				ProgramSource,
				NielsenMarketCode,
				(select [MarketID] from NLSNMarketStationMap where [NLSNStationID] = NielsenStationId),
				NielsenStationId,
				(select [NLSNStationID] from NLSNMarketStationMap where [NLSNStationID] = NielsenStationId),
				AirDate,
				QHM.[QuarterHourId],
				ProgramStartTime,
				ProgramEndTime,
				@ModifiedStartTime,
				@ModifiedEndTime,
				GetDate(),
				1
				FROM @NLSNProgramTemp NLSPT
				INNER JOIN [QuarterHour] QHM ON QHM.StartTime = @ModifiedStartTime AND QHM.EndTime = @ModifiedEndTime
				
				WHERE RowId = @RowCount

				SELECT @CURRENTROWCOUNT = @CURRENTROWCOUNT + 1
			END
			SELECT @RowCount = @RowCount + 1
		END

		select * from @NLSNSpotProgramSchedule
		
		COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSNProcessSpotFilesData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;