
-- ==================================================================
-- Author			  :	Karunakar
-- Create date		  :	30th October 2015
-- Description		  :	Getting Ad Details in DPF For Email
-- Execution Process  : sp_EmailGetAdData 7320
-- Updated By		  :	
-- ==================================================================

CREATE Procedure [dbo].[sp_EmailGetAdData]
(
@AdID as int
)
As
BEGIN
SET NOCOUNT ON;

	   DECLARE @PatternId as INTEGER
	   DECLARE @FirstRunDate AS VARCHAR(200) 
	   DECLARE @LastRunDate AS VARCHAR(200)			 
	   DECLARE @FirstRunMarket AS VARCHAR(200)

	   SELECT top 1 @FirstRunDate = AdDT,@FirstRunMarket = m.Descrip
		  FROM Pattern p inner join OccurrenceDetailEM o on p.patternid = o.patternid
		  LEFT JOIN Market m on o.MarketID = m.MarketID
	   WHERE o.AdId = @AdID
	   ORDER BY AdDT asc

	   SELECT top 1 @LastRunDate = AdDT
		  FROM Pattern p inner join OccurrenceDetailEM o on p.patternid = o.patternid
	   WHERE o.AdId = @AdID
	   ORDER BY AdDT desc

	   SELECT  Ad.[AdID] As [AdID],Ad.LeadAvHeadline ,[LeadText],[AdVisual],[Description],[Advertiser].[AdvertiserID],
	   Ad.[LanguageID],[CommonAdDT],[InternalNotes],[NoTakeAdReason],[AdLength],[Creative].PrimaryQuality,
	   [OriginalAdID],[RecutAdId], [TradeClass].[Descrip] as TradeClass,
	   '' As   CoreSupplementalStatus,''  as Distributiontype , [Advertiser].descrip as advertisername,
	   [Pattern].MediaStream,ad.recutdetail,@FirstRunMarket as FirstRunMarket,@FirstRunDate as [FirstRunDate],@LastRunDate as [LastRunDate]
	   FROM  Ad 
	   INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] 
	   left JOIN   [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id
	   inner JOIN  [Advertiser] on [Advertiser].advertiserid=Ad.[AdvertiserID] 
	   Left join   [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
        Where Ad.[AdID]=@AdID and [Creative].PrimaryIndicator is not null

End
