
-- ======================================================================================
-- Author				: Arun Nair 
-- Create date			: 13/06/2015
-- Description			: Get Creative Details for ad
-- Execution Process	: [vw_PublicationCreatives] 
-- Updated By			: Arun Nair on 02/12/2016 - Added Additional Columns to View 
-- =======================================================================================

CREATE VIEW  [dbo].[vw_PublicationCreatives]
AS
SELECT 
CreativeDetailPUB.CreativeRepository,
CreativeDetailPUB.CreativeAssetName,
CreativeDetailPUB.CreativeFileType,
CreativeDetailPUB.LegacyCreativeAssetName,
CreativeDetailPUB.Deleted as IsDeleted,
CreativeDetailPUB.PageNumber,
CreativeDetailPUB.CreativeDetailID,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[OccurrenceDetailPUB].[AdID] as adid,
[Creative].PK_Id AS CreativeMasterID,
[Creative].[SourceOccurrenceId] as SourceOccurrenceId,
[OccurrenceDetailPUB].[OccurrenceDetailPUBID],
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator as PrimaryCreativeIndicator,
[Creative].PrimaryQuality as PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep as CreativeThumbnailRepository,
[Creative].ThmbnlFileType as CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as [LegacyCreativeThumbnailAsset Name],
[OccurrenceDetailPUB].[CreatedDT],
CreativeDetailPUB.[PageTypeID],
CreativeDetailPUB.PixelHeight,
CreativeDetailPUB.PixelWidth,
CreativeDetailPUB.FK_SizeID,
CreativeDetailPUB.FormName,
CreativeDetailPUB.[PageStartDT],
CreativeDetailPUB.[PageEndDT],
CreativeDetailPUB.PageName,
CreativeDetailPUB.PubPageNumber
FROM  [dbo].[CreativeDetailPUB] 
INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailPUB].CreativeMasterID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailPUB].CreativeMasterID=[dbo].[Pattern].[CreativeID]
INNER JOIN [dbo].[OccurrenceDetailPUB] ON dbo.[OccurrenceDetailPUB].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailPUB].[AdID]=[dbo].[AD].[AdID]
