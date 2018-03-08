



CREATE VIEW [dbo].[vw_CreativeDetailStagingAV]
AS

SELECT 'TV' AS MediaStream, CreativeDetailStagingTVId AS CreativeDetailStagingId,
	   OccurrenceID, CreativeStgMasterID as CreativeStagingID,MediaFilepath as CreativeRepository, 
	   [MediaFileName] as CreativeAssetName, [FileSize],[MediaFormat] as CreativeFileType
FROM            dbo.CreativeDetailStagingTV

UNION

SELECT  'CIN' AS MediaStream, CreativeDetailStagingCINId AS CreativeDetailStagingId,
	  null as OccurrenceID, CreativeStagingID,CreativeRepository, CreativeAssetName,
	   [CreativeFileSize] as FileSize, CreativeFileType
FROM            dbo.CreativeDetailStagingCIN

UNION

SELECT  'ONV' AS MediaStream,  CreativeDetailStagingID,
	   null as OccurrenceID, CreativeStagingID,CreativeRepository, CreativeAssetName,
	   [FileSize],CreativeFileType
FROM            dbo.CreativeDetailStagingONV