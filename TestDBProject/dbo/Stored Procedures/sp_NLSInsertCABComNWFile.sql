		
-- =============================================   
-- Author:    Govardhan   
-- Create date: 06/10/2015   
-- Description: Process Ingestion for Cable Commercial national weekly file.  
-- Query :   
/*  
exec sp_NLSInsertCABComNWFile '',  

*/ 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_NLSInsertCABComNWFile] (@NIELSONINGNWData dbo.NIELSONINGNWData 
readonly) 
AS 
  BEGIN 
     -- SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

        --Table variable to hold final household data. 
DECLARE @HHFINALRESULT TABLE 
  ( 
     acnprogramcode VARCHAR(50), 
     telecastnumber VARCHAR(50), 
     acnnetworkcode VARCHAR(50), 
     airdate        VARCHAR(50), 
     starttime      VARCHAR(50), 
     endtime        VARCHAR(50), 
     householdvalue BIGINT 
  ); 

INSERT INTO @HHFINALRESULT 
            (acnprogramcode, 
             telecastnumber, 
             acnnetworkcode, 
             airdate, 
             starttime, 
             endtime, 
             householdvalue) 
--PROGRAM AND HOUSEHOLD DATA. 
SELECT acnprogramcode, 
       telecastnumber, 
       acnnetworkcode, 
       airdate, 
       CASE 
         WHEN qtr_schedule_id = 1 THEN starttime 
         ELSE (SELECT Replace(CONVERT(VARCHAR(6), datevalue, 108), ':', '') 
               FROM   (SELECT Dateadd(minute, ( CONVERT(INT, ( ( 
                                                qtr_schedule_id - 1 ) 
                                                               * 15 )) 
                                              ), Cast 
                                      (( 
                                              Substring(starttime, 1, 2) + ':' 
                                              + 
                              Substring(starttime, 3, 2) ) AS DATETIME)) AS 
                              DATEVALUE) 
                      Filter) 
       END            [STARTTIME], 
       (SELECT Replace(CONVERT(VARCHAR(8), datevalue, 108), ':', '') 
        FROM   (SELECT Dateadd(second, -1, datevalue)[DATEVALUE] 
                FROM   (SELECT Dateadd(minute, ( 
                               CONVERT(INT, ( ( qtr_schedule_id ) * 
                                              15 )) ), 
                               Cast( 
                                               ( Substring(starttime, 1, 2) + 
                                                 ':' 
                                                 + 
                               Substring(starttime, 3, 2) ) AS DATETIME)) AS 
                               DATEVALUE) 
                       AS SUB) 
               Filter)[ENDTIME], 
       householdvalue 
FROM   (SELECT DISTINCT 
Substring(value, 21, 10) 
[ACNPROGRAMCODE], 
          Substring(value, 58, 10) 
                 [TELECASTNUMBER], 
          Substring(value, 15, 6) 
                 [ACNNETWORKCODE], 
          Substring(value, 44, 7) 
                 [AIRDATE], 
dbo.Nielsonroundoffstarttime(Substring(value, 86, 4))   [STARTTIME], 
dbo.Nielsonroundoffendtime((SELECT Replace(CONVERT(VARCHAR(8), 
                                           datevalue, 108), 
                                   ':', '') 
                            FROM   (SELECT Dateadd(second, -1, 
                                           datevalue) 
                                           [DATEVALUE] 
                                    FROM   (SELECT Dateadd( 
                                           minute, ( 
                                   CONVERT(INT, Substring(value 
                                                , 
                                                278, 4)) 
                                                   ), Cast 
                                   (( 
Substring(Substring(value, 
86, 4), 1, 2) 
+ ':' 
+ 
Substring( 
                                   Substring(value, 86, 4), 3, 2 
                                    ) ) AS DATETIME)) AS 
                                   DATEVALUE) AS 
                                           SUB) Filter)) 
[ENDTIME], 
          Substring(value, 337, 9) 
[HOUSEHOLDVALUE], 
          dbo.Nlsgetminutesfromtime(Substring(value, 86, 4), (SELECT 
          Replace(CONVERT(VARCHAR(8), datevalue, 108), ':', '') 
                                                              FROM 
          (SELECT Dateadd(second, -1, datevalue)[DATEVALUE] 
           FROM   (SELECT Dateadd(minute, ( CONVERT(INT, Substring(value, 
                                                         278, 4)) 
                                          ), Cast 
                          (( 
                                          Substring(Substring(value, 86, 
                                          4), 1, 2) 
                                          + ':' 
                                          + 
                                          Substring( 
                          Substring(value, 86, 4), 3, 2) ) AS DATETIME)) 
                          AS 
                          DATEVALUE) AS 
                  SUB) Filter)) 
[RECORDSCOUNT] 
        FROM   @NIELSONINGNWData 
        WHERE  Substring(value, 11, 1) = 0 
               AND Substring(value, 42, 2) = 00 
			   AND Substring(value, 81, 2) = 00
               AND Substring(value, 1, 2) = '06' 
               AND Substring(value, 85, 1) = 'C' 
               AND CONVERT(INT, ( Substring(value, 86, 4) )) < 2400)MAIN 
       CROSS JOIN quarter_hours QH 
