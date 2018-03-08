-- =============================================
-- Author:		Ashanie Cole
-- Create date:	October 2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionMultiMap]
	@Adid as INT,
	@OriginalPatternCode varchar(50),
	@AdvertiserID INT,
	@PromptResult VARCHAR(50),
	@UserId INT
AS
BEGIN

BEGIN try  
    
    BEGIN TRANSACTION
      
    DECLARE @MultiMap BIT = 0
    DECLARE @mediastream VARCHAR(50)
    DECLARE @ScoreQ INT
    DECLARE @LanguageID INT

    SELECT @mediastream = configurationid 
        FROM   [Configuration] 
        WHERE  systemname = 'ALL' 
                AND componentname = 'media stream' 
                AND valuetitle = 'Television' 

    --1.3	Addendum to Universal Search:  TV Pattern qualified for Multi Map
    --The steps to apply in order when selected TV Pattern is qualified for Multi Map:
    --	Check Original Pattern, AdID and Air Dates for approved ALL Markets in TVMMPRCode and map matching Occurrences accordingly.
    --Check if Ad has been approved for ALL Market:

    PRINT '1.3'

    SELECT a.OccurrenceDetailTVID as OccurrenceID, 
	    b.OriginalPatternCode as OriginalPatternCode,
    a.FakePatternCODE as FakePatternCode
    INTO #TempALLMarket
    FROM OccurrenceDetailTV a, TVMMPRCode b	-- XXX is for TV
    WHERE b.OriginalPatternCode = @OriginalPatternCode
    AND b.ApprovedForAllMarkets = 1
    AND b.Status = 'AP'		-- approved for all Market
    AND a.PRCODE = b.OriginalPatternCode
    AND a.FakePatternCODE IS NULL
    AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
    AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
    AND a.AdID IS NULL		-- not mapped
    AND b.AdID = @Adid
    AND b.MediaStream = @mediastream
    -- check of MediaStream is for flexibility in the future

    IF @@ROWCOUNT > 0	-- matching approved FakePatterns
    BEGIN
    
    PRINT 'No need to create PatternMaster'

	   -- No need to create PatternMaster since a Pattern with the 
	   --FakePatternCode is expected to exist.
	   UPDATE OccurrenceDetailTV		-- XXX is for TV
		   SET AdID = @Adid,
			   [PatternID] = c.PatternID
	   FROM OccurrenceDetailTV a, #TempALLMarket b, Pattern c
	   WHERE a.OccurrenceDetailTVID = b.OccurrenceID
	   AND c.CreativeSignature = b.OriginalPatternCode
	   -- for All Markets, referenced is the OriginalPatternCode’s PatternMaster.
    END

    PRINT 'Check Original Pattern - specific Market'

    --	Check Original Pattern, AdID, Maket and Air Dates for approved individual Markets in TVMMPRCode and map matching Occurrences accordingly.
    --Check if Ad has been approved for specific Market/Date Range combination:
    SELECT a.OccurrenceDetailTVID as OccurrenceID,
	    b.OriginalPatternCode as OriginalPatternCode,
	    a.FakePatternCODE as FakePatternCode
    INTO #TempIndMarket
    FROM OccurrenceDetailTV a, TVMMPRCode b, TVRecordingSchedule c, TVStation d		-- XXX is for TV MTTVStationMaster
    WHERE b.OriginalPatternCode = @OriginalPatternCode
    AND c.TVRecordingScheduleID = a.TVRecordingScheduleID
    AND d.MarketID = c.TVStationID
    AND b.ApprovedMarketID = d.MarketID
    AND b.Status = 'UA'		-- approved for individual Market
    AND a.PRCODE = b.OriginalPatternCode
    AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
    AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
    AND a.AdID IS NULL		-- not mapped
    AND b.AdID = @Adid
    AND b.MediaStream = @mediastream
    -- check of MediaStream is for flexibility in the future

    IF (@@ROWCOUNT > 0)	-- matching approved Fake Patterns
    BEGIN
    
    PRINT 'No need to create PatternMaster'

	   -- No need to create PatternMaster since a Pattern with the 
	   --FakePatternCode is expected to exist.
	   UPDATE OccurrenceDetailTV
		   SET AdID = @Adid,
			   PRCODE = b.FakePatternCode,
			   [PatternID] = c.PatternID
	   FROM OccurrenceDetailTV a, #TempIndMarket b, Pattern c
	   WHERE a.OccurrenceDetailTVID = b.OccurrenceID
	   AND c.CreativeSignature = b.FakePatternCode
	   -- for specific Market, references is the FakePatternCode’s PatternMaster.
    END
    
    PRINT 'Check Original Pattern - TempREJMarkets'

    --	Check Original Pattern, AdID, Maket and Air Dates for REJECTED Markets in TVMMPRCode and reject mapping of these Occurrences.
    --Check if Ad has been REJECTED for specific Market/Date Range combination:
    -- This is simply to record in TempREJMarkets what Occurrences are REJECTED
    SELECT a.OccurrenceDetailTVID as OccurrenceID,
	    b.OriginalPatternCode as OriginalPatternCode,
	    a.FakePatternCODE as FakePatternCode
    INTO #TempREJMarkets
    FROM OccurrenceDetailTV a, TVMMPRCode b, TVRecordingSchedule c, TVStation d		-- XXX is for TV
    WHERE b.OriginalPatternCode = @OriginalPatternCode
    AND c.TVRecordingScheduleID = a.TVRecordingScheduleID
    AND d.TVStationID = c.TVStationID
    AND b.ApprovedMarketID = d.MarketID
    AND b.Status = 'RE'		-- Rejected for individual Market
    AND a.PRCODE = b.OriginalPatternCode
    AND a.FakePatternCODE IS NULL
    AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
    AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
    AND a.AdID IS NULL		-- not mapped
    AND b.AdID = @Adid
    AND b.MediaStream = @mediastream
    -- check of MediaStream is for flexibility in the future

    PRINT 'Check remaining unmapped Occurrences'

    --	Check remaining unmapped Occurrences of the Original Pattern for user to apply whether they are to be APPROVED or REJECTED for their Markets.
    SELECT a.OccurrenceDetailTVID as OccurrenceID, 
    a.PRCODE as OriginalPatternCode,
    c.MarketID as MarketID,
    a.AirDT as AirDT,
    a.FakePatternCODE
    INTO #TempForApproval
    FROM OccurrenceDetailTV a, TVRecordingSchedule b, TVStation c
    -- XXX is for TV
    WHERE a.PRCODE = @OriginalPatternCode
    AND a.AdID IS NULL
    AND b.TVRecordingScheduleID = a.TVRecordingScheduleID
    AND c.TVStationID = b.TVStationID
    AND a.OccurrenceDetailTVID NOT IN (SELECT OccurrenceID FROM #TempREJMarkets)
-- #TempREJMarkets contains the rejected Occurrences

--IF @@ROWCOUNT > 0
--BEGIN
----	PROMPT 3 options:
----a)	This Ad can air in this new geographic area on these dates.
----b)	This Ad can air in any geographic area on these dates.
----c)	Reject Ad in this new geographic area on these dates.
--END

