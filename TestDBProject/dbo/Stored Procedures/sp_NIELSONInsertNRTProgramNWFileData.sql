-- ============================================= 
-- Author:    Govardhan 
-- Create date: 05/22/2015 
-- Description: Process Ingestion for Netwrok Program national weekly file. 
-- Query : 
/* 
exec sp_NIELSONInsertNRTProgramNWFileData '', 
*/ 
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_NIELSONInsertNRTProgramNWFileData] (@NIELSONINGNWData dbo.NIELSONINGNWDATA readonly) 
AS 
  BEGIN 
    SET nocount ON; 
    BEGIN try 
      BEGIN TRANSACTION 
      --INSERT PROGRAM DATA-- 
      TRUNCATE TABLE nlsnprogramscheduletemp; 
       
      INSERT INTO nlsnprogramscheduletemp 
                  ( 
                              [MarketID], 
                              channel, 
                              airdate, 
                              programname, 
                              starttime, 
                              endtime, 
                              [QuarterHourID], 
                              [CreatedDT], 
                              [CreatedByID] 
                  ) 
      SELECT 1[MARKETCODE], 
             filter.acnnetworkcode, 
             filter.airdate, 
             filter.programname, 
             filter.starttime, 
             filter.endtime, 
             ( 
                    SELECT QuarterHourID 
                    FROM   quarter_hours 
                    WHERE  Cast(CONVERT(DATETIME,Substring(filter.starttime,1,2)+':'+Substring(filter.starttime,3,2)) AS TIME) BETWEEN qtr_start_time AND    qtr_end_time ) [QUARTERHOURID], 
             Getdate()[CREATEDDATE], 
             1[CREATEDBY] 
      FROM   ( 
                    SELECT Substring(value,15,6)[ACNNETWORKCODE], 
                           Substring(value,44,7)[AIRDATE], 
                           Substring(value,86,4)[STARTTIME], 
                           Substring(value,278,4)[EVENTDURATION] , 
                           ( 
                                  SELECT Replace(CONVERT(VARCHAR(8), datevalue, 108), ':', '') 
                                  FROM   ( 
                                                SELECT Dateadd(second,-1,datevalue)[DATEVALUE] 
                                                FROM   ( 
                                                              SELECT Dateadd(minute,(CONVERT(INT,Substring(value,278,4))),Cast( ( Substring(Substring(value,86,4), 1, 2) + ':' + Substring(Substring(value,86,4), 3, 2) ) AS DATETIME ) ) AS datevalue) AS sub ) Filter)[ENDTIME] , 
                           Substring(value,115,25)[PROGRAMNAME] 
                    FROM   @NIELSONINGNWData PN 
                    WHERE  Substring(value,11,1)=0 
                    AND    Substring(value,42,2)=00 
                    AND    ( 
                                  Substring(value,97,1)=NULL 
                           OR     ( 
                                         Substring(value,97,1)='')) 
                    AND    Substring(value,85,1)='D' 
                    AND    Substring(value,1,2)='04' 
                    AND    CONVERT(INT,(Substring(value,86,4)))<2400 )AS filter 
      INSERT INTO nlsnprogramschedule 
                  ( 
                              [MarketID], 
                              channel, 
                              [AirDT], 
                              programname, 
                              starttime, 
                              endtime, 
                              [QuarterHourID], 
                              [CreatedDT], 
                              [CreatedByID] 
                  ) 
      SELECT marketid, 
             channel, 
             CONVERT(DATETIME,'20'+Substring(airdate,2,6))[AirDate], 
             programname, 
             Cast(CONVERT(DATETIME,Substring(starttime,1,2)+':'+Substring(starttime,3,2)) AS TIME)[StartTime], 
             Cast(CONVERT(DATETIME,Substring(endtime,1,2)  +':'+Substring(endtime,3,2)) AS TIME)[EndTime], 
             [QuarterHourID], 
             Getdate(), 
             1 
      FROM   ( 
                    SELECT 1[MarketID], 
                           channel, 
                           CASE 
                                  WHEN CONVERT(INT,starttime)<600 THEN CONVERT(VARCHAR(8),(CONVERT(INT,airdate)-1)) 
                                  ELSE airdate 
                           END AS [AIRDATE], 
                           programname, 
                           dbo.Nielsonroundoffstarttime(starttime) AS starttime, 
                           dbo.Nielsonroundoffendtime(endtime)     AS endtime, 
                           [QuarterHourID] 
                    FROM   nlsnprogramscheduletemp )SUB 
      --INSERT HOUSEHOLD AND DEMOGRAPHIC DATA-- 
      --Table variable to hold filtered household data. 
      DECLARE @HHFILTEREDDATA TABLE 
                                    ( 
                                                                  acnnetworkcode            VARCHAR(50), 
                                                                  airdate                   VARCHAR(50), 
                                                                  starttime                 VARCHAR(50), 
                                                                  endtime                   VARCHAR(50), 
                                                                  firstquarterhourduration  VARCHAR(50), 
                                                                  secondquarterhourduration VARCHAR(50), 
                                                                  hhfirst                   VARCHAR(50), 
                                                                  hhsecond                  VARCHAR(50), 
                                                                  halfhouridentifier        VARCHAR(50) 
                                    ); 
       
      --Table variable to hold filtered household calculated data. 
      DECLARE @HHCALCULATIONRESULT TABLE 
                                         ( 
                                                                            acnnetworkcode        VARCHAR(50), 
                                                                            airdate               VARCHAR(50), 
                                                                            halfhouridentifier    VARCHAR(50), 
                                                                            hhfirst               VARCHAR(50), 
                                                                            hhsecond              VARCHAR(50), 
                                                                            quarterhouridentifier VARCHAR(50), 
                                                                            starttime             VARCHAR(50) 
                                         ); 
       
      --Table variable to hold final household data. 
      DECLARE @HHFINALRESULT TABLE 
                                   ( 
                                                                acnnetworkcode        VARCHAR(50), 
                                                                airdate               VARCHAR(50), 
                                                                starttime             VARCHAR(50), 
                                                                endtime               VARCHAR(50), 
                                                                halfhouridentifier    VARCHAR(50), 
                                                                quarterhouridentifier VARCHAR(50), 
                                                                householdvalue        BIGINT 
                                   ); 
       
      --DUPLICATE TABLE 
      DECLARE @DOUBLE TABLE 
                            ( 
                                                  slno INT 
                            ); 
       
      INSERT INTO @DOUBLE 
                  ( 
                              slno 
                  ) 
      SELECT slno 
      FROM   ( 
                    SELECT 1[SlNo] 
                    UNION 
                    SELECT 2[SlNo] )AS filter; 
       
      ---DEMOGRAPHIC VARIABLES--- 
      DECLARE @DMFILTEREDDATA TABLE 
                                    ( 
                                                                  networkcode           VARCHAR(50), 
                                                                  airdate               VARCHAR(50), 
                                                                  starttime             VARCHAR(50), 
                                                                  endtime               VARCHAR(50), 
                                                                  quarterhouridentifier VARCHAR(50), 
                                                                  demographicgroupid    VARCHAR(50), 
                                                                  fc2_5                 VARCHAR(50), 
                                                                  fc6_8                 VARCHAR(50), 
                                                                  fc9_11                VARCHAR(50), 
                                                                  ft12_14               VARCHAR(50), 
                                                                  ft15_17               VARCHAR(50), 
                                                                  f18_20                VARCHAR(50), 
                                                                  f21_24                VARCHAR(50), 
                                                                  f25_29                VARCHAR(50), 
                                                                  f30_34                VARCHAR(50), 
                                                                  f35_39                VARCHAR(50), 
                                                                  f40_44                VARCHAR(50), 
                                                                  f45_49                VARCHAR(50), 
                                                                  f50_54                VARCHAR(50), 
                                                                  f55_64                VARCHAR(50), 
                                                                  f65plus               VARCHAR(50), 
                                                                  mc2_5                 VARCHAR(50), 
                                                                  mc6_8                 VARCHAR(50), 
                                                                  mc9_11                VARCHAR(50), 
                                                                  mt12_14               VARCHAR(50), 
                                                                  mt15_17               VARCHAR(50), 
                                                                  m18_20                VARCHAR(50), 
                                                                  m21_24                VARCHAR(50), 
                                                                  m25_29                VARCHAR(50), 
                                                                  m30_34                VARCHAR(50), 
                                                                  m35_39                VARCHAR(50), 
                                                                  m40_44                VARCHAR(50), 
                                                                  m45_49                VARCHAR(50), 
                                                                  m50_54                VARCHAR(50), 
                                                                  m55_64                VARCHAR(50), 
                                                                  m65plus               VARCHAR(50) 
                                    ); 
       
      DECLARE @DMCALCULATEDDATA TABLE 
                                      ( 
                                                                      networkcode           VARCHAR(50), 
                                                                      airdate               VARCHAR(50), 
                                                                      quarterhouridentifier VARCHAR(50), 
                                                                      demographicgroupid    VARCHAR(50), 
                                                                      fc2_5                 VARCHAR(50), 
                                                                      fc6_8                 VARCHAR(50), 
                                                                      fc9_11                VARCHAR(50), 
                                                                      ft12_14               VARCHAR(50), 
                                                                      ft15_17               VARCHAR(50), 
                                                                      f18_20                VARCHAR(50), 
                                                                      f21_24                VARCHAR(50), 
                                                                      f25_29                VARCHAR(50), 
                                                                      f30_34                VARCHAR(50), 
                                                                      f35_39                VARCHAR(50), 
                                                                      f40_44                VARCHAR(50), 
                                                                      f45_49                VARCHAR(50), 
                                                                      f50_54                VARCHAR(50), 
                                                                      f55_64                VARCHAR(50), 
                                                                      f65plus               VARCHAR(50), 
                                                                      mc2_5                 VARCHAR(50), 
                                                                      mc6_8                 VARCHAR(50), 
                                                                      mc9_11                VARCHAR(50), 
                                                                      mt12_14               VARCHAR(50), 
                                                                      mt15_17               VARCHAR(50), 
                                                                      m18_20                VARCHAR(50), 
                                                                      m21_24                VARCHAR(50), 
                                                                      m25_29                VARCHAR(50), 
                                                                      m30_34                VARCHAR(50), 
                                                                      m35_39                VARCHAR(50), 
                                                                      m40_44                VARCHAR(50), 
                                                                      m45_49                VARCHAR(50), 
                                                                      m50_54                VARCHAR(50), 
                                                                      m55_64                VARCHAR(50), 
                                                                      m65plus               VARCHAR(50) 
                                      ); 
       
      DECLARE @DEMOGRAPHICDIVIDER AS INT; 
      SET @DEMOGRAPHICDIVIDER=30; 
      ---INSERT HOUSEHOLD FILTERED DATA. 
      INSERT INTO @HHFILTEREDData 
                  ( 
                              acnnetworkcode, 
                              airdate, 
                              starttime, 
                              firstquarterhourduration, 
                              secondquarterhourduration, 
                              endtime, 
                              hhfirst, 
                              hhsecond, 
                              halfhouridentifier 
                  ) 
      SELECT Substring(value,15,6)[ACNNETWORKCODE], 
             Substring(value,44,7)[AIRDATE], 
             Substring(value,86,4)[STARTTIME], 
             Substring(value,254,6)[FIRSTQUARTERHOURDURATION], 
             Substring(value,303,6)[SECONDQUARTERHOURDURATION], 
             ''[ENDTIME], 
             Substring(value,260,9)[HHFIRST], 
             Substring(value,309,9)[HHSECOND], 
             Substring(value,81,2)[HalfHourIdentifier] 
      FROM   @NIELSONINGNWData PN 
      WHERE  Substring(value,11,1)=0 
      AND    Substring(value,42,2)=00 
      AND    ( 
                    Substring(value,97,1)=NULL 
             OR     ( 
                           Substring(value,97,1)='')) 
             --AND SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NPRHouseholdData','Half Hour Identifier'),ISNULL(DBO.GetEndIndexCntOfNLSNINGAttribute('NPRHouseholdData','Half Hour Identifier'),1))>0 
      AND    Substring(value,85,1)='H'; 
       
      --INSERT HOUSEHOLD CALCULATED DATA. 
      INSERT INTO @HHCALCULATIONRESULT 
                  ( 
                              acnnetworkcode, 
                              airdate, 
                              halfhouridentifier, 
                              hhfirst, 
                              hhsecond, 
                              quarterhouridentifier, 
                              starttime 
                  ) 
      SELECT acnnetworkcode, 
             airdate, 
             halfhouridentifier, 
             hhfirst, 
             hhsecond, 
             ( 
                    SELECT QuarterHourID 
                    FROM   quarter_hours 
                    WHERE  Cast(CONVERT(DATETIME,Substring(starttime,1,2)+':'+Substring(starttime,3,2)) AS TIME) BETWEEN qtr_start_time AND    qtr_end_time )[QUARTERHOURIDENTIFIER], 
             starttime 
      FROM   ( 
                      SELECT   cd.acnnetworkcode, 
                               cd.airdate, 
                               cd.halfhouridentifier, 
                               Count(*)[Count], 
                               (Sum(Isnull(CONVERT(BIGINT,cd.firstquarterhourduration),0) *Isnull(cd.hhfirst,0))/Sum(CONVERT(BIGINT,cd.firstquarterhourduration)))[HHFIRST], 
                               (Sum(Isnull(CONVERT(BIGINT,cd.secondquarterhourduration),0)*Isnull(cd.hhsecond,0))/Sum(CONVERT(BIGINT,cd.secondquarterhourduration)))[HHSECOND], 
                               ( 
                                      SELECT TOP 1 
                                             starttime 
                                      FROM   @HHFILTEREDData 
                                      WHERE  acnnetworkcode=cd.acnnetworkcode 
                                      AND    airdate=cd.airdate 
                                      AND    halfhouridentifier=cd.halfhouridentifier)[STARTTIME] 
                      FROM     @HHFILTEREDData CD 
                      WHERE    cd.firstquarterhourduration<>0 
                      AND      cd.secondquarterhourduration<>0 
                      AND      CONVERT(INT,cd.starttime)<2400 
                      GROUP BY acnnetworkcode, 
                               airdate, 
                               halfhouridentifier ) FILTER; 
       
      --INSERT FINAL HOUSE HOLD RESULT DATA. 
      INSERT INTO @HHFINALRESULT 
                  ( 
                              acnnetworkcode, 
                              airdate, 
                              starttime, 
                              endtime, 
                              halfhouridentifier, 
                              quarterhouridentifier, 
                              householdvalue 
                  ) 
      SELECT cr.acnnetworkcode, 
             cr.airdate, 
             CASE 
                    WHEN cd.slno=1 THEN cr.starttime 
                    WHEN cd.slno=2 THEN 
                           ( 
                                  SELECT Replace(CONVERT(VARCHAR(5), datevalue, 108), ':', '') 
                                  FROM   ( 
                                                SELECT Dateadd(minute,(CONVERT(INT,15)),Cast( ( Substring(cr.starttime, 1, 2) + ':' + Substring(cr.starttime, 3, 2) ) AS DATETIME ) ) AS datevalue) AS sub) 
             END [STARTTIME], 
             CASE 
                    WHEN cd.slno=1 THEN 
                           ( 
                                  SELECT Replace(CONVERT(VARCHAR(8), datevalue, 108), ':', '') 
                                  FROM   ( 
                                                SELECT Dateadd(second,59,datevalue)[DATEVALUE] 
                                                FROM   ( 
                                                              SELECT Dateadd(minute,(CONVERT(INT,14)),Cast( ( Substring(cr.starttime, 1, 2) + ':' + Substring(cr.starttime, 3, 2) ) AS DATETIME ) ) AS datevalue) AS sub ) Filter) 
                    WHEN cd.slno=2 THEN 
                           ( 
                                  SELECT Replace(CONVERT(VARCHAR(8), datevalue, 108), ':', '') 
                                  FROM   ( 
                                                SELECT Dateadd(second,59,datevalue)[DATEVALUE] 
                                                FROM   ( 
                                                              SELECT Dateadd(minute,(CONVERT(INT,29)),Cast( ( Substring(cr.starttime, 1, 2) + ':' + Substring(cr.starttime, 3, 2) ) AS DATETIME ) ) AS datevalue) AS sub ) Filter) 
             END [ENDTIME], 
             cr.halfhouridentifier,( 
             CASE 
                    WHEN cd.slno=1 THEN cr.quarterhouridentifier 
                    WHEN cd.slno=2 THEN cr.quarterhouridentifier+1 
             END)[QUARTERHOURIDENTIFIER] ,( 
             CASE 
                    WHEN cd.slno=1 THEN cr.hhfirst 
                    WHEN cd.slno=2 THEN cr.hhsecond 
             END)[HOUSEHOLDVALUE] 
      FROM   @HHCALCULATIONRESULT CR, 
             @DOUBLE CD 
      --INSERT FILTERED DEMOGRAPHIC DATA. 
      INSERT INTO @DMFILTEREDDATA 
                  ( 
                              networkcode, 
                              airdate, 
                              starttime, 
                              endtime, 
                              quarterhouridentifier, 
                              demographicgroupid, 
                              fc2_5, 
                              fc6_8, 
                              fc9_11, 
                              ft12_14, 
                              ft15_17, 
                              f18_20, 
                              f21_24, 
                              f25_29, 
                              f30_34, 
                              f35_39, 
                              f40_44, 
                              f45_49, 
                              f50_54, 
                              f55_64, 
                              f65plus, 
                              mc2_5, 
                              mc6_8, 
                              mc9_11, 
                              mt12_14, 
                              mt15_17, 
                              m18_20, 
                              m21_24, 
                              m25_29, 
                              m30_34, 
                              m35_39, 
                              m40_44, 
                              m45_49, 
                              m50_54, 
                              m55_64, 
                              m65plus 
                  ) 
      SELECT Substring(value,15,6)[NETWORKCODE], 
             Substring(value,44,7)[AIRDATE], 
             Substring(value,86,4)[STARTTIME], 
             ''[ENDTIME], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN 
                           ( 
                                  SELECT QuarterHourID 
                                  FROM   quarter_hours 
                                  WHERE  Cast(CONVERT(DATETIME,Substring((Substring(value,86,4)),1,2)+':'+ Substring((Substring(value,86,4)),3,2)) AS TIME) BETWEEN qtr_start_time AND    qtr_end_time ) 
                    WHEN Substring(value,92,3)='021' THEN 
                           ( 
                                  SELECT QuarterHourID+1 
                                  FROM   quarter_hours 
                                  WHERE  Cast(CONVERT(DATETIME,Substring((Substring(value,86,4)),1,2)+':'+ Substring((Substring(value,86,4)),3,2)) AS TIME) BETWEEN qtr_start_time AND    qtr_end_time ) 
             END [QUARTERHOURIDENTIFIER], 
             --SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NPRDemographicData','Quarter Hour Identifier'),ISNULL(DBO.GetEndIndexCntOfNLSNINGAttribute('NPRDemographicData','Quarter Hour Identifier'),1))[QUARTERHOURIDENTIFIER], 
             Substring(value,92,3)[DEMOGRAPHICGROUPID], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,116,9) 
             END [FC2_5], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,125,9) 
             END[FC6_8], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,134,9) 
             END[FC9_11], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,143,9) 
             END[FT12_14], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,152,9) 
             END[FT15_17], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,161,9) 
             END[F18_20], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,170,9) 
             END[F21_24], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,179,9) 
             END[F25_29], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,188,9) 
             END[F30_34], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,197,9) 
             END[F35_39], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,206,9) 
             END[F40_44], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,215,9) 
             END[F45_49], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,224,9) 
             END[F50_54], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,233,9) 
             END[F55_64], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,242,9) 
             END[F65PLUS], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,251,9) 
             END[MC2_5], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,260,9) 
             END[MC6_8], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,269,9) 
             END[MC9_11], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,278,9) 
             END[MT12_14], 
             CASE 
                    WHEN Substring(value,92,3)='001' THEN Substring(value,287,9) 
             END[MT15_17], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,116,9) 
             END[M18_20], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,125,9) 
             END[M21_24], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,134,9) 
             END[M25_29], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,143,9) 
             END[M30_34], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,152,9) 
             END[M35_39], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,161,9) 
             END[M40_44], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,170,9) 
             END[M45_49], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,179,9) 
             END[M50_54], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,188,9) 
             END[M55_64], 
             CASE 
                    WHEN Substring(value,92,3)='021' THEN Substring(value,197,9) 
             END[M65PLUS] 
      FROM   @NIELSONINGNWData 
      WHERE  Substring(value,11,1)=0 
      AND    Substring(value,42,2)=00 
      AND    ( 
                    Substring(value,97,1)=NULL 
             OR     ( 
                           Substring(value,97,1)='')) 
             --AND SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NPRDemographicData','Quarter Hour Identifier'),ISNULL(DBO.GetEndIndexCntOfNLSNINGAttribute('NPRDemographicData','Quarter Hour Identifier'),1))>0 
      AND    Substring(value,85,1)='P' 
             --AND CONVERT(INT, SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NPRDemographicData','Program Put Indicator'),ISNULL(DBO.GetEndIndexCntOfNLSNINGAttribute('NPRDemographicData','Program Put Indicator'),1)))=0; 
      AND    CONVERT(INT,Substring(value,86,4))<2400 
      --INSERT FILTERED DEMOGRAPHIC DATA. 
      INSERT INTO @DMCALCULATEDDATA 
                  ( 
                              networkcode, 
                              airdate, 
                              quarterhouridentifier, 
                              demographicgroupid, 
                              fc2_5, 
                              fc6_8, 
                              fc9_11, 
                              ft12_14, 
                              ft15_17, 
                              f18_20, 
                              f21_24, 
                              f25_29, 
                              f30_34, 
                              f35_39, 
                              f40_44, 
                              f45_49, 
                              f50_54, 
                              f55_64, 
                              f65plus, 
                              mc2_5, 
                              mc6_8, 
                              mc9_11, 
                              mt12_14, 
                              mt15_17, 
                              m18_20, 
                              m21_24, 
                              m25_29, 
                              m30_34, 
                              m35_39, 
                              m40_44, 
                              m45_49, 
                              m50_54, 
                              m55_64, 
                              m65plus 
                  ) 
      SELECT   dd.networkcode, 
               dd.airdate, 
               dd.quarterhouridentifier, 
               dd.demographicgroupid, 
               Sum(CONVERT(INT,Isnull(fc2_5,0)))  /@DEMOGRAPHICDIVIDER[FC2_5], 
               Sum(CONVERT(INT,Isnull(fc6_8,0)))  /@DEMOGRAPHICDIVIDER[FC6_8], 
               Sum(CONVERT(INT,Isnull(fc9_11,0))) /@DEMOGRAPHICDIVIDER[FC9_11], 
               Sum(CONVERT(INT,Isnull(ft12_14,0)))/@DEMOGRAPHICDIVIDER[FT12_14], 
               Sum(CONVERT(INT,Isnull(ft15_17,0)))/@DEMOGRAPHICDIVIDER[FT15_17], 
               Sum(CONVERT(INT,Isnull(f18_20,0))) /@DEMOGRAPHICDIVIDER[F18_20], 
               Sum(CONVERT(INT,Isnull(f21_24,0))) /@DEMOGRAPHICDIVIDER[F21_24], 
               Sum(CONVERT(INT,Isnull(f25_29,0))) /@DEMOGRAPHICDIVIDER[F25_29], 
               Sum(CONVERT(INT,Isnull(f30_34,0))) /@DEMOGRAPHICDIVIDER[F30_34], 
               Sum(CONVERT(INT,Isnull(f35_39,0))) /@DEMOGRAPHICDIVIDER[F35_39], 
               Sum(CONVERT(INT,Isnull(f40_44,0))) /@DEMOGRAPHICDIVIDER[F40_44], 
               Sum(CONVERT(INT,Isnull(f45_49,0))) /@DEMOGRAPHICDIVIDER[F45_49], 
               Sum(CONVERT(INT,Isnull(f50_54,0))) /@DEMOGRAPHICDIVIDER[F50_54], 
               Sum(CONVERT(INT,Isnull(f55_64,0))) /@DEMOGRAPHICDIVIDER[F55_64], 
               Sum(CONVERT(INT,Isnull(f65plus,0)))/@DEMOGRAPHICDIVIDER[F65PLUS], 
               Sum(CONVERT(INT,Isnull(mc2_5,0)))  /@DEMOGRAPHICDIVIDER[MC2_5], 
               Sum(CONVERT(INT,Isnull(mc6_8,0)))  /@DEMOGRAPHICDIVIDER[MC6_8], 
               Sum(CONVERT(INT,Isnull(mc9_11,0))) /@DEMOGRAPHICDIVIDER[MC9_11], 
               Sum(CONVERT(INT,Isnull(mt12_14,0)))/@DEMOGRAPHICDIVIDER[MT12_14], 
               Sum(CONVERT(INT,Isnull(mt15_17,0)))/@DEMOGRAPHICDIVIDER[MT15_17], 
               Sum(CONVERT(INT,Isnull(m18_20,0))) /@DEMOGRAPHICDIVIDER[M18_20], 
               Sum(CONVERT(INT,Isnull(m21_24,0))) /@DEMOGRAPHICDIVIDER[M21_24], 
               Sum(CONVERT(INT,Isnull(m25_29,0))) /@DEMOGRAPHICDIVIDER[M25_29], 
               Sum(CONVERT(INT,Isnull(m30_34,0))) /@DEMOGRAPHICDIVIDER[M30_34], 
               Sum(CONVERT(INT,Isnull(m35_39,0))) /@DEMOGRAPHICDIVIDER[M35_39], 
               Sum(CONVERT(INT,Isnull(m40_44,0))) /@DEMOGRAPHICDIVIDER[M40_44], 
               Sum(CONVERT(INT,Isnull(m45_49,0))) /@DEMOGRAPHICDIVIDER[M45_49], 
               Sum(CONVERT(INT,Isnull(m50_54,0))) /@DEMOGRAPHICDIVIDER[M50_54], 
               Sum(CONVERT(INT,Isnull(m55_64,0))) /@DEMOGRAPHICDIVIDER[M55_64], 
               Sum(CONVERT(INT,Isnull(m65plus,0)))/@DEMOGRAPHICDIVIDER[M65PLUS] 
      FROM     @DMFILTEREDDATA DD 
      GROUP BY dd.networkcode, 
               dd.airdate, 
               dd.quarterhouridentifier, 
               dd.demographicgroupid 
      --INSERT INTO FINAL RATING TABLE 
      INSERT INTO nlsnnetworkandcableprogramrating 
                  ( 
                              [StationID], 
                              [AirDT], 
                              starttime, 
                              endtime, 
                              household, 
                              national_fc2_5, 
                              national_fc6_8, 
                              national_fc9_11, 
                              national_ft12_14, 
                              national_ft15_17, 
                              national__f18_20, 
                              national_f21_24, 
                              national_f25_29, 
                              national_f30_34, 
                              national_f35_39, 
                              national_f40_44, 
                              national_f45_49, 
                              national_f50_54, 
                              national_f55_64, 
                              national_f65plus, 
                              national_mc2_5, 
                              national_mc6_8, 
                              national_mc9_11, 
                              national_mt12_14, 
                              national_mt15_17, 
                              national_m18_20, 
                              national_m21_24, 
                              national_m25_29, 
                              national_m30_34, 
                              national_m35_39, 
                              national_m40_44, 
                              national_m45_49, 
                              national_m50_54, 
                              national_m55_64, 
                              national_m65plus 
                  ) 
      SELECT     hr.acnnetworkcode, 
                 CONVERT(DATETIME,'20'+Substring(hr.airdate,2,6))[AirDate], 
                 Cast(CONVERT(DATETIME,Substring(hr.starttime,1,2)+':'+Substring(hr.starttime,3,2)) AS TIME)[StartTime], 
                 Cast(CONVERT(DATETIME,Substring(hr.endtime,1,2)  +':'+Substring(hr.endtime,3,2)+':'+Substring(hr.endtime,5,2)) AS TIME)[EndTime], 
                 householdvalue, 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN fc2_5 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     fc2_5 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [FC2_5], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN fc6_8 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     fc6_8 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [FC6_8] , 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN fc9_11 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     fc9_11 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [FC9_11] , 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN ft12_14 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     ft12_14 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [FT12_14] , 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN ft15_17 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     ft15_17 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [FT15_17], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f18_20 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f18_20 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F18_20], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f21_24 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f21_24 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F21_24], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f25_29 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f25_29 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F25_29], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f30_34 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f30_34 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F30_34], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f35_39 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f35_39 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F35_39], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f40_44 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f40_44 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F40_44], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f45_49 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f45_49 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F45_49], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f50_54 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f50_54 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F50_54], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f55_64 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f55_64 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F55_64], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN f65plus 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     f65plus 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [F65PLUS], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN mc2_5 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     mc2_5 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [MC2_5], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN mc6_8 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     mc6_8 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [MC6_8], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN mc9_11 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     mc9_11 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [MC9_11], 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN mt12_14 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     mt12_14 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END mt12_14, 
                 CASE 
                            WHEN dd.demographicgroupid='001' THEN mt15_17 
                            WHEN dd.demographicgroupid='021' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     mt15_17 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier-1)) 
                 END [MT15_17], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m18_20 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m18_20 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M18_20], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m21_24 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m21_24 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M21_24], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m25_29 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m25_29 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M25_29], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m30_34 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m30_34 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M30_34], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m35_39 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m35_39 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M35_39], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m40_44 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m40_44 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M40_44], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m45_49 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m45_49 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M45_49], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m50_54 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m50_54 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M50_54] , 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m55_64 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m55_64 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M55_64], 
                 CASE 
                            WHEN dd.demographicgroupid='021' THEN m65plus 
                            WHEN dd.demographicgroupid='001' THEN 
                                       ( 
                                              SELECT TOP 1 
                                                     m65plus 
                                              FROM   @DMCALCULATEDDATA 
                                              WHERE  networkcode=hr.acnnetworkcode 
                                              AND    airdate=hr.airdate 
                                              AND    quarterhouridentifier=(dd.quarterhouridentifier+1)) 
                 END [M65PLUS] 
                 --FC2_5,FC6_8,FC9_11,FT12_14,FT15_17,F18_20, 
                 --F21_24,F25_29,F30_34,F35_39,F40_44,F45_49,F50_54,F55_64,F65PLUS,MC2_5,MC6_8,MC9_11, 
                 --MT12_14,MT15_17,M18_20,M21_24,M25_29,M30_34,M35_39,M40_44,M45_49,M50_54,M55_64,M65PLUS 
      FROM       @HHFINALRESULT HR 
      INNER JOIN @DMCALCULATEDDATA DD 
      ON         dd.networkcode=hr.acnnetworkcode 
      AND        dd.airdate=hr.airdate 
      AND        hr.quarterhouridentifier=dd.quarterhouridentifier 
      ORDER BY   hr.acnnetworkcode, 
                 hr.airdate, 
                 hr.starttime 
      SELECT Count(*)[ImportedRecCount] 
      FROM   nlsnnetworkandcableprogramrating 
      --  WHERE  AirDate = @BatchID 
      COMMIT TRANSACTION 
    END try 
    BEGIN catch 
      DECLARE @error INT, 
        @message     VARCHAR(4000), 
        @lineNo      INT 
      SELECT @error = Error_number(), 
             @message = Error_message(), 
             @lineNo = Error_line() RAISERROR ('sp_NIELSONInsertNRTProgramNWFileData: %d: %s',16,1,@error,@message, @lineNo ); 
       
      ROLLBACK TRANSACTION 
    END catch; 
  END;