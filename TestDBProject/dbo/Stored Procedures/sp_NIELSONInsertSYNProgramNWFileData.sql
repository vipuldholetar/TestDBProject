﻿-- =============================================    
-- Author:    Govardhan    
-- Create date: 05/22/2015    
-- Description: Process Ingestion for Syndication Program national weekly file.   
-- Query :    
/*   

exec sp_NIELSONInsertSYNProgramNWFileData '',   

*/ 
-- =============================================    
CREATE PROCEDURE [dbo].[sp_NIELSONInsertSYNProgramNWFileData] (@NIELSONINGNWData 
dbo.NIELSONINGNWDATA readonly) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          --Table variable to hold filtered PROGRAM data. 
          DECLARE @PGFILTEREDData TABLE 
            ( 
               acnprogramcode    VARCHAR(50), 
               airdate           VARCHAR(50), 
               programname       VARCHAR(250), 
               ratingsrecordscnt INT, 
               startdate         VARCHAR(50), 
               enddate           VARCHAR(50), 
               startdatetime     DATETIME 
            ); 
          --Table variable to hold FINAL PROGRAM data. 
          DECLARE @PGFINALData TABLE 
            ( 
               acnprogramcode VARCHAR(50), 
               airdate        VARCHAR(50), 
               programname    VARCHAR(250), 
               startdate      VARCHAR(50), 
               enddate        VARCHAR(50), 
               airdatetime    DATETIME 
            ); 
          --Table variable to hold filtered household data. 
          DECLARE @HHFINALData TABLE 
            ( 
               acnprogramcode VARCHAR(50), 
               airdate        VARCHAR(50), 
               household      BIGINT 
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

          DECLARE @DEMOGRAPHICDIVIDER AS INT; 

          SET @DEMOGRAPHICDIVIDER=30; 

          --INSERT INTO TEMP PROGRAM DATA . 
          INSERT INTO @PGFILTEREDData 
                      (acnprogramcode, 
                       airdate, 
                       programname, 
                       ratingsrecordscnt, 
                       startdate, 
                       enddate, 
                       startdatetime) 
          SELECT acnprogramcode, 
                 airdate, 
                 programname, 
                 dbo.Nielsongetsumofairdate(airdate)[RATINGSRECORDSCNT], 
                 startdate, 
                 enddate, 
                 startdatetime 
          FROM   (SELECT DISTINCT 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'ACN Program Code'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'ACN Program Code'))[ACNPROGRAMCODE], 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Air Date'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Air Date'))        [AirDate], 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Program Name'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Program Name'))    [ProgramName], 
Substring(value, 44, 7) 
[StartDate], 
Substring(value, 51, 7) 
[EndDate], 
CONVERT(DATETIME, '20' 
                  + Substring((Substring(value, 44, 7)), 2, 6)) 
[StartDateTime] 
 FROM   @NIELSONINGNWData PSYN 
 WHERE 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Original/Correction'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Original/Correction'), 1)) = 0 
AND 
( Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), 1)) = NULL 
 OR 
( Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), 1)) = '' ) ) 
AND 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Record Type'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Record Type'), 1)) = 'D' 
AND Substring(value, 1, 2) = '04' 
--AND SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NWSyndicationProgramData','ACN Program Code'),DBO.GetEndIndexCntOfNLSNINGAttribute('NWSyndicationProgramData','ACN Program Code'))='0000009159' 
)FILTER 

    --INSERT INTO FINAL PROGRAM DATA . 
    INSERT INTO @PGFINALData 
                (acnprogramcode, 
                 airdate, 
                 programname, 
                 startdate, 
                 enddate, 
                 airdatetime) 
    SELECT 
PD.acnprogramcode, 
PD.airdate, 
PD.programname, 
PD.startdate, 
PD.enddate, 
Dateadd(wk, 
Datediff(wk, 0, PD.startdatetime), ( 
dbo.Nielsongetposition(PD.airdate, '1', 1, DP.number) ) - 1)[AIRDATETIME] 
    FROM   @PGFILTEREDData PD 
           CROSS JOIN @DUPLICATE DP 
    WHERE  DP.number <= PD.ratingsrecordscnt 

    --INSERT INTO FINAL HOUSEHOLD TEMP TABLE VARIABLE 
    INSERT INTO @HHFINALData 
                (acnprogramcode, 
                 airdate, 
                 household) 
    SELECT acnprogramcode, 
           airdate, 
           Sum(Isnull(CONVERT(INT, household), 0)) / Count(*)[HOUSEHOLD] 
    FROM 
(SELECT DISTINCT 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'ACN Program Code'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'ACN Program Code'))[ACNPROGRAMCODE], 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Household'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Household'))       [Household], 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Air Date'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Air Date'))        [AirDate] 
 FROM   @NIELSONINGNWData PSYN 
 WHERE 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Original/Correction'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Original/Correction'), 1)) = 0 
AND 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Total Program/Half Hour Identifier'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Total Program/Half Hour Identifier'), 1)) > 0 
AND 
( Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Program VCR Indicator'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Program VCR Indicator'), 1)) = NULL 
 OR 
( Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationProgramData', 'Program VCR Indicator'), 1)) = '' ) ) 
AND 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationHouseholdData', 'Record Type'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'Record Type'), 1)) = 'H' 
AND Substring(value, 1, 2) = '04' 
--and SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NWSyndicationHouseholdData','ACN Program Code'),DBO.GetEndIndexCntOfNLSNINGAttribute('NWSyndicationHouseholdData','ACN Program Code'))='0000009159' 
)AS FILTER 
--WHERE ACNPROGRAMCODE='0000009159' 
GROUP  BY acnprogramcode, 
          airdate 

    --INSERT INTO RATING TABLE 
    INSERT INTO [NLSNSyndicationProgramming] 
                ([NLSNSyndicationProgrammingID], 
                 [AirDT], 
                 programname, 
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
                 national_m65plus) 
    SELECT Newid(), 
           PD.airdatetime, 
           PD.programname, 
           HD.household, 
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
                   startdate, 
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
            FROM   (SELECT DISTINCT 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'ACN Program Code'), 
dbo.Getendindexcntofnlsningattribute('NWSyndicationHouseholdData', 'ACN Program Code'))[ACNPROGRAMCODE], 
Substring(value, 44, 7) 
[StartDate], 
Substring(value, 51, 7) 
[EndDate], 
Substring(value, 92, 3) 
[DEMOGRAPHICGROUPID], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'FC2_5'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'FC2_5'), 1)) 
END 
[FC2_5], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'FC6_8'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'FC6_8'), 1)) 
END 
[FC6_8], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'FC9_11'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'FC9_11'), 1)) 
END 
[FC9_11], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'FT12_14'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'FT12_14'), 1)) 
END 
[FT12_14], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'FT15_17'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'FT15_17'), 1)) 
END 
[FT15_17], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F18_20'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F18_20'), 1)) 
END 
[F18_20], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F21_24'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F21_24'), 1)) 
END 
[F21_24], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F25_29'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F25_29'), 1)) 
END 
[F25_29], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F30_34'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F30_34'), 1)) 
END 
[F30_34], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F35_39'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F35_39'), 1)) 
END 
[F35_39], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F40_44'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F40_44'), 1)) 
END 
[F40_44], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F45_49'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F45_49'), 1)) 
END 
[F45_49], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F50_54'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F50_54'), 1)) 
END 
[F50_54], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F55_64'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F55_64'), 1)) 
END 
[F55_64], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'F65PLUS'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'F65PLUS'), 1)) 
END 
[F65PLUS], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'MC2_5'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'MC2_5'), 1)) 
END 
[MC2_5], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'MC6_8'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'MC6_8'), 1)) 
END 
[MC6_8], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'MC9_11'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'MC9_11'), 1)) 
END 
[MC9_11], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'MT12_14'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'MT12_14'), 1)) 
END 
[MT12_14], 
CASE 
  WHEN Substring(value, 92, 3) = '001' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'MT12_14'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'MT12_14'), 1)) 
END 
[MT15_17], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M18_20'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M18_20'), 1)) 
END 
[M18_20], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M21_24'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M21_24'), 1)) 
END 
[M21_24], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M25_29'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M25_29'), 1)) 
END 
[M25_29], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M30_34'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M30_34'), 1)) 
END 
[M30_34], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M35_39'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M35_39'), 1)) 
END 
[M35_39], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M40_44'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M40_44'), 1)) 
END 
[M40_44], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M45_49'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M45_49'), 1)) 
END 
[M45_49], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M50_54'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M50_54'), 1)) 
END 
[M50_54], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M55_64'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M55_64'), 1)) 
END 
[M55_64], 
CASE 
  WHEN Substring(value, 92, 3) = '021' THEN 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'M65PLUS'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'M65PLUS'), 1)) 
END 
[M65PLUS] 
 FROM   @NIELSONINGNWData PSYN 
 WHERE 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'OriginalOrCorrection'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'Original/Correction'), 1)) = 0 
AND 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'Total ProgramPerHalf Hour Identifier'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'Total ProgramPerHalf Hour Identifier'), 1)) = 0 
AND 
( Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'VCR Indicator'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'VCR Indicator'), 1)) ) = 1 
AND 
Substring(value, 
dbo.Getstartindexofnlsningattribute('NWSyndicationDemographicData', 'Record Type'), Isnull( 
dbo.Getendindexcntofnlsningattribute('NWSyndicationDemographicData', 'Record Type'), 1)) = 'P' 
AND Substring(value, 1, 2) = '04' 
--and SUBSTRING(VALUE,DBO.GetStartIndexOfNLSNINGAttribute('NWSyndicationDemographicData','ACN Program Code'),DBO.GetEndIndexCntOfNLSNINGAttribute('NWSyndicationHouseholdData','ACN Program Code'))='0000009159' 
) AS FILTER 
 --WHERE ACNPROGRAMCODE='0000009159' 
 GROUP  BY acnprogramcode, 
           startdate) AS DEMOFINALDATA 
INNER JOIN @PGFINALData PD 
        ON PD.acnprogramcode = DEMOFINALDATA.acnprogramcode 
           AND PD.startdate = DEMOFINALDATA.startdate 
INNER JOIN @HHFINALData HD 
        ON HD.acnprogramcode = PD.acnprogramcode 
           AND HD.airdate = PD.airdate 
ORDER  BY PD.acnprogramcode, 
          PD.airdatetime 

    SELECT Count(*)[ImportedRecCount] 
    FROM   [NLSNSyndicationProgramming] 

    COMMIT TRANSACTION 
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('sp_NIELSONInsertSYNProgramNWFileData: %d: %s',16,1,@error, 
                   @message,@lineNo ); 

        ROLLBACK TRANSACTION 
    END catch; 
END;
