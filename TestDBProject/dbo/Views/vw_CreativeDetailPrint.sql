


CREATE VIEW [dbo].[vw_CreativeDetailPrint]
AS
SELECT 'PUB' as mediastream, CreativeDetailID, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyCreativeAssetName as LegacyAssetName,CreativeFileType,
	   Deleted,PageNumber,PageTypeID,PixelHeight,PixelWidth,FK_SizeID as SizeID,FormName,PageStartDT,PageEndDT,PageName,PubPageNumber
FROM            dbo.CreativeDetailPUB

UNION

SELECT 'CIR' as mediastream, CreativeDetailID, CreativeMasterID as CreativeId,
	   CreativeAssetName,CreativeRepository,LegacyCreativeAssetName as LegacyAssetName,CreativeFileType,
	   Deleted,PageNumber,PageTypeID,PixelHeight,PixelWidth,SizeID,FormName,PageStartDT,PageEndDT,PageName,PubPageNumber
FROM            dbo.CreativeDetailCIR