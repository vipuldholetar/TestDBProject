
-- =================================================================
-- Author			: KARUNAKAR 
-- Create date		: 30th October 2015
-- Description		: Get Creative Details for Email
-- Execution Process: [dbo].[vw_EmailCreatives] 
-- Updated By		: Arun Nair on 02/12/2016 -Added Additional Cols
-- ====================================================================
CREATE  VIEW  [dbo].[vw_EmailCreatives]
AS
SELECT 
CreativeDetailEM.CreativeRepository,
CreativeDetailEM.CreativeAssetName,
CreativeDetailEM.CreativeFileType,
CreativeDetailEM.LegacyAssetName,
CreativeDetailEM.Deleted as IsDeleted,
CreativeDetailEM.PageNumber,
CreativeDetailEM.[CreativeDetailsEMID] AS CreativeDetailID,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[OccurrenceDetailEM].[AdID] as adid,
[Creative].PK_Id AS CreativeMasterID,
[Creative].[SourceOccurrenceId] AS SourceOccurrenceId,
[OccurrenceDetailEM].[OccurrenceDetailEMID] AS PK_OccurrenceID,
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator AS PrimaryCreativeIndicator,
[Creative].PrimaryQuality As PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep As CreativeThumbnailRepository,
[Creative].ThmbnlFileType As CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as LegacyCreativeThumbnailAssetName,
[OccurrenceDetailEM].[CreatedDT] AS CreateDTM,
Ad.[PrimaryOccurrenceID],
CreativeDetailEM.PageTypeId,
CreativeDetailEM.PixelHeight,
CreativeDetailEM.PixelWidth,
CreativeDetailEM.[SizeID],
CreativeDetailEM.FormName,
CreativeDetailEM.[PageStartDT],
CreativeDetailEM.[PageEndDT],
CreativeDetailEM.PageName,
CreativeDetailEM.EmailPageNumber
FROM  [dbo].[CreativeDetailEM] 
INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailEM].CreativeMasterID=[dbo].[Pattern].[CreativeID]
INNER join [dbo].[OccurrenceDetailEM] on dbo.[OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailEM].[AdID]=[dbo].[AD].[AdID]
