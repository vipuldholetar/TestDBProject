
CREATE VIEW [dbo].[vw_CreativeDetailStaging_All]
AS
select CreativeAssetName ImageName, CreativeDetailStagingEMID PageId, CreativeStagingID CreativeMasterId from [CreativeDetailStagingEM]
union all
select CreativeAssetName ImageName, CreativeDetailStagingODRID PageId, CreativeStagingID CreativeMasterId from [CreativeDetailStagingODR]