--	When For Approval Occurrences are under single Market only and the OriginalPatternCode is with no entry at all in TVMMPRCode, automatically to apply is Option 1.


    --1.4	Addendum to Universal Search:  Approve Geographic Area and Air Dates
    --This option is NOT applicable when Advertiser is with AdvertiserMarket.AllMarketIndicator = Yes.  Otherwise, apply the update below on select of this option:
    -- 1 – Create  entries in TVMMPRCode for their corresponding FakePatternCodes
    IF @PromptResult = 'CanAirThisGeo'
    BEGIN
	   
	   PRINT 'CanAirThisGeo'

	   IF (SELECT COUNT(*) FROM AdvertiserMarket
	   WHERE AdvertiserID = @AdvertiserID
	   AND AllMarketIndicator <> 1) > 0
	   BEGIN
		  INSERT INTO TVMMPRCode
			  (OriginalPatternCode,
			  TVMMPRCodeCODE,
			  AdID,
			  ApprovedForAllMarkets,
			  ApprovedMarketID,
			  [Status],
			  EffectiveEndDT,
			 EffectiveStartDT,
			 CreatedDT,
			 CreatedByID)
		  (SELECT OriginalPatternCode,
			 (SELECT MAX([TVMMPRCodeCODE]) + 1 FROM [TVMMPRCode] where [TVMMPRCodeCODE] not like '%[^0-9]%' ),
			 @Adid,
			 NULL,
			 MarketID,
			 'UA',			-- approved individual Market
			 NULL,			-- open ended date
			 DATEADD(DAY,-30, MIN(AirDT)), -- - 30 days
			 GETDATE(),
			 @UserId
		  FROM #TempForApproval
		  GROUP BY OriginalPatternCode)

		  -- 2 – Create entries in PatternMasterStaging for these new FakePatternCodes

		  SELECT @ScoreQ = ScoreQ, 
			  @LanguageID = LanguageID
		  FROM PatternStaging
		  where CreativeSignature=@OriginalPatternCode
		  --WHERE PatternStagingTVID=(select PatternStagingTVID from PatternTVStaging where CreativeSignature=@OriginalPatternCode)-- '<Original Pattern Code’s PK)'

	   PRINT 'INSERT INTO PatternStaging'

		  INSERT INTO PatternStaging
			  (--AdID,		-- remove this column since now using Staging table
		  CreativeStgID,
		  CreativeSignature,
		  ScoreQ,
		  LanguageID)
		  (SELECT DISTINCT --@Adid,
				  NULL,		-- No creative for this fake pattern initially
				  b.FakePatternCode,
				  @ScoreQ,	-- same as Original PR Code’s
				  @LanguageID	-- same as Original PR Code’s
			  FROM TVMMPRCode a, #TempForApproval b
			  WHERE a.OriginalPatternCode = b.OriginalPatternCode
			  AND a.ApprovedMarketID = b.MarketID
			  AND a.AdID = @Adid
			  AND (b.AirDT >= a.EffectiveStartDT OR a.EffectiveStartDT IS NULL)
			  AND (b.AirDT <= a.EffectiveEndDT OR a.EffectiveEndDT IS NULL)
			  AND (a.Status = 'UA')
		  )

		  -- remove original record – this is not reused since referenced creative is for a specific Market and applying the first Market for this record is NOT full proof.
		  --Using NO TAKE to logically delete a Pattern in the Staging table.

	   PRINT 'Using NO TAKE to logically delete a Pattern'

		  UPDATE PatternStaging
			  SET NoTakeReasonCode = 'Multi-Map'
		  where CreativeSignature=@OriginalPatternCode
		  --WHERE PatternStagingTVID = (select PatternStagingTVID from PatternTVStaging where CreativeSignature=@OriginalPatternCode) --'<Original Pattern Code’s PK>'

		  -- 4 – Update the OccurrenceDetails to complete the mapping to Ad and reference to the PatternMaster.
		  SELECT a.OccurrenceID as OccurrenceID,
			  a.FakePatternCode as FakePatternCode
		  INTO #TempOccurrence
		  FROM #TempForApproval a, TVMMPRCode b
		  WHERE b.OriginalPatternCode = a.OriginalPatternCode
		  AND b.ApprovedMarketID = a.MarketID
		  AND b.Status = 'UA'		-- approved for individual Market
		  AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
		  AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
		  AND b.AdID = @Adid
		  AND b.MediaStream = @mediastream	
		  -- check of MediaStream is for flexibility in the future
		  
		  IF (@@ROWCOUNT > 0)	-- matching approved Fake Patterns
		  BEGIN

			 PRINT 'Should not be auto indexed since they need to be indexed individually per Market'

			 -- Should not be auto indexed since they need to be indexed individually per Market
			 UPDATE OccurrenceDetailTV
				 SET --AdID = @Adid,
					 PRCODE = b.FakePatternCode
					 --PatternMasterID = c.PatternID
			 FROM OccurrenceDetailTV a, #TempOccurrence b --, Pattern c
			 WHERE a.OccurrenceDetailTVID = b.OccurrenceID
			 AND a.AdID IS NULL		-- not mapped
			 --AND c.CreativeSignature = b.FakePatternCode
			 -- for specific Market, references is the FakePatternCode’s PatternMaster.
		  END
	   END
    END
    --1.5	Addendum to Universal Search:  Approve for ALL Markets and Air Dates
    --This option is NOT applicable when Advertiser is with individual Markets for multi map.  
    
    PRINT '1.5'

    IF (SELECT COUNT(*) FROM AdvertiserMarket
    WHERE AdvertiserID = @AdvertiserID
    AND AllMarketIndicator = 0) <= 0 AND  @PromptResult = 'CanAirAnyGeo'
    BEGIN
    
	   PRINT 'CanAirAnyGeo'
	   --Otherwise, apply the update below on select of this option:
	   -- 1 – Create entries in TVMMPRCode for the ALL Market entry for this Ad and AirDTs
	   INSERT INTO TVMMPRCode
		   (OriginalPatternCode,
		   TVMMPRCodeCODE,
		   AdID,
		   ApprovedForAllMarkets,
		   ApprovedMarketID,
		   Status,
		   EffectiveEndDT,
	   EffectiveStartDT,
	   CreatedDT,
	   CreatedByID)
	   (SELECT OriginalPatternCode,
		  (SELECT MAX([TVMMPRCodeCODE]) + 1 FROM [TVMMPRCode] where [TVMMPRCodeCODE] not like '%[^0-9]%' ),
		  @Adid,
		  1,
		  NULL,
		  'AP',			-- approved ALL Markets
		  NULL,			-- open ended date
		  DATEADD(DAY,-30, MIN(AirDT)), -- - 30 days
		  GETDATE(),
		  @UserId
	   FROM #TempForApproval 		
	   -- understanding here is that there is only 1 original PR Code at a time in #TempForApproval
	   GROUP BY OriginalPatternCode)

	   -- 2 – Create entries in PatternMaster for the OriginalPatternCode
	   IF (SELECT COUNT(*) FROM Pattern
		   WHERE CreativeSignature = @OriginalPatternCode) = 0 
	   BEGIN
		  
		  PRINT 'No entry in PatternMaster table yet for the OriginalPatternCode'

		   -- No entry in PatternMaster table yet for the OriginalPatternCode
		  INSERT INTO Pattern
			  (AdID,
		  CreativeID,
		  CreativeSignature,
		  MediaStream,
		  [Status],
		  CreateDate,
		  CreateBy)
		  (SELECT DISTINCT @Adid,
			   NULL,
			   a.OriginalPatternCode,
			   @mediastream,'Valid',GETDATE(),@UserId
		   FROM TVMMPRCode a, #TempForApproval b
		   WHERE a.OriginalPatternCode = b.OriginalPatternCode
		   AND a.ApprovedForAllMarkets = 1
		   AND a.AdID = @Adid
		   AND (b.AirDT >= a.EffectiveStartDT OR a.EffectiveStartDT IS NULL)
		   AND (b.AirDT <= a.EffectiveEndDT OR a.EffectiveEndDT IS NULL)
		   AND (a.Status = 'AP'))
	   END

	   -- 3 - APPLY the update in CreativeMaster and CreativeDetail tables here.

	   -- 4 – Update the OccurrenceDetails to complete the mapping to Ad and reference to the PatternMaster.

	   SELECT a.OccurrenceID as OccurrenceID, 
	   a.FakePatternCode as FakePatternCode,
	   b.OriginalPatternCode
	   INTO #TempALLOccurrence
	   FROM #TempForApproval a, TVMMPRCode b
	   WHERE b.OriginalPatternCode = a.OriginalPatternCode
	   AND b.ApprovedForAllMarkets = 1
	   AND b.Status = 'AP'		-- approved for all Market
	   AND (a.AirDT >= b.EffectiveStartDT OR b.EffectiveStartDT IS NULL)
	   AND (a.AirDT <= b.EffectiveEndDT OR b.EffectiveEndDT IS NULL) 
	   AND b.AdID = @Adid
	   AND b.MediaStream = @mediastream
	   -- check of MediaStream is for flexibility in the future

	   IF @@ROWCOUNT > 0	-- matching approved FakePatterns
	   BEGIN
	   
	   PRINT 'matching approved FakePatterns'

	   -- No need to create PatternMaster since a Pattern with the 
	   --FakePatternCode is expected to exist.
	   UPDATE OccurrenceDetailTV
		   SET AdID = @Adid,
			   FakePatternCODE = NULL,
			   [PatternID] = c.PatternID
	   FROM OccurrenceDetailTV a, #TempALLMarket b, Pattern c
	   WHERE a.OccurrenceDetailTVID = b.OccurrenceID
	   AND a.AdID IS NULL		-- not mapped
	   AND c.CreativeSignature = b.OriginalPatternCode
	   -- for All Markets, referenced is the OriginalPatternCode’s PatternMaster.
	   END
    END

    --1.6	Addendum to Universal Search:  Reject Geographic Area and Air Dates
    --Apply the update below on select of this option:
    -- 1 – Create entries in TVMMPRCode for the Rejected Market entry for this Ad and AirDTs
    IF @PromptResult = 'RejectAd'
    BEGIN
    
	   PRINT 'RejectAd'

	   INSERT INTO TVMMPRCode
		   (OriginalPatternCode,
		   TVMMPRCodeCODE,
		   AdID,
		   ApprovedForAllMarkets,
		   ApprovedMarketID,
		   Status,
		   EffectiveEndDT,
		  EffectiveStartDT,
		  CreatedDT,
		  CreatedByID)
	   (SELECT OriginalPatternCode,
		  (SELECT MAX([TVMMPRCodeCODE]) + 1 FROM [TVMMPRCode] where [TVMMPRCodeCODE] not like '%[^0-9]%' ),
		  @Adid,
		  NULL,
		  MarketID,
		  'RE',			-- approved ALL Markets
		  NULL,			-- open ended date
		  DATEADD(DAY,-30, MIN(AirDT)), -- - 30 days
		  GETDATE(),
		  @UserId
	   FROM #TempForApproval	 	
	   -- understanding here is that there is only 1 original PR Code at a time in #TempForApproval
	   GROUP BY OriginalPatternCode)
    END
    PRINT 'END'
    COMMIT TRANSACTION
END try  
  
BEGIN catch  
    DECLARE @error   INT,  
		  @message VARCHAR(4000),  
		  @lineNo  INT  
  
    SELECT @error = Error_number(),@message = Error_message(),  
		  @lineNo = Error_line()  
  
    RAISERROR ('[sp_TelevisionMultiMap]: %d: %s',16,1,@error,@message,  
			 @lineNo);  
  
    ROLLBACK TRANSACTION  
END catch  

END