

CREATE PROC [dbo].[usp_TVCostCalculation] 
@runAsDateTime datetime = null
AS 
  BEGIN 
      SET NOCOUNT ON 
      BEGIN TRY 
		if @runAsDateTime is null
		begin
			set @runAsDateTime = GETDATE()
		end
	  -- Determine the day of the week and day part 
		SELECT OCCURRENCECLIENTFACINGTVID, 
		AIRSTARTTIME, 
		ADID, 
		   CASE   
				  WHEN DATENAME(DW,AIRDATE) = 'MONDAY' AND  CONVERT(VARCHAR(8),@runAsDateTime,108) < '06:00:00' THEN 'SAT-SUN'
				  WHEN DATENAME(DW,AIRDATE) = 'SATURDAY' AND  CONVERT(VARCHAR(8),@runAsDateTime,108) < '06:00:00' THEN 'MON-FRI' 
				  WHEN DATENAME(DW,AIRDATE) = 'MONDAY' AND  CONVERT(VARCHAR(8),@runAsDateTime,108) >= '06:00:00' THEN 'MON-FRI'
				  WHEN DATENAME(DW,AIRDATE) = 'SATURDAY' AND  CONVERT(VARCHAR(8),@runAsDateTime,108) >= '06:00:00' THEN 'SAT-SUN' 
				  WHEN DATENAME(DW,AIRDATE) IN ( 'TUESDAY', 'WEDNESDAY', 'THURSDAY','FRIDAY') THEN 'MON-FRI' 
				  WHEN DATENAME(DW,AIRDATE) = 'SUNDAY' THEN 'SAT-SUN' 
				  ELSE 'MON-FRI' 
		   END  AS DAYRANGE
			 INTO #TEMPDAYRANGE 
			 FROM [OccurrenceClientFacingTV] CF WHERE NOT EXISTS(
			 SELECT OCCURRENCECLIENTFACINGTVID 
				FROM [OccurrenceCostTV] CTV
				WHERE CTV.[OccurenceClientFacingTVID]=CF.OccurrenceClientFacingTVId) 

			 --Calulating the cost by length factor
			 
			 SELECT OCCURRENCECLIENTFACINGTVID,
			 rdp.[RadioDayPartID], TEMP.AdID, AdLength ,
			 CASE   
				  WHEN AdLength > 63 THEN (CONVERT(FLOAT,AdLength) / 60)* RSDP.RATE
				  WHEN AdLength >= 49 AND AdLength <= 63 THEN 1 * RSDP.RATE
				  WHEN AdLength >= 34 AND AdLength <= 48 THEN .95 * RSDP.RATE
				  WHEN AdLength >= 22 AND AdLength <= 33THEN .80 * RSDP.RATE
				  WHEN AdLength >= 17 AND AdLength <= 21THEN .60 * RSDP.RATE
				  WHEN AdLength >= 12 AND AdLength <= 16 THEN .50 * RSDP.RATE
				  WHEN AdLength >= 7 AND AdLength <= 11 THEN .40 * RSDP.RATE
				  WHEN AdLength >= 1 AND AdLength <= 6 THEN .33 * RSDP.RATE
			 ELSE 0 
		   END 
				  AS COST,
				  Rate,
				  null as CostModelId,
				  @runAsDateTime as CreateDTM,
				  1 as CreateBy,
				  null as ModifiedDTM,
				  null as ModifiedBy
				  INTO #TEMPADLENGTH
				  FROM #TEMPDAYRANGE TEMP 
			 INNER JOIN [RadioDayPart] RDP ON TEMP.DAYRANGE=RDP.[Day] INNER JOIN AD AD ON AD.ADID = TEMP.ADID 
			 INNER JOIN [RadioStationDayPartRate] RSDP ON RDP.[RadioDayPartID] = RSDP.RADIODAYPARTSID 
			 WHERE (cast (TEMP.AIRSTARTTIME as time) BETWEEN cast (STARTTIME as time) AND cast (ENDTIME as time)) 
			 AND (@runAsDateTime BETWEEN RSDP.EffectiveDateBegin and RSDP.EffectiveDateEnd)

			 -- Moving Cost records to OccurancecostTV Table

			 INSERT INTO [OccurrenceCostTV]
			 SELECT OCCURRENCECLIENTFACINGTVID,
			 [RadioDayPartID],
			 COST,
			Rate,
			 CostModelId,
			 CreateDTM,
			 CreateBy,
			 ModifiedDTM,
			 ModifiedBy
			 FROM #TEMPADLENGTH 
			 WHERE COST!=0
			
			-- Error log if length is < 1
			INSERT INTO [RadioLengthFactorErrorLog]
			SELECT OCCURRENCECLIENTFACINGTVID,
			ADID,
			AdLength ,
			@runAsDateTime
			FROM #TEMPADLENGTH 
			WHERE COST=0



			 -- Dropping temp tables
			 DROP TABLE #TEMPDAYRANGE
			 DROP TABLE #TEMPADLENGTH
			 --TRUNCATE TABLE OCCURRENCESCOSTTV

      END TRY 
      BEGIN CATCH 
          DECLARE @ERROR   INT,
                  @MESSAGE VARCHAR(4000),
                  @LINENO  INT
          SELECT @ERROR = ERROR_NUMBER(),
                 @MESSAGE = ERROR_MESSAGE(),
                 @LINENO = ERROR_LINE() RAISERROR ('usp_RadioCostCalculation: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO);
      END CATCH; 
  END;