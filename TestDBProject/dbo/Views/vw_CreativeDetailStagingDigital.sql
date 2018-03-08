



CREATE VIEW [dbo].[vw_CreativeDetailStagingDigital]
AS
SELECT 'OND' AS mediastream,[SignatureDefault] as CreativeSignature, CreativeDetailStagingID,
	   null as OccurrenceID, CreativeStagingID,CreativeRepository, CreativeAssetName,
	   [FileSize],CreativeFileType
FROM            dbo.CreativeDetailStagingOND

UNION

SELECT 'MOB' AS mediastream,SignatureDefault as CreativeSignature, CreativeDetailStagingID,
	   null as OccurrenceID, CreativeStagingID,CreativeRepository, CreativeAssetName,
	   [FileSize],CreativeFileType
FROM            dbo.CreativeDetailStagingMOB