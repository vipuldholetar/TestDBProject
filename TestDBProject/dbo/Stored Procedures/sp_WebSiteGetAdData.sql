
-- ==================================================================
-- Author			  :	Karunakar
-- Create date		  :	11th Nov 2015
-- Description		  :	Getting Ad Details in DPF For WebSite
-- Execution Process  : sp_WebSiteGetAdData 7320
-- Updated By		  :	
-- ==================================================================

CREATE Procedure [dbo].[sp_WebSiteGetAdData]
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
				[Pattern].MediaStream,ad.recutdetail, [Market].[Descrip] as FirstRunMarket
				FROM  Ad 
				INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] 
				left JOIN   [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id
				inner JOIN  [Advertiser] on [Advertiser].advertiserid=Ad.[AdvertiserID] 
				Left join   [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
				left join [Market] on [Market].[MarketID] = [Ad].[FirstRunMarketID]
                Where Ad.[AdID]=@AdID and [Creative].PrimaryIndicator is not null
		 END TRY
		 BEGIN CATCH
		      DECLARE @error INT, @message VARCHAR(4000), @lineno INT
			  SELECT @error=Error_number(),@message=Error_message(),@lineno=Error_line()
			  RAISERROR('sp_WebSiteGetAdData: %d: %s',16,1,@error,@message,@lineno);
		 END CATCH
End