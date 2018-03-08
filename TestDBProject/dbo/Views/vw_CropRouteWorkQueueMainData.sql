




-- ==============================================================================================

-- Author			:	Monika. J on 10/19/2015

-- Description		:	This view RETURNS THE DATA

-- ==============================================================================================

CREATE VIEW [dbo].[vw_CropRouteWorkQueueMainData]

AS



	--SELECT DISTINCT a.Priority as Priority,

	--a.PK_ID as RecordID,	

	--e.Descrip as Advertiser,

	--b.FirstRunDate as FirstRunDate,

	--CASE WHEN g.AdDate IS NOT NULL THEN g.AdDate

	--ELSE b.CommonAdDate END as CommonAdDate,

	--f.IndustryName as IndustryGroup,

	--d.[Description] as Market,

	--b.ModifiedBy as LastUpdatedBy,

	--b.ModifiedDate as LastUpdatedOn,

	--c.[Description] as Language,

	--g.CompletedBy as CompletedBy,

	--g.CompletedDate as CompletedOn,

	----/// below columns are not for display

	--b.PK_ID as AdID,			

	--a.OccurrenceID as OccurrenceID,	

	--b.AdvID as AdvertiserID,	

	--b.IsQuery as IsQuery,		

	--b.CreatedBy as CreateBy,	

	--b.CreateDate as CreateOn,	

	--a.MediaStream as MediaStream

	--FROM vw_CropRouteWorkQueueData a INNER JOIN Ad b ON b.PK_ID = a.PK_ID AND (b.IsQuery != 1 OR b.IsQuery IS NULL) and 

	--b.ClassifiedBy IS NOT NULL AND b.NoTakeAdReason IS NULL

	--INNER JOIN LanguageMaster c ON c.LanguageID = b.LanguageID 

	--left outer JOIN MarketMaster d ON d.MarketCode = b.FK_MarketID 

	--LEFT OUTER JOIN CreativeforCrop g ON g.FK_ID = a.PK_ID AND ISNULL(g.FK_OccurrenceID,'') = ISNULL(a.OccurrenceID,'')--AND g.FK_OccurrenceID = a.OccurrenceID

	--INNER JOIN AdvertiserMaster e ON e.AdvertiserID = b.AdvID 

	--INNER JOIN AdvertiserIndustryGroup h ON  h.FK_AdvertiserID = e.AdvertiserID 

	--INNER JOIN RefIndustryGroup f ON f.PK_ID = h.FK_IndustryGroupID --AND f.SystemName = 'All' AND f.ComponentName = 'Industry Group'

	

	--WHERE a.OccurrenceID IS NOT NULL AND a.Status = 1



	--UNION ALL



	 SELECT Priority,RecordID,Advertiser,FirstRunDate,CommonAdDate,IndustryGroup,Market,LastUpdatedBy,

	 LastUpdatedOn,Language,CompletedBy,CompletedOn,AdID,OccurrenceID,AdvertiserID,IsQuery,MIN(CreateBy) AS CreateBy,CreateOn,MediaStream

	 FROM 

	 (

		SELECT distinct a.Priority as Priority,

		 CAST(a.AdId AS VARCHAR) + ' / ' + CAST(a.OccurrenceID AS VARCHAR) as RecordID,    

		e.Descrip as Advertiser,

		b.FirstRunDate as FirstRunDate,

		CASE WHEN h.AdDate IS NOT NULL THEN h.AdDate

		ELSE g.AdDate END as CommonAdDate,

		f.IndustryName as IndustryGroup,

		--		d.[Description] as Market,
		'' as Market,
		g.ModifiedBy as LastUpdatedBy,

		g.ModifiedDate as LastUpdatedOn,

		c.[Description] as Language,

		h.[CompletedByID] as CompletedBy,

		h.[CompletedDT] as CompletedOn,

		--/// below columns are not for display

		b.[AdID] as AdID,			

		a.OccurrenceID as OccurrenceID,	

		b.[AdvertiserID] as AdvertiserID,

		g.IsQuery as IsQuery,		

		g.CreateBy as CreateBy,	

		g.CreateDate as CreateOn,	

		a.MediaStream as MediaStream	

 FROM vw_CropRouteWorkQueueData a CROSS APPLY ufn_OccurrenceDetails(a.OccurrenceID) g
    INNER JOIN Ad b ON b.[AdID] = a.[AdID] 
    INNER JOIN [Language] c ON  c.LanguageID = b.[LanguageID]	--/// to get Language Desc
    INNER JOIN	[Advertiser] e ON e.AdvertiserID = b.[AdvertiserID]
    INNER JOIN AdvertiserIndustryGroup i ON i.[AdvertiserID] = e.AdvertiserID
    INNER JOIN RefIndustryGroup f ON f.[RefIndustryGroupID] = i.[IndustryGroupID]
    LEFT JOIN [CreativeForCrop] h ON h.[CreativeID] = a.[AdID]	--/// OUTER RIGHT JOIN since <Track 7.4 Table/View> is the main source table/view
    AND h.[OccurrenceID] = a.OccurrenceID

	WHERE --/// Only Occurrences for Crop & Route --/// The Ad Classification is capable of tagging for Crop or not; to exclude Crop Completed Ads too.
	a.Status = 1
	AND a.OccurrenceID IS NOT NULL 
	AND (b.[Query] != 1 OR b.[Query] IS NULL)	--/// to exclude Ad level raised queries
	AND (g.IsQuery != 1	OR g.IsQuery IS NULL)--/// to exclude Occurrence level raised queries
	AND (g.NoTakeReason IS NULL or g.notakereason='')	--/// to exclude No Takes
	--AND d.MarketCode = b.FK_MarketID	--/// by this time Market is with value since this is a mandatory field in Ad Classification
		--/// to get default Industry Group
	--ORDER BY a.Priority, b.FirstRunDate, CommonAdDate	--/// default sort order
	) A GROUP BY Priority,RecordID,Advertiser,FirstRunDate,CommonAdDate,IndustryGroup,Market,LastUpdatedBy,

	 LastUpdatedOn,Language,CompletedBy,CompletedOn,AdID,OccurrenceID,AdvertiserID,IsQuery,CreateOn,MediaStream
