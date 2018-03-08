
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 06/17/2015 
-- Description:  Ingestion of overnight broadcast file
-- Query : exec sp_NLSInsertONBCFile
-- ============================================= 
CREATE PROC [dbo].[sp_NLSInsertONBCFile]  
AS 
  BEGIN       

      BEGIN try 

	   BEGIN TRANSACTION 
			
		--Table variable to hold Program and HouseHold filtered data.
		DECLARE @OvernightHouseholdFilteredData TABLE
		(
		  [Station] VARCHAR(50),
		  [AirDate] VARCHAR(250),
		  [HalfHrsIdentifier] INT,
		  [StartTime] VARCHAR(10),
		  [EndTime] VARCHAR(10),
		  [FirstQtrHrsDuration] VARCHAR(50),
		  [SecondQtrHrsDuration] VARCHAR(50),
		  [HHFirst] VARCHAR(50),
		  [HHSecond] VARCHAR(50)
		);

		--Table variable to hold Program and HouseHold calculations data.
		DECLARE @OvernightHouseholdCalcData TABLE
		(
		  [Station] VARCHAR(50),
		  [AirDate] VARCHAR(250),
		  [HalfHrsIdentifier] INT,
		  [StartTime] VARCHAR(10),
		  [HHFirst] VARCHAR(50),
		  [HHSecond] VARCHAR(50),
		  [QuartedHrsIdentifier] VARCHAR(50)
		);
		--Table variable to hold Program and HouseHold Final data.
		DECLARE @OvernightHouseholdFinalData TABLE
		(
		  [Station] VARCHAR(50),
		  [AirDate] VARCHAR(250),		
		  [StartTime] VARCHAR(10),
		  [EndTime] VARCHAR(10),
		  [HalfHrsIdentifier] INT,
		  [QuartedHrsIdentifier] VARCHAR(50),
		  [HouseHold] VARCHAR(50)
		);

		--DUPLICATE TABLE
		DECLARE @Double TABLE
		(
		  SlNo INT
		);

		---DEMOGRAPHIC VARIABLES---

		 DECLARE @OvernightDemographicFilteredData TABLE
		(
		  RowId INT IDENTITY (1, 1), 
		  Station VARCHAR(50),
		  AirDate VARCHAR(50),
		  QuarterHrsId VARCHAR(50),
		  DemographicGroupId VARCHAR(10),
		  StartTime VARCHAR(10),
		  EndTime VARCHAR(10),
		  Duration VARCHAR(10),
		  FC2_5 VARCHAR(50),
		  FC6_8 VARCHAR(50),
		  FC9_11 VARCHAR(50),
		  FT12_14 VARCHAR(50),
		  FT15_17 VARCHAR(50),
		  F18_20 VARCHAR(50),
		  F21_24 VARCHAR(50),
		  F25_29 VARCHAR(50),
		  F30_34 VARCHAR(50),
		  F35_39 VARCHAR(50),
		  F40_44 VARCHAR(50),
		  F45_49 VARCHAR(50),
		  F50_54 VARCHAR(50),
		  F55_64 VARCHAR(50),
		  F65PLUS VARCHAR(50),
		  MC2_5 VARCHAR(50),
		  MC6_8 VARCHAR(50),
		  MC9_11 VARCHAR(50),
		  MT12_14 VARCHAR(50),
		  MT15_17 VARCHAR(50),
		  M18_20 VARCHAR(50),
		  M21_24 VARCHAR(50),
		  M25_29 VARCHAR(50),
		  M30_34 VARCHAR(50),
		  M35_39 VARCHAR(50),
		  M40_44 VARCHAR(50),
		  M45_49 VARCHAR(50),
		  M50_54 VARCHAR(50),
		  M55_64 VARCHAR(50),
		  M65PLUS VARCHAR(50)
		  );

		DECLARE @OvernightDistinctDemographicFilteredData TABLE
		(
		  RowId INT IDENTITY (1, 1), 
		  Station VARCHAR(50),
		  AirDate VARCHAR(50),
		  QuarterHrsId VARCHAR(50),
		  DemographicGroupId VARCHAR(10)		  
		  );

		DECLARE @OvernightDemographicData TABLE
		(
		  RowId INT IDENTITY (1, 1), 
		  Station VARCHAR(50),
		  AirDate VARCHAR(50),
		  QuarterHrsId VARCHAR(50),
		  DemographicGroupId VARCHAR(10),
		  StartTime VARCHAR(10),
		  EndTime VARCHAR(10),
		  Duration VARCHAR(10)		  
		  );

		DECLARE @OvernightDemographicCalculatedData TABLE
		(
		  Station VARCHAR(50), 
		  AirDate VARCHAR(50),
		  QuarterHrsId VARCHAR(50),
		  FC2_5 VARCHAR(50),
		  FC6_8 VARCHAR(50),
		  FC9_11 VARCHAR(50),
		  FT12_14 VARCHAR(50),
		  FT15_17 VARCHAR(50),
		  F18_20 VARCHAR(50),
		  F21_24 VARCHAR(50),
		  F25_29 VARCHAR(50),
		  F30_34 VARCHAR(50),
		  F35_39 VARCHAR(50),
		  F40_44 VARCHAR(50),
		  F45_49 VARCHAR(50),
		  F50_54 VARCHAR(50),
		  F55_64 VARCHAR(50),
		  F65PLUS VARCHAR(50),
		  MC2_5 VARCHAR(50),
		  MC6_8 VARCHAR(50),
		  MC9_11 VARCHAR(50),
		  MT12_14 VARCHAR(50),
		  MT15_17 VARCHAR(50),
		  M18_20 VARCHAR(50),
		  M21_24 VARCHAR(50),
		  M25_29 VARCHAR(50),
		  M30_34 VARCHAR(50),
		  M35_39 VARCHAR(50),
		  M40_44 VARCHAR(50),
		  M45_49 VARCHAR(50),
		  M50_54 VARCHAR(50),
		  M55_64 VARCHAR(50),
		  M65PLUS VARCHAR(50)
		  );

		--

		INSERT INTO @Double(SlNo)
		SELECT SlNo
		FROM (
		select 1[SlNo]
		union
		select 2[SlNo]
		)AS FILTER;
		--
		
		INSERT INTO @OvernightHouseholdFilteredData
		(
		[Station],
		[AirDate],
		[HalfHrsIdentifier],
		[StartTime],
		[EndTime],
		[FirstQtrHrsDuration],
		[SecondQtrHrsDuration],
		[HHFirst],
		[HHSecond]
		)	
