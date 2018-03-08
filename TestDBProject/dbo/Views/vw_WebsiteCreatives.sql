

-- ====================================================================
-- Author			: Arun Nair 
-- Create date		: 
-- Description		: Get Creative Details for Website
-- Execution Process: [dbo].[vw_WebsiteCreatives]
-- Updated By		: Arun Nair on 02/12/2016 - Added Additional Cols 
-- ======================================================================
CREATE  VIEW  [dbo].[vw_WebsiteCreatives]
AS
SELECT 
CreativeDetailWeb.CreativeRepository,
CreativeDetailWeb.CreativeAssetName,
CreativeDetailWeb.CreativeFileType,
CreativeDetailWeb.LegacyAssetName,
CreativeDetailWeb.Deleted as IsDeleted,
CreativeDetailWeb.PageNumber,
CreativeDetailWeb.[CreativeDetailWebID] AS CreativeDetailID,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[OccurrenceDetailWEB].[AdID] as adid,
[Creative].PK_Id AS CreativeMasterID,
[Creative].[SourceOccurrenceId] AS SourceOccurrenceId,
[OccurrenceDetailWEB].[OccurrenceDetailWEBID] AS PK_OccurrenceID,
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator AS PrimaryCreativeIndicator,
[Creative].PrimaryQuality As PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep As CreativeThumbnailRepository,
[Creative].ThmbnlFileType As CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as LegacyCreativeThumbnailAssetName,
[OccurrenceDetailWEB].[CreatedDT] AS CreateDTM,
Ad.[PrimaryOccurrenceID],
CreativeDetailWeb.[PageTypeID],
CreativeDetailWeb.PixelHeight,
CreativeDetailWeb.PixelWidth,
CreativeDetailWeb.[SizeID],
CreativeDetailWeb.FormName,
CreativeDetailWeb.[PageStartDT],
CreativeDetailWeb.[PageEndDT],
CreativeDetailWeb.PageName,
CreativeDetailWeb.PubPageNumber
FROM  [dbo].[CreativeDetailWeb] 
INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailWeb].CreativeMasterID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailWeb].CreativeMasterID=[dbo].[Pattern].[CreativeID]
INNER JOIN [dbo].[OccurrenceDetailWEB] on dbo.[OccurrenceDetailWEB].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailWEB].[AdID]=[dbo].[AD].[AdID]
