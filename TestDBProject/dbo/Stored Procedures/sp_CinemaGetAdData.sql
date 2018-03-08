
-- ==================================================================
-- Author			 :	Karunakar 
-- Create date		 :	20th July 2015
-- Description		 :	This Procedure is Used to Getting Ad for Cinema
-- Execution Process :  sp_CinemaGetAdData 13168
-- Updated By		 :  Updated By Karunakar on 28th july 2015
-- Updated By		 :  Ramesh On 08/12/2015  - CleanUp for OneMTDB    
-- ==================================================================

CREATE Procedure [dbo].[sp_CinemaGetAdData]
(@AdID as int)
As
BEGIN
SET NOCOUNT ON;
				SELECT  Distinct Ad.[AdID] AS [AdID],LeadAvHeadline AS [LeadAudioHeadline],[LeadText] AS [Lead_Text],[AdVisual] AS  [AD_Visual],[Description],[Advertiser].[AdvertiserID],
				ad.[LanguageID],[CommonAdDT],[InternalNotes] AS [Internal_Notes],[NoTakeAdReason],[AdLength] AS [Ad_Length],[Creative].[PrimaryQuality] AS [PrimaryCreativeQuality],
				[OriginalAdID],Ad.[RecutAdId] AS [Recut_AdId],[FirstRunDate] AS [First_Run_Date],[LastRunDate] AS [Last_Run_Date], [TradeClass].[Descrip] as TradeClass,
				'' As   CoreSupplementalStatus,''  as Distributiontype , [Advertiser].descrip as advertisername,
				[Pattern].mediastream,ad.RecutDetail as recut_detail, Market.Descrip AS [First_Run_Market]
				FROM  AD 
				INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] 
				left JOIN [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id
				inner JOIN   [Advertiser] on [Advertiser].advertiserid=ad.[AdvertiserID] 
				left join [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
				left join [Market] on [Market].[MarketID] = [Ad].[FirstRunMarketID]
                Where Ad.[AdID]=@AdID and [Creative].PrimaryIndicator is not null
				-- Updated By PrimaryCreativeQuality to PrimaryCreativeIndicator
End