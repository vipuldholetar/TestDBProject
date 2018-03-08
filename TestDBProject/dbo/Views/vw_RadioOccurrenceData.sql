-- ==========================================================
-- Author:		Arun Nair 
-- Create date: 21 April 2015
-- Description:	Get Occurence Data for Radio   
-- Updated By : Murali on 07/28/2015 for Exception queue
-- 
--=============================================================

CREATE VIEW [dbo].[vw_RadioOccurrenceData]
AS
	
		SELECT [OccurrenceDetailRA].[OccurrenceDetailRAID] AS OccurrenceID, RCSRADIOSTATION.[RCSRadioStationID] AS RCSStationID,[OccurrenceDetailRA].[AirDT] as AirDate, [RCSAdv].Name AS rcsadvertisername,
		[dbo].[RCSRADIOSTATION].Format AS [StationFormat],RCSRADIOSTATION.ShortName As RadioStation,[AirStartDT],
		(DATEDIFF(SECOND,[OccurrenceDetailRA].[AirStartDT],[OccurrenceDetailRA].[AirEndDT]))As Length
		,NetworkAffiliate,LiveRead, [Market].[Descrip] AS DMA,RCSRADIOSTATION.[EndDT], RCSRADIOSTATION.[EffectiveDT],[RCSACIDTORCSCREATIVEIDMAP].[RCSCreativeID] AS [rcscreativeid]
		 FROM  [dbo].[OccurrenceDetailRA] 
		INNER JOIN  RCSRADIOSTATION ON [OccurrenceDetailRA].[RCSStationID] = RCSRADIOSTATION.[RCSRadioStationID]
		 INNER JOIN	RADIOSTATION ON RCSRADIOSTATION.[RCSRadioStationID] = RADIOSTATION.[RCSStationID]
		INNER JOIN  [RCSACIDTORCSCREATIVEIDMAP] on [RCSACIDTORCSCREATIVEIDMAP].[RCSAcIdToRCSCreativeIdMapID]=[OccurrenceDetailRA].[RCSAcIdID]
		INNER JOIN  [RCSCreative] on [RCSACIDTORCSCREATIVEIDMAP].[RCSCreativeID]=[RCSCreative].[RCSCreativeID] and [OccurrenceDetailRA].[RCSAcIdID]=[RCSACIDTORCSCREATIVEIDMAP].[RCSAcIdToRCSCreativeIdMapID]
		INNER JOIN [RCSAdv] on [RCSAdv].[RCSAdvID]=[RCSCreative].[RCSAdvID]
		INNER JOIN [Market] ON [Market].[MarketID] = RADIOSTATION.dma