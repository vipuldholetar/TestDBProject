
-- =========================================================================
-- Author			: KARUNAKAR 
-- Create date		: 11/25/2015
-- Description		: Get Creative Details for Social
-- Execution Process: [dbo].[vw_SocialCreatives] 
-- Updated By		: Arun Nair on 02/12/2016 - Added Additional Columns in View 
-- =========================================================================
CREATE  VIEW  [dbo].[vw_SocialCreatives]
AS
SELECT 
CreativeDetailSOC.CreativeRepository,
CreativeDetailSOC.CreativeAssetName,
CreativeDetailSOC.CreativeFileType,
CreativeDetailSOC.LegacyAssetName,
CreativeDetailSOC.Deleted as IsDeleted,
CreativeDetailSOC.PageNumber,
CreativeDetailSOC.[CreativeDetailSOCID] AS CreativeDetailID,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[OccurrenceDetailSOC].[AdID] as adid,
[Creative].PK_Id AS CreativeMasterID,
[Creative].[SourceOccurrenceId] AS SourceOccurrenceId,
[OccurrenceDetailSOC].[OccurrenceDetailSOCID],
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator AS PrimaryCreativeIndicator,
[Creative].PrimaryQuality As PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep As CreativeThumbnailRepository,
[Creative].ThmbnlFileType As CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as LegacyCreativeThumbnailAssetName,
[OccurrenceDetailSOC].[CreatedDT] AS CreateDTM,
Ad.[PrimaryOccurrenceID],
CreativeDetailSOC.[PageTypeID],
CreativeDetailSOC.PixelHeight,
CreativeDetailSOC.PixelWidth,
CreativeDetailSOC.[SizeID],
CreativeDetailSOC.FormName,
CreativeDetailSOC.[PageStartDT],
CreativeDetailSOC.[PageEndDT],
CreativeDetailSOC.PageName,
CreativeDetailSOC.PubPageNumber
FROM  [dbo].[CreativeDetailSOC] 
INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailSOC].CreativeMasterID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailSOC].CreativeMasterID=[dbo].[Pattern].[CreativeID]
INNER JOIN [dbo].[OccurrenceDetailSOC] on dbo.[OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].Ad ON [dbo].[OccurrenceDetailSOC].[AdID]=[dbo].[AD].[AdID]
