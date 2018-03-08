
-- ============================================================================================================= 
-- Author    : Govardhan.R 
-- Create date  : 10/09/2015 
-- Description  : This stored procedure is used to get the CREATIVE DETAILS FOR AN AD . 
-- Execution  : [sp_CPGetCreativeDetailsForOccurrenceInQueryQueueForm] 'Online Display','5239' 
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[sp_CPGetCreativeDetailsForOccurrenceInQueryQueueForm] ( 
@MediaStream AS NVARCHAR(max), 
@OccrId      AS INT) 
AS 
  BEGIN 
      DECLARE @MediaStreamValue AS NVARCHAR(max)='' 
      DECLARE @MediaStreamBasePath AS NVARCHAR(max)='' 

      SELECT @MediaStreamValue = value 
      FROM   [dbo].[Configuration] 
      WHERE  valuetitle = @MediaStream 

      SELECT @MediaStreamBasePath = value 
      FROM   [Configuration] 
      WHERE  systemname = 'All' 
             AND componentname = 'Creative Repository'; 

      BEGIN try 
          IF( @MediaStreamValue = 'RAD' ) 
            BEGIN 
                SELECT CD.rep + CD.assetname + '.' + filetype AS 
[PrimarySource] 
, 
@MediaStreamBasePath 
[BasePath], 
CM.pk_id                               [CREATIVEMASTERID], 
@MediaStreamValue                      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [CreativeDetailRA] CD 
        ON CM.pk_id = CD.[CreativeID] 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailRA] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailRAID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'TV' ) 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailtv CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailTV] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailTVID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'OD' ) 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailodr CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailODR] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailODRID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'CIN' ) 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailcin CD 
        ON CM.pk_id = CD.[CreativeMasterID] 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailCIN] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailCINID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'OND' ) --Online Display 
BEGIN 
SELECT Isnull(CD.creativerepository, '') 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailond CD 
        ON CM.pk_id = CD.[CreativeMasterID] 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailOND] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailONDID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'ONV' ) --Online Video 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailonv CD 
        ON CM.pk_id = CD.[CreativeMasterID] 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailONV] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailONVID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'MOB' ) --Mobile 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN creativedetailmob CD 
        ON CM.pk_id = CD.[CreativeMasterID] 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailMOB] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailMOBID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'CIR' ) --Mobile 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [dbo].[creativedetailcir] CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailCIR] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailCIRID] = @OccrId 
-- AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'PUB' ) --Mobile 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [dbo].[creativedetailpub] CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailPUB] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailPUBID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'EM' ) --EMail 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [dbo].[creativedetailem] CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailEM] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailEMID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'SOC' ) --SOCIAL 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [dbo].[creativedetailsoc] CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailSOC] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailSOCID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 

IF( @MediaStreamValue = 'WEB' ) --SOCIAL 
BEGIN 
SELECT CD.creativerepository 
+ CD.creativeassetname AS [PrimarySource], 
@MediaStreamBasePath   [BasePath], 
CM.pk_id               [CREATIVEMASTERID], 
@MediaStreamValue      [MediaStream] 
FROM   [Creative] CM 
INNER JOIN [dbo].[creativedetailweb] CD 
        ON CM.pk_id = CD.creativemasterid 
INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
INNER JOIN [dbo].[OccurrenceDetailWEB] OCCR 
        ON OCCR.[PatternID] = PM.[PatternID] 
WHERE  OCCR.[OccurrenceDetailWEBID] = @OccrId 
--AND CM.PrimaryIndicator=1 
END 
END try 

BEGIN catch 
DECLARE @error   INT, 
@message VARCHAR(4000), 
@lineNo  INT 

SELECT @error = Error_number(), 
@message = Error_message(), 
@lineNo = Error_line() 

RAISERROR ( 
'sp_CPGetCreativeDetailsForOccurrenceInQueryQueueForm: %d: %s',16 
,1,@error, 
@message,@lineNo); 
END catch 
END