-- ==================================================================
-- Author			  :	Arun 
-- Create date		  :	23 Nov 2015
-- Description		  :	Getting Ad Details in DPF For Social
-- Execution Process  : sp_SocialGetAdData 32793
-- Updated By		  :	
-- ==================================================================

CREATE Procedure [dbo].[sp_SocialGetAdData]
(
@AdID as int
)
As
BEGIN
SET NOCOUNT ON;

         BEGIN TRY
				SELECT  Ad.[AdID] As [AdID],Ad.LeadAvHeadline ,[LeadText],[AdVisual],[Description],[Advertiser].[AdvertiserID],
				Ad.[LanguageID],[CommonAdDT],[InternalNotes],[NoTakeAdReason],[AdLength],[Creative].PrimaryQuality,
				[OriginalAdID],[RecutAdId],[FirstRunDate],[LastRunDate], [TradeClass].[Descrip] as TradeClass,
				'' As   CoreSupplementalStatus,''  as Distributiontype , [Advertiser].descrip as advertisername,
				[Pattern].MediaStream,ad.recutdetail, Market.Descrip as FirstRunMarket
				FROM  Ad 
				INNER JOIN [OccurrenceDetailSOC] ON [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=Ad.[PrimaryOccurrenceID]
				INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] AND [OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID]
				LEFT JOIN   [Creative] ON [Pattern].[CreativeID]=[Creative].PK_Id and [Creative].PrimaryIndicator IS NOT NULL
				INNER JOIN  [Advertiser] ON [Advertiser].advertiserid=Ad.[AdvertiserID] 
				LEFT join   [TradeClass] ON [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
				left join [Market] on [Market].[MarketID] = [Ad].[FirstRunMarketID]
                WHERE Ad.[AdID]=@AdID 
		 END TRY
		 BEGIN CATCH
		      DECLARE @error INT, @message VARCHAR(4000), @lineno INT
			  SELECT @error=Error_number(),@message=Error_message(),@lineno=Error_line()
			  RAISERROR('sp_SocialGetAdData: %d: %s',16,1,@error,@message,@lineno);
		 END CATCH
End