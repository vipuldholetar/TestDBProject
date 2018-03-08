

CREATE VIEW [dbo].[vw_CreativeDetailAV]
AS

SELECT 'TV' AS MediaStream, CreativeDetailTVID AS CreativeDetailId, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyCreativeAssetName as LegacyAssetName,CreativeFileType
FROM            dbo.CreativeDetailTV

UNION

SELECT  'CIN' AS MediaStream, CreativeDetailCINID AS CreativeDetailId, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyCreativeAssetName as LegacyAssetName,CreativeFileType
FROM            dbo.CreativeDetailCIN

UNION

SELECT  'ONV' AS MediaStream, CreativeDetailONVID AS CreativeDetailId, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType
FROM            dbo.CreativeDetailONV