 CREATE PROCEDURE [dbo].[sp_MultiMapGetApprovalQuery] 
  @OriginalPatternCode varchar(200), 
  @AdId int, 
  @MediaStream Varchar(20)    
 AS  
 	BEGIN	 
 		DECLARE @TempREJMarkets TABLE  (OccurrenceID INT,OriginalPatternCode VARCHAR(200),FakePatternCode INT) 
 		DECLARE @TempForApproval TABLE  (OccurrenceID INT,OriginalPatternCode VARCHAR(200),MarketID INT, AirDate DateTime) 
 		BEGIN			 
 			INSERT INTO @TempREJMarkets (OccurrenceID,OriginalPatternCode,FakePatternCode) 
 			SELECT a.[OccurrenceDetailTVID] as OccurrenceID,b.OriginalPatternCode as OriginalPatternCode,b.[TVMMPRCodeCODE] as FakePatternCode		 
  
 			FROM [OccurrenceDetailTV] a, [TVMMPRCode] b, TVRecordingSchedule c, [TVStation] d  
 			WHERE b.OriginalPatternCode = @OriginalPatternCode 
 			AND c.[TVRecordingScheduleID] = a.[TVRecordingScheduleID] 
 			AND d.[TVStationID] = c.[TVStationID] 
 			AND b.[ApprovedMarketID] = d.[MarketID] 
 			AND b.Status = 'RE' 
 			AND a.[PRCODE] = b.OriginalPatternCode 
 			AND a.[FakePatternCODE] IS NULL 
 			AND (a.[AirDT] >= b.[EffectiveStartDT] OR b.[EffectiveStartDT] IS NULL) 
 			AND (a.[AirDT] <= b.[EffectiveEndDT] OR b.[EffectiveEndDT] IS NULL) 
 			AND a.[AdID] IS NULL 
 			AND b.[AdID] = @AdId 
 			AND b.MediaStream = @MediaStream 
 		END		 
 		BEGIN 
 			 
 			INSERT INTO @TempForApproval(OccurrenceID,OriginalPatternCode,MarketID,AirDate) 
 			SELECT a.[OccurrenceDetailTVID] as OccurrenceID,a.[PRCODE] as OriginalPatternCode,c.[MarketID] as MarketID,a.[AirDT] as AirDate 
 			FROM [OccurrenceDetailTV] a, TVRecordingSchedule b, [TVStation] c 
 			WHERE a.[PRCODE] = @OriginalPatternCode 
 			AND a.[AdID] IS NULL 
 			AND b.[TVRecordingScheduleID] = a.[TVRecordingScheduleID] 
 			AND c.[TVStationID] = b.[TVStationID] 
 			AND a.[OccurrenceDetailTVID] NOT IN (SELECT OccurrenceID FROM @TempREJMarkets) 
 			IF (@@ROWCOUNT > 0) 
 					SELECT b.[Descrip] as Market,b.[MarketID] as MarketId, 
 					CONVERT(VARCHAR(10), dateadd(day, -30, MIN(a.AirDate)), 110)  as MinAirDate,  
 					CONVERT(VARCHAR(10),  MAX(a.AirDate), 110)   as MaxAirDate	 
 					FROM @TempForApproval a, [Market] b 
 					WHERE b.[MarketID] = a.MarketID 
 					GROUP BY b.[MarketID], b.[Descrip] 
 			SELECT OccurrenceID,OriginalPatternCode,MarketID,AirDate FROM @TempForApproval 
 		END 
 	END