WHERE  QH.qtr_schedule_id <= recordscount 
ORDER  BY acnprogramcode, 
          telecastnumber, 
          airdate, 
          starttime, 
          qtr_schedule_id 

INSERT INTO NLSNNetworkAndCableComRating([NLSNNetworkAndCableComRatingID],[StationID],[AirDT],StartTime,EndTime,HouseHold,National_FC2_5,National_FC6_8,National_FC9_11,National_FT12_14,National_FT15_17,National__F18_20,
		National_F21_24,National_F25_29,National_F30_34,National_F35_39,National_F40_44,National_F45_49,National_F50_54,National_F55_64,National_F65PLUS,National_MC2_5,National_MC6_8,National_MC9_11,
		National_MT12_14,National_MT15_17,National_M18_20,National_M21_24,National_M25_29,National_M30_34,National_M35_39,National_M40_44,National_M45_49,National_M50_54,National_M55_64,National_M65PLUS)
		 
SELECT NewID(), MAIN.acnnetworkcode, 
       convert(datetime,'20'+substring(MAIN.airdate,2,6))[AirDate],
	   cast(convert(datetime,SUBSTRING(HR.starttime,1,2)+':'+SUBSTRING(HR.starttime,3,2)) as time)[StartTime],
	   cast(convert(datetime,SUBSTRING(HR.endtime,1,2)+':'+SUBSTRING(HR.endtime,3,2)+':'+SUBSTRING(HR.endtime,5,2)) as time)[EndTime],
	   HR.householdvalue, 
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
FROM   (SELECT acnprogramcode, 
               telecastnumber, 
               acnnetworkcode, 
               airdate, 
               Max(Isnull(fc2_5, 0))  [FC2_5], 
               Max(Isnull(fc6_8, 0))  [FC6_8], 
               Max(Isnull(fc9_11, 0)) [FC9_11], 
               Max(Isnull(ft12_14, 0))[FT12_14], 
               Max(Isnull(ft15_17, 0))[FT15_17], 
               Max(Isnull(f18_20, 0)) [F18_20], 
               Max(Isnull(f21_24, 0)) [F21_24], 
               Max(Isnull(f25_29, 0)) [F25_29], 
               Max(Isnull(f30_34, 0)) [F30_34], 
               Max(Isnull(f35_39, 0)) [F35_39], 
               Max(Isnull(f40_44, 0)) [F40_44], 
               Max(Isnull(f45_49, 0)) [F45_49], 
               Max(Isnull(f50_54, 0)) [F50_54], 
               Max(Isnull(f55_64, 0)) [F55_64], 
               Max(Isnull(f65plus, 0))[F65PLUS], 
               Max(Isnull(mc2_5, 0))  [MC2_5], 
               Max(Isnull(mc6_8, 0))  [MC6_8], 
               Max(Isnull(mc9_11, 0)) [MC9_11], 
               Max(Isnull(mt12_14, 0))[MT12_14], 
               Max(Isnull(mt15_17, 0))[MT15_17], 
               Max(Isnull(m18_20, 0)) [M18_20], 
               Max(Isnull(m21_24, 0)) [M21_24], 
               Max(Isnull(m25_29, 0)) [M25_29], 
               Max(Isnull(m30_34, 0)) [M30_34], 
               Max(Isnull(m35_39, 0)) [M35_39], 
               Max(Isnull(m40_44, 0)) [M40_44], 
               Max(Isnull(m45_49, 0)) [M45_49], 
               Max(Isnull(m50_54, 0)) [M50_54], 
               Max(Isnull(m55_64, 0)) [M55_64], 
               Max(Isnull(m65plus, 0))[M65PLUS] 
        FROM   (SELECT DISTINCT Substring(value, 21, 10)[ACNPROGRAMCODE], 
                       Substring(value, 58, 10)[TELECASTNUMBER], 
                       Substring(value, 15, 6) [ACNNETWORKCODE], 
                       Substring(value, 44, 7) [AIRDATE], 
                       Substring(value, 86, 4) [STARTTIME], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN (SELECT 
                         qtr_schedule_id 
                                                                    FROM 
                         quarter_hours 
                                                                    WHERE 
                         Cast(CONVERT(DATETIME, 
                              Substring((Substring( 
                              value, 86, 4)), 1, 2) 
                              + ':' 
                              + Substring((Substring( 
                              value, 86, 4)), 3, 2)) 
                              AS 
                              TIME) BETWEEN StartTime and EndTime) 
                         WHEN Substring(value, 92, 3) = '021' THEN (SELECT 
                         qtr_schedule_id + 1 
                                                                    FROM 
                         quarter_hours 
                                                                    WHERE 
                         Cast(CONVERT(DATETIME, 
                              Substring((Substring( 
                              value, 86, 4)), 1, 2) 
                              + ':' 
                              + Substring((Substring( 
                              value, 86, 4)), 3, 2)) 
                              AS 
                              TIME) BETWEEN StartTime and EndTime) 
                       END                     [QUARTERHOURIDENTIFIER], 
                       --SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NWNCRDemographicData','Quarter Hour Identifier'),ISNULL(DBO.GetEndIndexCntOfNLSNINGAttribute('NWNCRDemographicData','Quarter Hour Identifier'),1))[QUARTERHOURIDENTIFIER], 
                       Substring(value, 92, 3) [DEMOGRAPHICGROUPID], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 116, 9) 
                       END                     [FC2_5], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 125, 9) 
                       END                     [FC6_8], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 134, 9) 
                       END                     [FC9_11], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 143, 9) 
                       END                     [FT12_14], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 152, 9) 
                       END                     [FT15_17], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 161, 9) 
                       END                     [F18_20], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 170, 9) 
                       END                     [F21_24], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 179, 9) 
                       END                     [F25_29], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 188, 9) 
                       END                     [F30_34], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 197, 9) 
                       END                     [F35_39], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 206, 9) 
                       END                     [F40_44], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 215, 9) 
                       END                     [F45_49], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 224, 9) 
                       END                     [F50_54], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 233, 9) 
                       END                     [F55_64], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 242, 9) 
                       END                     [F65PLUS], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 251, 9) 
                       END                     [MC2_5], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 260, 9) 
                       END                     [MC6_8], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 269, 9) 
                       END                     [MC9_11], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 278, 9) 
                       END                     [MT12_14], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '001' THEN 
                         Substring(value, 287, 9) 
                       END                     [MT15_17], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 116, 9) 
                       END                     [M18_20], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 125, 9) 
                       END                     [M21_24], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 134, 9) 
                       END                     [M25_29], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 143, 9) 
                       END                     [M30_34], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 152, 9) 
                       END                     [M35_39], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 161, 9) 
                       END                     [M40_44], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 170, 9) 
                       END                     [M45_49], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 179, 9) 
                       END                     [M50_54], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 188, 9) 
                       END                     [M55_64], 
                       CASE 
                         WHEN Substring(value, 92, 3) = '021' THEN 
                         Substring(value, 197, 9) 
                       END                     [M65PLUS] 
                FROM   @NIELSONINGNWData 
                WHERE  Substring(value, 11, 0) = 0 
                       AND Substring(value, 42, 2) = 00 
					   AND Substring(value, 81, 2) = 00 
                       AND Substring(value, 1, 2) = '06' 
                       AND Substring(value, 85, 1) = 'P'
                       AND CONVERT(INT, Substring(value, 86, 4)) < 2400) FILTER 
        GROUP  BY acnprogramcode, 
                  telecastnumber, 
                  acnnetworkcode, 
                  airdate)MAIN 
       INNER JOIN @HHFINALRESULT HR 
               ON HR.telecastnumber = MAIN.telecastnumber 
                  AND HR.acnprogramcode = MAIN.acnprogramcode 
                  AND HR.airdate = MAIN.airdate 
ORDER  BY HR.acnprogramcode, 
          HR.telecastnumber, 
          HR.airdate, 
          HR.starttime  

          SELECT Count(*)[ImportedRecCount] 
          FROM   [NLSNNetworkAndCableComRating]
          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSInsertCABComNWFile: %d: %s',16,1,@error,@message, 
                     @lineNo 
          ); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;