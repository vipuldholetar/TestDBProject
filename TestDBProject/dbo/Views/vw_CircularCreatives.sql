


-- ===========================================================================================
-- Author			: Arun Nair 
-- Create date		: 19/05/2015
-- Description		: Get Creative Details for ad
-- Execution Process: [vw_CircularCreatives] 
-- Updated By		: Arun Nair on 29/05/2015
--					: Karunakar on 11th August 2015
--					: Arun Nair on 12/14/2014 - Added Additional fields from CreativesCIR
-- ==================================================================================================

CREATE VIEW  [dbo].[vw_CircularCreatives]
AS
SELECT 
CreativeDetailCIR.CreativeRepository,
CreativeDetailCIR.CreativeAssetName,
CreativeDetailCIR.CreativeFileType,
CreativeDetailCIR.LegacyCreativeAssetName,
CreativeDetailCIR.Deleted as IsDeleted,
CreativeDetailCIR.PageNumber,
CreativeDetailCIR.CreativeDetailID,
CreativeDetailCIR.[PageTypeID],
CreativeDetailCIR.PixelHeight,
CreativeDetailCIR.PixelWidth,
CreativeDetailCIR.[SizeID],
CreativeDetailCIR.FormName,
CreativeDetailCIR.[PageStartDT],
CreativeDetailCIR.[PageEndDT],
CreativeDetailCIR.PageName,
CreativeDetailCIR.PubPageNumber,
[Pattern].[CreativeID] AS PatternMasterCreativeMasterID,
[OccurrenceDetailCIR].[AdID] as adid,
[Creative].PK_Id AS CreativeMasterID,
[Creative].[SourceOccurrenceId] AS SourceOccurrenceId,
[OccurrenceDetailCIR].[OccurrenceDetailCIRID],
[Creative].EnvelopId,
[Creative].CreativeType,
[Creative].PrimaryIndicator AS PrimaryCreativeIndicator,
[Creative].PrimaryQuality As PrimaryCreativeQuality,
[Creative].AssetThmbnlName as CreativeAssetThumbnailName,
[Creative].ThmbnlRep As CreativeThumbnailRepository,
[Creative].ThmbnlFileType As CreativeThumbnailFileType,
[Creative].LegacyThmbnlAssetName as LegacyCreativeThumbnailAssetName,
[OccurrenceDetailCIR].[CreatedDT]
FROM  [dbo].[CreativeDetailCIR] 
INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailCIR].CreativeMasterID =[dbo].[Creative].PK_Id
INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailCIR].CreativeMasterID=[dbo].[Pattern].[CreativeID]
INNER join [dbo].[OccurrenceDetailCIR] on dbo.[OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID]
INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailCIR].[AdID]=[dbo].[AD].[AdID]