SELECT DISTINCT	
Station,
 CASE WHEN([StartTimeRaw] >= 2400) THEN DATEADD(day,1,AirDate) ELSE AirDate END[AirDate],
		[HalfHrsIdentifier], 	
		StartTime,
 REPLACE(CONVERT(VARCHAR(8), DATEADD(SECOND,59,DATEADD(MINUTE,(convert(int,29)),CAST(
									(  SUBSTRING(StartTime,1,2) + ':' + SUBSTRING(StartTime, 3, 2)
									) AS DATETIME))), 108), ':', '') EndTime,
		[FirstQtrHrsDuration],
		[SecondQtrHrsDuration],
		[HHFirst],
		[HHSecond]
from (
select SUBSTRING(NLSRawData,15,6)[Station],
		convert(DATE,'20'+substring((SUBSTRING(NLSRawData,44,7)),2,6))[AirDate], 
		right(replicate('0',4) + convert(varchar,CASE WHEN(SUBSTRING(NLSRawData,86,4) >= 2400) 
		THEN (SUBSTRING(NLSRawData,86,4)-2400)
		ELSE SUBSTRING(NLSRawData,86,4)
		END), 4) [StartTime],
		SUBSTRING(NLSRawData,86,4) [StartTimeRaw],
		CAST(SUBSTRING(NLSRawData,81,2) AS INT) [HalfHrsIdentifier],
		SUBSTRING(NLSRawData,254,6)[FirstQtrHrsDuration],
		SUBSTRING(NLSRawData,303,6)[SecondQtrHrsDuration], 
		SUBSTRING(NLSRawData,260,9)[HHFirst],
		SUBSTRING(NLSRawData,309,9)[HHSecond]
		FROM [NLSNBCRawData]
		WHERE SUBSTRING(NLSRawData,85,1)='H'
		AND SUBSTRING(NLSRawData,1,2)='04'	
		) q	
		
		--
		INSERT INTO @OvernightHouseholdCalcData
		(
		[Station],
		[AirDate],
		[HalfHrsIdentifier],
		[StartTime],
		[HHFirst],
		[HHSecond],
		[QuartedHrsIdentifier]
		)		
		
		SELECT 
		Station,
		AirDate,
		HalfHrsIdentifier,
		StartTime,
		HHFirst,
		HHSecond,
		(SELECT QuarterHourID FROM QuarterHour q WHERE cast(convert(datetime,SUBSTRING(FILTER.StartTime,1,2)+':'+SUBSTRING(FILTER.StartTime,3,2)) as time) BETWEEN q.StartTime AND q.EndTime )[QuartedHrsIdentifier]
		
		 FROM 
		(select 
		CD.Station,
		CD.AirDate,
		CD.HalfHrsIdentifier,
		(SELECT TOP 1 StartTime FROM @OvernightHouseholdFilteredData WHERE Station=CD.Station AND AirDate=CD.AirDate AND HalfHrsIdentifier=CD.HalfHrsIdentifier)[StartTime], 
		(sum(isnull(convert(bigint,CD.[FirstQtrHrsDuration]),0)*isnull(CD.HHFirst,0))/sum(convert(bigint,CD.[FirstQtrHrsDuration])))[HHFirst],
		(sum(isnull(convert(bigint,CD.[SecondQtrHrsDuration]),0)*isnull(CD.HHSecond,0))/sum(convert(bigint,CD.[SecondQtrHrsDuration])))[HHSecond]
		
		from @OvernightHouseholdFilteredData CD
		WHERE CD.[FirstQtrHrsDuration]<>0 AND CD.[SecondQtrHrsDuration]<>0
		group by Station,AirDate,HalfHrsIdentifier
		) FILTER;	

		--

		INSERT INTO @OvernightHouseholdFinalData
		(
		[Station],
		[AirDate],		
		[StartTime],
		[EndTime],
		[HalfHrsIdentifier],
		[QuartedHrsIdentifier],
		[HouseHold]
		)	

		SELECT CR.Station,
		CR.AirDate,		
		CASE WHEN CD.SLNO=1 THEN CR.StartTime 
		     WHEN CD.SLNO=2 THEN
			 (SELECT REPLACE(CONVERT(VARCHAR(5), DATEVALUE, 108), ':', '')
		FROM (	  SELECT  DATEADD(MINUTE,(convert(int,15)),CAST(
									(   SUBSTRING(CR.StartTime, 1, 2) + ':' + 
										SUBSTRING(CR.StartTime, 3, 2)
									) AS DATETIME
								)
							) AS DATEVALUE) AS SUB)
							
							 END
		[StartTime],

		CASE WHEN CD.SLNO=1 THEN 			
			(SELECT REPLACE(CONVERT(VARCHAR(8), DATEVALUE, 108), ':', '')
		FROM (
		SELECT DATEADD(SECOND,59,DATEVALUE)[DATEVALUE] FROM (
		SELECT  DATEADD(MINUTE,(convert(int,14)),CAST(
									(   SUBSTRING(CR.StartTime, 1, 2) + ':' + 
										SUBSTRING(CR.StartTime, 3, 2)
									) AS DATETIME
								)
							) AS DATEVALUE) AS SUB
							) Filter)	
		     WHEN CD.SLNO=2 THEN
			(SELECT REPLACE(CONVERT(VARCHAR(8), DATEVALUE, 108), ':', '')
		FROM (
		SELECT DATEADD(SECOND,59,DATEVALUE)[DATEVALUE] FROM (
		SELECT  DATEADD(MINUTE,(convert(int,29)),CAST(
									(   SUBSTRING(CR.StartTime, 1, 2) + ':' + 
										SUBSTRING(CR.StartTime, 3, 2)
									) AS DATETIME
								)
							) AS DATEVALUE) AS SUB
							) Filter)
							
							 END
            [EndTime],
		CR.HalfHrsIdentifier,
		(CASE WHEN CD.SLNO=1 THEN CR.QuartedHrsIdentifier WHEN CD.SLNO=2 THEN CR.QuartedHrsIdentifier+1 END)[QuartedHrsIdentifier] 
		,(CASE WHEN CD.SLNO=1 THEN CR.HHFirst WHEN CD.SLNO=2 THEN CR.HHSecond END)[HouseHold] FROM 
		@OvernightHouseholdCalcData CR,
		@Double CD

		--INSERT FILTERED DEMOGRAPHIC DATA.
		INSERT INTO @OvernightDemographicFilteredData
		(Station,
		AirDate,
		QuarterHrsId,
		DemographicGroupId,
		StartTime,
		EndTime,
		Duration,
		FC2_5,
		FC6_8,
		FC9_11,
		FT12_14,
		FT15_17,
		F18_20,
		F21_24,
		F25_29,
		F30_34,
		F35_39,
		F40_44,
		F45_49,
		F50_54,
		F55_64,
		F65PLUS,
		MC2_5,
		MC6_8,
		MC9_11,
		MT12_14,
		MT15_17,
		M18_20,
		M21_24,
		M25_29,
		M30_34,
		M35_39,
		M40_44,
		M45_49,
		M50_54,
		M55_64,
		M65PLUS
		)

		SELECT [Station],
				 CASE WHEN([StartTimeRaw] >= 2400) THEN DATEADD(day,1,AirDate) ELSE AirDate END[AirDate],
		QtrHrsId,
				DemographicGroupId,
  				StartTime,
		 REPLACE(CONVERT(VARCHAR(8), DATEADD(SECOND,59,DATEADD(MINUTE,(convert(int,29)),CAST(
											(  SUBSTRING(StartTime,1,2) + ':' + SUBSTRING(StartTime, 3, 2)
											) AS DATETIME))), 108), ':', '') EndTime,
				NULL [Duration],
				FC2_5,
				FC6_8,
				FC9_11,
				FT12_14,
				FT15_17,
				F18_20,
				F21_24,
				F25_29,
				F30_34,
				F35_39,
				F40_44,
				F45_49,
				F50_54,
				F55_64,
				F65PLUS,
				MC2_5,
				MC6_8,
				MC9_11,
				MT12_14,
				MT15_17,
				M18_20,
				M21_24,
				M25_29,
				M30_34,
				M35_39,
				M40_44,
				M45_49,
				M50_54,
				M55_64,
				M65PLUS
		
		from (select SUBSTRING(NLSRawData,15,6)[Station],
				convert(DATE,'20'+substring((SUBSTRING(NLSRawData,44,7)),2,6))[AirDate], 
				SUBSTRING(NLSRawData,83,2)[QtrHrsId],
				SUBSTRING(NLSRawData,92,3)[DemographicGroupId],
				right(replicate('0',4) + convert(varchar,CASE WHEN(SUBSTRING(NLSRawData,86,4) >= 2400) 
				THEN (SUBSTRING(NLSRawData,86,4)-2400)
				ELSE SUBSTRING(NLSRawData,86,4)
				END), 4) [StartTime],
				SUBSTRING(NLSRawData,86,4) [StartTimeRaw],
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 116, 9) 
				END                     [FC2_5], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 125, 9) 
				END                     [FC6_8], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 134, 9) 
				END                     [FC9_11], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 143, 9) 
				END                     [FT12_14], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 152, 9) 
				END                     [FT15_17], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 161, 9) 
				END                     [F18_20], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 170, 9) 
				END                     [F21_24], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 179, 9) 
				END                     [F25_29], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 188, 9) 
				END                     [F30_34], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 197, 9) 
				END                     [F35_39], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 206, 9) 
				END                     [F40_44], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 215, 9) 
				END                     [F45_49], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 224, 9) 
				END                     [F50_54], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 233, 9) 
				END                     [F55_64], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 242, 9) 
				END                     [F65PLUS], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 251, 9) 
				END                     [MC2_5], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 260, 9) 
				END                     [MC6_8], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 269, 9) 
				END                     [MC9_11], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 278, 9) 
				END                     [MT12_14], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '001' THEN 
				  Substring(NLSRawData, 287, 9) 
				END                     [MT15_17], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 116, 9) 
				END                     [M18_20], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 125, 9) 
				END                     [M21_24], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 134, 9) 
				END                     [M25_29], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 143, 9) 
				END                     [M30_34], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 152, 9) 
				END                     [M35_39], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 161, 9) 
				END                     [M40_44], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 170, 9) 
				END                     [M45_49], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 179, 9) 
				END                     [M50_54], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 188, 9) 
				END                     [M55_64], 
				CASE 
				  WHEN Substring(NLSRawData, 92, 3) = '021' THEN 
				  Substring(NLSRawData, 197, 9) 
				END						[M65PLUS] 
				FROM [NLSNBCRawData] 
				WHERE SUBSTRING(NLSRawData,1,2)='04'
				AND SUBSTRING(NLSRawData,85,1)='P'
				AND SUBSTRING(NLSRawData,83,2) != ''
				AND (SUBSTRING(NLSRawData,44,7) = SUBSTRING(NLSRawData,51,7))
				AND SUBSTRING(NLSRawData,95,1)=0
		) q		
				ORDER BY
				Station,
				AirDate,
				QtrHrsID,
				DemographicGroupId,
				StartTimeRaw				


		INSERT INTO @OvernightDistinctDemographicFilteredData
		(Station,
		AirDate,
		QuarterHrsId,
		DemographicGroupId
		)
		SELECT DISTINCT Station, AirDate, QuarterHrsId, DemographicGroupId
		FROM @OvernightDemographicFilteredData

		--select * from @OvernightDemographicFilteredData
				
		DECLARE @RowCount        INT, 
                @Count           INT,
				@TotalQuarterHrsMinutes INT,
				@Station VARCHAR(50),
				@AirDate VARCHAR(50),
				@QuarterHrsId VARCHAR(10),
				@DemographicGroupId Varchar(10),
				@RecordCountForDuration INT,
				@InnerCount INT,
				@InnerStartCount INT,
				@Duration1 INT,
				@TotalDuration INT,
				@StartTime1 time,
				@StartTime2 time,
				@Station1 VARCHAR(50),
				@AirDate1 VARCHAR(50),
				@QuarterHrsId1 VARCHAR(10),
				@DemographicGroupId1 Varchar(10),
				@EndTime1 INT,
				@QuarterHrDuration INT

		SELECT @RowCount = 0, 
               @Count = 1,
			   @InnerStartCount = 1,
			   @TotalQuarterHrsMinutes = 15,
			   @TotalDuration =0,
			   @QuarterHrDuration = 15

        SELECT @RowCount = Count(*) 
        FROM   @OvernightDistinctDemographicFilteredData 

		PRINT( 'Total Row Count-  ' 
                 + Cast(@RowCount AS VARCHAR) ) 
				
          -- Looping through all distinct demographic records's    
          WHILE ( @RowCount > 0 ) 
            BEGIN 
                BEGIN try 
                    SELECT @RowCount = @RowCount - 1 
					SELECT @Station = Station FROM @OvernightDistinctDemographicFilteredData WHERE RowId = @Count
					SELECT @AirDate = AirDate FROM @OvernightDistinctDemographicFilteredData WHERE RowId = @Count
					SELECT @QuarterHrsId = QuarterHrsId FROM @OvernightDistinctDemographicFilteredData WHERE RowId = @Count
					SELECT @DemographicGroupId = DemographicGroupId FROM @OvernightDistinctDemographicFilteredData WHERE RowId = @Count
					
					SELECT @RecordCountForDuration = COUNT(*) FROM @OvernightDemographicFilteredData WHERE Station = @Station and AirDate = @AirDate and QuarterHrsId = @QuarterHrsId AND DemographicGroupId = @DemographicGroupId
					
					PRINT( 'Total Row Count for Duration-  ' 
                 + Cast(@RecordCountForDuration AS VARCHAR) ) 
					
					IF(@RecordCountForDuration = 1)
					BEGIN
					UPDATE @OvernightDemographicFilteredData SET Duration = '15' WHERE Station = @Station and AirDate = @AirDate and QuarterHrsId = @QuarterHrsId AND DemographicGroupId = @DemographicGroupId
					END
					ELSE
					BEGIN

					WHILE (@RecordCountForDuration > 1)
					BEGIN
					
					SELECT @RecordCountForDuration = @RecordCountForDuration - 1 
					
					INSERT INTO @OvernightDemographicData
					(Station,
					AirDate,
					QuarterHrsId,
					DemographicGroupId,
					StartTime,
					EndTime,
					Duration
					)
					SELECT Station, 
					AirDate, 
					QuarterHrsId, 
					DemographicGroupId, 
					StartTime, 
					EndTime, 
					Duration 
					FROM @OvernightDemographicFilteredData 
					WHERE Station = @Station and 
					AirDate = @AirDate and 
					QuarterHrsId = @QuarterHrsId AND 
					DemographicGroupId = @DemographicGroupId

					--SELECT * FROM @OvernightDemographicData
					SELECT @InnerCount = COUNT(*) FROM @OvernightDemographicData

					WHILE (@InnerCount > 0)
									

					BEGIN
					IF(@InnerCount = 1)
					BEGIN
					SELECT @Duration1 = 15 - @TotalDuration
					END
					ELSE
					BEGIN					 

					SELECT @StartTime1 = cast(substring(StartTime,1,2)+':'+substring(StartTime,3,2)+':00' as time) FROM @OvernightDemographicData WHERE RowId = @InnerStartCount
					SELECT @StartTime2 = cast(substring(StartTime,1,2)+':'+substring(StartTime,3,2)+':00' as time) FROM @OvernightDemographicData WHERE RowId = @InnerStartCount + 1

					SELECT @Duration1 = round(convert(float, datediff(second,@StartTime1,@StartTime2))/60,0) 
				
					END
					SET @TotalDuration = @TotalDuration + @Duration1

					SELECT @Station1 = Station FROM @OvernightDemographicData WHERE RowId = @InnerStartCount
					SELECT @AirDate1 = AirDate FROM @OvernightDemographicData WHERE RowId = @InnerStartCount
					SELECT @QuarterHrsId1 = QuarterHrsId FROM @OvernightDemographicData WHERE RowId = @InnerStartCount
					SELECT @DemographicGroupId1 = DemographicGroupId FROM @OvernightDemographicData WHERE RowId = @InnerStartCount
					SELECT @EndTime1 = EndTime FROM @OvernightDemographicData WHERE RowId = @InnerStartCount

					UPDATE @OvernightDemographicFilteredData SET Duration = @Duration1 WHERE Station = @Station1 and AirDate = @AirDate1 and QuarterHrsId = @QuarterHrsId1 AND DemographicGroupId = @DemographicGroupId1 AND EndTime = @EndTime1

					SELECT @InnerCount = @InnerCount - 1
					SET @InnerStartCount = @InnerStartCount + 1					
					END
					delete from @OvernightDemographicData
					SET @TotalDuration = 0
					END
					
									
					END
					SET @Count = @Count + 1
                END try 
				BEGIN catch                     
                    SET @Count = @Count + 1 
                END catch 
            END 
		--SELECT * FROM @OvernightHouseholdFinalData

		--INSERT FILTERED DEMOGRAPHIC DATA.
		INSERT INTO @OvernightDemographicCalculatedData
		(Station,
		AirDate,
		QuarterHrsId,
		FC2_5,
		FC6_8,
		FC9_11,
		FT12_14,
		FT15_17,
		F18_20,
		F21_24,
		F25_29,
		F30_34,
		F35_39,
		F40_44,
		F45_49,
		F50_54,
		F55_64,
		F65PLUS,
		MC2_5,
		MC6_8,
		MC9_11,
		MT12_14,
		MT15_17,
		M18_20,
		M21_24,
		M25_29,
		M30_34,
		M35_39,
		M40_44,
		M45_49,
		M50_54,
		M55_64,
		M65PLUS
		)
		SELECT  rtrim(case DD.Station 
                          when 'TEL'  then 'TELA'
						  when 'UMA'  then 'UNIM'
						  when 'UNI '  then 'UNIV'
						  else DD.Station end),
		--convert(DATE,'20'+substring(DD.AirDate,2,6))[AirDate],
		DD.AirDate,
		DD.QuarterHrsId,
		convert(int,round(SUM(convert(float,ISNULL(FC2_5,0))*Duration)/@QuarterHrDuration,0)) [FC2_5],
		convert(int,round(SUM(convert(float,ISNULL(FC6_8,0))*Duration)/@QuarterHrDuration,0)) [FC6_8],
		convert(int,round(SUM(convert(float,ISNULL(FC9_11,0))*Duration)/@QuarterHrDuration,0)) [FC9_11],
		convert(int,round(SUM(convert(float,ISNULL(FT12_14,0))*Duration)/@QuarterHrDuration,0)) [FT12_14],
		convert(int,round(SUM(convert(float,ISNULL(FT15_17,0))*Duration)/@QuarterHrDuration,0)) [FT15_17],
		convert(int,round(SUM(convert(float,ISNULL(F18_20,0))*Duration)/@QuarterHrDuration,0)) [F18_20],
		convert(int,round(SUM(convert(float,ISNULL(F21_24,0))*Duration)/@QuarterHrDuration,0)) [F21_24],
		convert(int,round(SUM(convert(float,ISNULL(F25_29,0))*Duration)/@QuarterHrDuration,0)) [F25_29],
		convert(int,round(SUM(convert(float,ISNULL(F30_34,0))*Duration)/@QuarterHrDuration,0)) [F30_34],
		convert(int,round(SUM(convert(float,ISNULL(F35_39,0))*Duration)/@QuarterHrDuration,0)) [F35_39],
		convert(int,round(SUM(convert(float,ISNULL(F40_44,0))*Duration)/@QuarterHrDuration,0)) [F40_44],
		convert(int,round(SUM(convert(float,ISNULL(F45_49,0))*Duration)/@QuarterHrDuration,0)) [F45_49],
		convert(int,round(SUM(convert(float,ISNULL(F50_54,0))*Duration)/@QuarterHrDuration,0)) [F50_54],
		convert(int,round(SUM(convert(float,ISNULL(F55_64,0))*Duration)/@QuarterHrDuration,0)) [F55_64],
		convert(int,round(SUM(convert(float,ISNULL(F65PLUS,0))*Duration)/@QuarterHrDuration,0)) [F65PLUS],
		convert(int,round(SUM(convert(float,ISNULL(MC2_5,0))*Duration)/@QuarterHrDuration,0)) [MC2_5],
		convert(int,round(SUM(convert(float,ISNULL(MC6_8,0))*Duration)/@QuarterHrDuration,0)) [MC6_8],
		convert(int,round(SUM(convert(float,ISNULL(MC9_11,0))*Duration)/@QuarterHrDuration,0)) [MC9_11],
		convert(int,round(SUM(convert(float,ISNULL(MT12_14,0))*Duration)/@QuarterHrDuration,0)) [MT12_14],
		convert(int,round(SUM(convert(float,ISNULL(MT15_17,0))*Duration)/@QuarterHrDuration,0)) [MT15_17],
		convert(int,round(SUM(convert(float,ISNULL(M18_20,0))*Duration)/@QuarterHrDuration,0)) [M18_20],
		convert(int,round(SUM(convert(float,ISNULL(M21_24,0))*Duration)/@QuarterHrDuration,0)) [M21_24],
		convert(int,round(SUM(convert(float,ISNULL(M25_29,0))*Duration)/@QuarterHrDuration,0)) [M25_29],
		convert(int,round(SUM(convert(float,ISNULL(M30_34,0))*Duration)/@QuarterHrDuration,0)) [M30_34],
		convert(int,round(SUM(convert(float,ISNULL(M35_39,0))*Duration)/@QuarterHrDuration,0)) [M35_39],
		convert(int,round(SUM(convert(float,ISNULL(M40_44,0))*Duration)/@QuarterHrDuration,0)) [M40_44],
		convert(int,round(SUM(convert(float,ISNULL(M45_49,0))*Duration)/@QuarterHrDuration,0)) [M45_49],
		convert(int,round(SUM(convert(float,ISNULL(M50_54,0))*Duration)/@QuarterHrDuration,0)) [M50_54],
		convert(int,round(SUM(convert(float,ISNULL(M55_64,0))*Duration)/@QuarterHrDuration,0)) [M55_64],
		convert(int,round(SUM(convert(float,ISNULL(M65PLUS,0))*Duration)/@QuarterHrDuration,0)) [M65PLUS]
		 FROM 
		@OvernightDemographicFilteredData DD
		GROUP BY DD.Station,DD.AirDate,DD.QuarterHrsId

		INSERT INTO [NLSNOvernightNetworkCableRating]
		(
		[TVStationID],
		[AirDate],
		[StartTime],
		[EndTime],
		[HouseHold],
		[National_FC2_5],
		[National_FC6_8],
		[National_FC9_11],
		[National_FT12_14],
		[National_FT15_17],
		[National_F18_20], 
		[National_F21_24], 
		[National_F25_29], 
		[National_F30_34], 
		[National_F35_39], 
		[National_F40_44], 
		[National_F45_49], 
		[National_F50_54], 
		[National_F55_64], 
		[National_F65Plus],
		[National_MC2_5],
		[National_MC6_8],
		[National_MC9_11],
		[National_MT12_14],
		[National_MT15_17],
		[National_M18_20], 
		[National_M21_24], 
		[National_M25_29], 
		[National_M30_34],
		[National_M35_39], 
		[National_M40_44], 
		[National_M45_49], 		 
		[National_M50_54],	
		[National_M55_64],	
		[National_M65Plus]
		)
		SELECT (select TVStationId from TVStation where StationShortName = ONH.Station),
		ONH.AirDate,
		cast(convert(datetime,SUBSTRING(ONH.StartTime,1,2)+':'+SUBSTRING(ONH.StartTime,3,2)) as time)[StartTime],
		cast(convert(datetime,SUBSTRING(ONH.EndTime,1,2)+':'+SUBSTRING(ONH.EndTime,3,2)+':'+SUBSTRING(ONH.EndTime,5,2)) as time)[EndTime],		
		ONH.HouseHold,
		OND.FC2_5,
		OND.FC6_8,
		OND.FC9_11,
		OND.FT12_14,
		OND.FT15_17,
		OND.F18_20,
		OND.F21_24,
		OND.F25_29,
		OND.F30_34,
		OND.F35_39,
		OND.F40_44,
		OND.F45_49,
		OND.F50_54,
		OND.F55_64,
		OND.F65PLUS,
		OND.MC2_5,
		OND.MC6_8,
		OND.MC9_11,
		OND.MT12_14,
		OND.MT15_17,
		OND.M18_20,
		OND.M21_24,
		OND.M25_29,
		OND.M30_34,
		OND.M35_39,
		OND.M40_44,
		OND.M45_49,
		OND.M50_54,
		OND.M55_64,
		OND.M65PLUS

		FROM @OvernightHouseholdFinalData ONH
		INNER JOIN @OvernightDemographicCalculatedData OND
		ON ONH.Station = OND.Station AND
		ONH.AirDate = OND.AirDate AND
		ONH.QuartedHrsIdentifier = OND.QuarterHrsId
		and exists (select 1 from TVStation where StationShortName = ONH.Station)
	


		--SELECT * FROM @OvernightHouseholdFilteredData
		--SELECT * FROM @OvernightHouseholdCalcData
		--SELECT * FROM @OvernightHouseholdFinalData
		--SELECT * FROM @OvernightDemographicFilteredData
		--SELECT * FROM @OvernightDemographicFilteredData
		--SELECT * FROM @OvernightDemographicCalculatedData

		SELECT * FROM [NLSNOvernightNetworkCableRating]


	
	   COMMIT TRANSACTION 
	
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSInsertONBCFile: %d: %s',16,1,@Error,@Message,@LineNo); 
      END catch; 
  END;