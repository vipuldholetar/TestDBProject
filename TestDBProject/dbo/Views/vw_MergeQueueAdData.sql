




-- =============================================================================
-- Author		: KARUNAKAR  
-- modifiedBy   : AMRUTHA
-- Create date	: 4th Jan 2016
-- Description	: Get the Merge ad Data
-- Updated By	: 				  
-- Execution	: Select * from vw_MergeQueueAdData
--===============================================================================

CREATE VIEW [dbo].[vw_MergeQueueAdData]
AS
		--Circular
		WITH CTE AS (
		
		SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]
                               ORDER BY a.[AdID]) AS RN,
		a.LeadAvHeadline,a.LeadText,a.AdVisual,b.Descrip as AdvertiserName,a.AdInfo as AdDescription,c.[Description] as [Language],
				e.MediaStream as MediaStreamID,a.AdLength,f.PrimaryQuality,a.FirstRunDate,a.[FirstRunMarketID],a.LastRunDate,
				f.ThmbnlRep + '\' + f.AssetThmbnlName as Thumbnail,
				d.[OccurrenceDetailCIRID] as OccurrenceID,e.[PatternID] as PatternmasterID,f.PK_Id as CreativeMasterID,
				cm.ValueTitle as MediaStream,
				a.[PrimaryOccurrenceID],
				(Select Count(*) from [OccurrenceDetailCIR] where a.[AdID]=[OccurrenceDetailCIR].[AdID]) as OccurrenceCount,
				(Select Count(*) from [Pattern] where a.[AdID]=[Pattern].[AdID] and d.[PatternID]=[Pattern].[PatternID]) as PatternmasterCount
				,f.PrimaryIndicator
		FROM Ad a, [Advertiser] b, [Language] c, [OccurrenceDetailCIR] d, [Pattern] e, 				[Creative] f,[Configuration] cm
		WHERE  	b.AdvertiserID = a.[AdvertiserID] AND c.LanguageID = a.[LanguageID]
			AND d.[AdID] = a.[AdID]
			AND e.[PatternID] = d.[PatternID] and e.[AdID]=a.[AdID]
			AND f.[AdId] = a.[AdID]
			and cm.ConfigurationID=e.MediaStream
			AND f.PrimaryIndicator = 1

			UNION

SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]
                               ORDER BY a.[AdID]) AS RN,
		a.LeadAvHeadline,a.LeadText,a.AdVisual,b.Descrip as AdvertiserName,a.AdInfo as AdDescription,c.[Description] as [Language],
				e.MediaStream as MediaStreamID,a.AdLength,f.PrimaryQuality,a.FirstRunDate,a.[FirstRunMarketID],a.LastRunDate,
				f.ThmbnlRep + '\' + f.AssetThmbnlName as Thumbnail,
				d.[OccurrenceDetailPUBID] as OccurrenceID,e.[PatternID] as PatternmasterID,f.PK_Id as CreativeMasterID,
				cm.ValueTitle as MediaStream,
				a.[PrimaryOccurrenceID],
				(Select Count(*) from [OccurrenceDetailPUB] where a.[AdID]=[OccurrenceDetailPUB].[AdID]) as OccurrenceCount,
				(Select Count(*) from [Pattern] where a.[AdID]=[Pattern].[AdID] and d.[PatternID]=[Pattern].[PatternID]) as PatternmasterCount
				,f.PrimaryIndicator
		FROM Ad a, [Advertiser] b, [Language] c, [OccurrenceDetailPUB] d, [Pattern] e, 				[Creative] f,[Configuration] cm
		WHERE  	b.AdvertiserID = a.[AdvertiserID] AND c.LanguageID = a.[LanguageID]
			AND d.[AdID] = a.[AdID]
			AND e.[PatternID] = d.[PatternID] and e.[AdID]=a.[AdID]
			AND f.[AdId] = a.[AdID]
			and cm.ConfigurationID=e.MediaStream
			AND f.PrimaryIndicator = 1
	UNION

SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]
                               ORDER BY a.[AdID]) AS RN,
		a.LeadAvHeadline,a.LeadText,a.AdVisual,b.Descrip as AdvertiserName,a.AdInfo as AdDescription,c.[Description] as [Language],
				e.MediaStream as MediaStreamID,a.AdLength,f.PrimaryQuality,a.FirstRunDate,a.[FirstRunMarketID],a.LastRunDate,
				f.ThmbnlRep + '\' + f.AssetThmbnlName as Thumbnail,
				d.[OccurrenceDetailSOCID] as OccurrenceID,e.[PatternID] as PatternmasterID,f.PK_Id as CreativeMasterID,
				cm.ValueTitle as MediaStream,
				a.[PrimaryOccurrenceID],
				(Select Count(*) from [OccurrenceDetailSOC] where a.[AdID]=[OccurrenceDetailSOC].[AdID]) as OccurrenceCount,
				(Select Count(*) from [Pattern] where a.[AdID]=[Pattern].[AdID] and d.[PatternID]=[Pattern].[PatternID]) as PatternmasterCount
				,f.PrimaryIndicator
		FROM Ad a, [Advertiser] b, [Language] c, [OccurrenceDetailSOC] d, [Pattern] e, 				[Creative] f,[Configuration] cm
		WHERE  	b.AdvertiserID = a.[AdvertiserID] AND c.LanguageID = a.[LanguageID]
			AND d.[AdID] = a.[AdID]
			AND e.[PatternID] = d.[PatternID] and e.[AdID]=a.[AdID]
			AND f.[AdId] = a.[AdID]
			and cm.ConfigurationID=e.MediaStream
			AND f.PrimaryIndicator = 1
			UNION

SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]
                               ORDER BY a.[AdID]) AS RN,
		a.LeadAvHeadline,a.LeadText,a.AdVisual,b.Descrip as AdvertiserName,a.AdInfo as AdDescription,c.[Description] as [Language],
				e.MediaStream as MediaStreamID,a.AdLength,f.PrimaryQuality,a.FirstRunDate,a.[FirstRunMarketID],a.LastRunDate,
				f.ThmbnlRep + '\' + f.AssetThmbnlName as Thumbnail,
				d.[OccurrenceDetailWEBID] as OccurrenceID,e.[PatternID] as PatternmasterID,f.PK_Id as CreativeMasterID,
				cm.ValueTitle as MediaStream,
				a.[PrimaryOccurrenceID],
				(Select Count(*) from [OccurrenceDetailWEB] where a.[AdID]=[OccurrenceDetailWEB].[AdID]) as OccurrenceCount,
				(Select Count(*) from [Pattern] where a.[AdID]=[Pattern].[AdID] and d.[PatternID]=[Pattern].[PatternID]) as PatternmasterCount
				,f.PrimaryIndicator
		FROM Ad a, [Advertiser] b, [Language] c, [OccurrenceDetailWEB] d, [Pattern] e, 				[Creative] f,[Configuration] cm
		WHERE  	b.AdvertiserID = a.[AdvertiserID] AND c.LanguageID = a.[LanguageID]
			AND d.[AdID] = a.[AdID]
			AND e.[PatternID] = d.[PatternID] and e.[AdID]=a.[AdID]
			AND f.[AdId] = a.[AdID]
			and cm.ConfigurationID=e.MediaStream
			AND f.PrimaryIndicator = 1	
				UNION

SELECT a.[AdID] as AdID, Row_Number() OVER (partition BY a.[AdID]
                               ORDER BY a.[AdID]) AS RN,
		a.LeadAvHeadline,a.LeadText,a.AdVisual,b.Descrip as AdvertiserName,a.AdInfo as AdDescription,c.[Description] as [Language],
				e.MediaStream as MediaStreamID,a.AdLength,f.PrimaryQuality,a.FirstRunDate,a.[FirstRunMarketID],a.LastRunDate,
				f.ThmbnlRep + '\' + f.AssetThmbnlName as Thumbnail,
				d.[OccurrenceDetailEMID] as OccurrenceID,e.[PatternID] as PatternmasterID,f.PK_Id as CreativeMasterID,
				cm.ValueTitle as MediaStream,
				a.[PrimaryOccurrenceID],
				(Select Count(*) from [OccurrenceDetailEM] where a.[AdID]=[OccurrenceDetailEM].[AdID]) as OccurrenceCount,
				(Select Count(*) from [Pattern] where a.[AdID]=[Pattern].[AdID] and d.[PatternID]=[Pattern].[PatternID]) as PatternmasterCount
				,f.PrimaryIndicator
		FROM Ad a, [Advertiser] b, [Language] c, [OccurrenceDetailEM] d, [Pattern] e, 				[Creative] f,[Configuration] cm
		WHERE  	b.AdvertiserID = a.[AdvertiserID] AND c.LanguageID = a.[LanguageID]
			AND d.[AdID] = a.[AdID]
			AND e.[PatternID] = d.[PatternID] and e.[AdID]=a.[AdID]
			AND f.[AdId] = a.[AdID]
			and cm.ConfigurationID=e.MediaStream
			AND f.PrimaryIndicator = 1)
 SELECT *
     FROM CTE
     WHERE Rn = 1