
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 06/02/2015 
-- Description:  Delete Job Steps
-- Select * from [NLSSyndComRtg]
--Truncate table NLSSyndComRtg
-- Query : exec sp_NLSInsertSYNComNWFile
-- ============================================= 
CREATE PROC [dbo].[sp_NLSInsertSYNComNWFile]  
AS 
  BEGIN       

      BEGIN try 

	  BEGIN TRANSACTION 
	   --select * from NLSCSRFRawData
	   --Table variable to hold Program and HouseHold data.
		DECLARE @ProgramAndHouseholdData TABLE
		(
		  ACNProgramCode VARCHAR(50), 		  
		  ProgramName VARCHAR(250),
		  AirDate DATE,
		  SplittedDate DATE,
		  CountDaysOfWeekIndicator INT,
		  DaysOfWeekIndicator VARCHAR(50),
		  Household VARCHAR(50)

		);
	
		--Table variable to hold Demographic data.
		DECLARE @DemographicData TABLE
		(
		  ACNProgramCode VARCHAR(50),
		  AirDate VARCHAR(50),
		  FC2_5	 VARCHAR(20),
		  FC6_8	 VARCHAR(20),
		  FC9_11 VARCHAR(20),
		  FT12_14 VARCHAR(20),
		  FT15_17 VARCHAR(20),
		  F18_20 VARCHAR(20),
		  F21_24 VARCHAR(20),
		  F25_29 VARCHAR(20),
		  F30_34 VARCHAR(20),
		  F35_39 VARCHAR(20),
		  F40_44 VARCHAR(20),
		  F45_49 VARCHAR(20),
		  F50_54 VARCHAR(20),
		  F55_64 VARCHAR(20),
		  F65PLUS VARCHAR(20),
		  MC2_5	 VARCHAR(20),
		  MC6_8	 VARCHAR(20),
		  MC9_11 VARCHAR(20),
		  MT12_14 VARCHAR(20),
		  MT15_17 VARCHAR(20),
		  M18_20 VARCHAR(20),
		  M21_24 VARCHAR(20),
		  M25_29 VARCHAR(20),
		  M30_34 VARCHAR(20),
		  M35_39 VARCHAR(20),
		  M40_44 VARCHAR(20),
		  M45_49 VARCHAR(20),
		  M50_54 VARCHAR(20),
		  M55_64 VARCHAR(20),
		  M65PLUS VARCHAR(20)
		);

		 --Table variable to hold filtered household data. 
        DECLARE @DUPLICATE TABLE 
        ( 
           number INT 
        ); 

		INSERT INTO @DUPLICATE 
                      (number) 
          SELECT number 
          FROM   (SELECT 1[NUMBER] 
                  UNION 
                  SELECT 2[NUMBER] 
                  UNION 
                  SELECT 3[NUMBER] 
                  UNION 
                  SELECT 4[NUMBER] 
                  UNION 
                  SELECT 5[NUMBER] 
                  UNION 
                  SELECT 6[NUMBER] 
                  UNION 
                  SELECT 7[NUMBER]) AS SUB 

		INSERT INTO @ProgramAndHouseholdData
		(
		ACNProgramCode,
		ProgramName,
		AirDate,
		SplittedDate,
		CountDaysOfWeekIndicator,
		DaysOfWeekIndicator,
		Household)
		SELECT [ACNProgramCode], [ProgramName], [AirDate], DATEADD(wk, DATEDIFF(wk,0,AirDate),(DBO.NLSGetPosition([Bit],'1',1,DP.NUMBER,CountDaysOfWeekIndicator))-1) [SplittedDate], [CountDaysOfWeekIndicator], [Bit], [Household] 
		FROM
		(
		SELECT [ACNProgramCode], [ProgramName], [AirDate], [CountDaysOfWeekIndicator], [Bit], [Household]
		FROM
		(
		SELECT [ACNProgramCode], [ProgramName], [AirDate], dbo.Nielsongetsumofairdate([DaysOfWeekIndicator])[CountDaysOfWeekIndicator], DaysOfWeekIndicator[Bit], [Household] 
		FROM
		(
		SELECT DISTINCT
		SUBSTRING(NLSRawData,21,10)[ACNProgramCode],
		SUBSTRING(NLSRawData,115,25) [ProgramName],
		convert(DATE,'20'+substring((SUBSTRING(NLSRawData,44,7)),2,6))[AirDate],
		SUBSTRING(NLSRawData,282,7)[DaysOfWeekIndicator],
		SUBSTRING(NLSRawData,337,9)[Household]  
		FROM [NLSNCSRFRawData] 
		WHERE 
		SUBSTRING(NLSRawData,1,2)='06'  and
		SUBSTRING(NLSRawData,11,1)=0  and
		SUBSTRING(NLSRawData,97,1)='B'  and
		SUBSTRING(NLSRawData,85,1)='C'
		) FILTER
		) ProgramHouseholdData 
		) ProgramHSData CROSS JOIN @DUPLICATE DP 
		WHERE  DP.number <= [CountDaysOfWeekIndicator] 
		ORDER BY [ACNProgramCode]

		SELECT * FROM @ProgramAndHouseholdData ORDER BY [ACNProgramCode]

		INSERT INTO @DemographicData
		(
		ACNProgramCode,
		AirDate,
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
		SELECT [ACNProgramCode],
		[AirDate],
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
		FROM 
		(
		SELECT [ACNProgramCode],
		[AirDate],
		MAX(ISNULL(FC2_5,0))[FC2_5],
		MAX(ISNULL(FC6_8,0))[FC6_8],
		MAX(ISNULL(FC9_11,0))[FC9_11],
		MAX(ISNULL(FT12_14,0))[FT12_14],
		MAX(ISNULL(FT15_17,0))[FT15_17],
		MAX(ISNULL(F18_20,0))[F18_20],
		MAX(ISNULL(F21_24,0))[F21_24],
		MAX(ISNULL(F25_29,0))[F25_29],
		MAX(ISNULL(F30_34,0))[F30_34],
		MAX(ISNULL(F35_39,0))[F35_39],
		MAX(ISNULL(F40_44,0))[F40_44],
		MAX(ISNULL(F45_49,0))[F45_49],
		MAX(ISNULL(F50_54,0))[F50_54],
		MAX(ISNULL(F55_64,0))[F55_64],
		MAX(ISNULL(F65PLUS,0))[F65PLUS],
		MAX(ISNULL(MC2_5,0))[MC2_5],
		MAX(ISNULL(MC6_8,0))[MC6_8],
		MAX(ISNULL(MC9_11,0))[MC9_11],
		MAX(ISNULL(MT12_14,0))[MT12_14],
		MAX(ISNULL(MT15_17,0))[MT15_17],
		MAX(ISNULL(M18_20,0))[M18_20],
		MAX(ISNULL(M21_24,0))[M21_24],
		MAX(ISNULL(M25_29,0))[M25_29],
		MAX(ISNULL(M30_34,0))[M30_34],
		MAX(ISNULL(M35_39,0))[M35_39],
		MAX(ISNULL(M40_44,0))[M40_44],
		MAX(ISNULL(M45_49,0))[M45_49],
		MAX(ISNULL(M50_54,0))[M50_54],
		MAX(ISNULL(M55_64,0))[M55_64],
		MAX(ISNULL(M65PLUS,0))[M65PLUS]
		FROM 
		(		
		SELECT DISTINCT
		SUBSTRING(NLSRawData,21,10)[ACNProgramCode],
		convert(DATE,'20'+substring((SUBSTRING(NLSRawData,44,7)),2,6)) [AirDate],
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
		FROM [NLSNCSRFRawData] 
		WHERE 
		SUBSTRING(NLSRawData,1,2)='06'  AND
		SUBSTRING(NLSRawData,11,1)=0  AND
		SUBSTRING(NLSRawData,97,1)='B'  AND
		SUBSTRING(NLSRawData,85,1)='P'
		--ORDER BY Substring(NLSRawData, 92, 3)
		) AS Filter
		GROUP BY [ACNProgramCode], [AirDate] 
		) AS DemographicData

		SELECT * FROM @DemographicData ORDER BY [ACNProgramCode]

		INSERT INTO [NLSNSyndicationComRating]
		(
		[AirDT],
		[PrgName],
		[HouseHold],
		[National_FC2_5],
		[National_FC6_8],
		[National_FC9_11],
		[National_FT12_14],
		[National_FT15_17],
		[National__F18_20],
		[National_F21_24],
		[National_F25_29],
		[National_F30_34],
		[National_F35_39],
		[National_F40_44],
		[National_F45_49],
		[National_F50_54],
		[National_F55_64],
		[National_F65PLUS],
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
		[National_M65PLUS]
		)

		SELECT PD.[SplittedDate],
		PD.[ProgramName],
		PD.[Household],
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
		
		FROM @ProgramAndHouseholdData PD
		INNER JOIN @DemographicData DD
		ON PD.[ACNProgramCode] = DD.[ACNProgramCode] AND PD.[AirDate] = DD.[AirDate]
		  
	  COMMIT TRANSACTION 
	
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_NLSInsertSYNComNWFile: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;
