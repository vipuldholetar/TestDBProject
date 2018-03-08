
-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 11/03/2015   
-- Description: Insert spot files data into database tables.  
-- Query :   
/*  
exec sp_NLSNProcessSpotRatingFileData '',  
drop procedure sp_NLSNProcessSpotRatingFileData
*/ 
-- =============================================  

CREATE PROCEDURE [dbo].[sp_NLSNProcessSpotRatingFileData] (@NLSNTSData dbo.NLSNTSData readonly, @SpotRatingFileName varchar(100)) 
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
			StationID int,
			IsTracked bit
		)

		DECLARE @NLSNRatingData TABLE
		(
		  StationID int, 
		  AirDate date,
		  StartTime time,
		  EndTime time,
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

		SELECT @MarketCode = Column3, @StartTime = Column13, @Region = Column7 FROM @NLSNTSData WHERE COLUMN1 = '01'
		
--        IF(EXISTS( select distinct NLSNDMACode from NLSNMarketStationMap where NLSNDMACode = @MarketCode))
		BEGIN		
			INSERT INTO @NLSNRatingStationCodes
			(
				[MarketCode],
				[City],
				[StationCode],
				[StationName]
			)
			SELECT Column7, Column8, column9, column10
			from @NLSNTSData
			where column1 = '02' and column7 = @MarketCode and Column8 LIKE '%' + RTRIM(LTRIM(@Region))+ '%'

			-- SELECT * FROM @NLSNRatingStationCodes
			
			INSERT INTO @NLSNNoStations
			(
				StationName,
				StationID,
				IsTracked
			)
			SELECT distinct NLSC.[StationName], NLSC.[StationCode], 0
			FROM @NLSNRatingStationCodes NLSC
			LEFT OUTER JOIN NLSNMarketStationMap NLSM ON NLSC.[StationCode] = NLSM.[NLSNStationID]
			where NLSM.[NLSNStationID] IS NULL
			--SELECT DISTINCT NLSC.Column2, 0
			--FROM @NLSNTSData NLSC
			--LEFT OUTER JOIN NLSNMarketStationMap NLSM ON NLSC.Column2 = NLSM.NLSNStationId
			--where NLSM.NLSNStationId IS NULL


			SELECT * FROM @NLSNNoStations

			INSERT INTO NLSNMarketStationMap
			(
				NLSNDMACode,
				[NLSNStationID],
				[NLSNStationName],
				[Tracked],
				[CreatedDT],
				[CreatedByID]
			)
			SELECT  @MarketCode, StationID, StationName, IsTracked, GETDATE(), 1
			FROM @NLSNNoStations			

			INSERT INTO @NLSNRatingData
			(
				StationID,
				AirDate,
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
			dateadd(s,59,dateadd(mi,14,Column4)), -- add 14 minutes, 59 seconds to end time
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
			FROM @NLSNTSData
			WHERE Column1 = '08'
			--AND Column8 LIKE '%' + RTRIM(LTRIM(@Region))+ '%'
			AND COLUMN2 IN (SELECT [NLSNStationID]  FROM NLSNMarketStationMap where Tracked = 1 and NLSNDMACode = @MarketCode)
			
			INSERT INTO NLSNSpotRating
			(
				[TVStationID],
				[AirDate],
				[StartTime],
				[EndTime],
				[HouseHold],
				[c2_5],	
				[c6_11],
				[m12_14],
				[m15_17],
				[m18_20],	
				[m21_24],
				[m25_34],
				[m35_49],
				[m50_54],
				[m55_64],
				[m65P],
				[f12_14],
				[f15_17],
				[f18_20],
				[f21_24],
				[f25_34],
				[f35_49],
				[f50_54],
				[f55_64],
				[f65P]
			)
			SELECT 
				(SELECT [TVStationID] FROM NLSNMarketStationMap WHERE [NLSNStationID] = StationID),
				AirDate,
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
		END

		SELECT @SpotRatingFileName = REPLACE(@SpotRatingFileName, '.txt', '.zip')
		UPDATE NLSNFTPLog
		SET [ProcessDT] = GETDATE(),
		[UnzipDT] = DATEADD(Minute, -1, GETDATE())
		WHERE FTPFileName = @SpotRatingFileName
		
		COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSNProcessSpotRatingFileData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;