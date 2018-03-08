



-- ===========================================================================================
-- Author			: Arun Nair 
-- Create date		: 19/05/2015
-- Description		: Get Creative Details for ad
-- Execution Process: [vw_CircularCreatives] 
-- Updated By		: Arun Nair on 29/05/2015
--					: Karunakar on 11th August 2015
--					: Arun Nair on 12/14/2014 - Added Additional fields from CreativesCIR
-- ==================================================================================================

CREATE VIEW  [dbo].[vw_PrintCreatives]
AS
SELECT 
[vw_CreativeDetailPrint].CreativeRepository,
[vw_CreativeDetailPrint].CreativeAssetName,
[vw_CreativeDetailPrint].CreativeFileType,
[vw_CreativeDetailPrint].LegacyAssetName,
[vw_CreativeDetailPrint].Deleted as IsDeleted,
[vw_CreativeDetailPrint].PageNumber,
[vw_CreativeDetailPrint].CreativeDetailID,
[vw_CreativeDetailPrint].[PageTypeID],
[vw_CreativeDetailPrint].PixelHeight,
[vw_CreativeDetailPrint].PixelWidth,
[vw_CreativeDetailPrint].[SizeID],
[vw_CreativeDetailPrint].FormName,
[vw_CreativeDetailPrint].[PageStartDT],
[vw_CreativeDetailPrint].[PageEndDT],
[vw_CreativeDetailPrint].PageName,
[vw_CreativeDetailPrint].PubPageNumber,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[vw_OccurrenceDetailPrint].[AdID] as adid,
[Creative].PK_Id AS CreativeID,
[Creative].[SourceOccurrenceId] AS SourceOccurrenceId,
[vw_OccurrenceDetailPrint].[OccurrenceDetailID],
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator AS PrimaryCreativeIndicator,
[Creative].PrimaryQuality As PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep As CreativeThumbnailRepository,
[Creative].ThmbnlFileType As CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as LegacyCreativeThumbnailAssetName,
[vw_OccurrenceDetailPrint].[CreatedDT]
FROM  [dbo].[vw_CreativeDetailPrint] 
INNER JOIN [dbo].[Creative] ON [dbo].[vw_CreativeDetailPrint].CreativeID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[vw_CreativeDetailPrint].CreativeID=[dbo].[Pattern].[CreativeID]
INNER join [dbo].[vw_OccurrenceDetailPrint] on dbo.[vw_OccurrenceDetailPrint].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].ad ON [dbo].[vw_OccurrenceDetailPrint].[AdID]=[dbo].[AD].[AdID]