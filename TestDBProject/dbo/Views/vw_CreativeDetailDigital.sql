


CREATE VIEW [dbo].[vw_CreativeDetailDigital]
AS
SELECT 'OND' AS mediastream, CreativeDetailONDID AS CreativeDetailId, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType
FROM            dbo.CreativeDetailOND

UNION

SELECT 'MOB' AS mediastream, CreativeDetailMOBID AS CreativeDetailId, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType
FROM            dbo.CreativeDetailMOB