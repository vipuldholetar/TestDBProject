-- ===========================================================================
-- Author			: Karunakar
-- Create date		: 08/05/14
-- Description		: This Procedure is Used to Getting Ad Data for Radio
-- Execution		: sp_GetAdData 1115
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--					  Karunakar on 7th Sep 2015
--=============================================================================
CREATE PROCEDURE [dbo].[sp_GetAdData]
(
@AdID as int
)
AS
BEGIN

	SET NOCOUNT ON;
		 BEGIN TRY
			SELECT  Distinct [LeadAvHeadline],LeadText,[AdVisual],[Description],[Advertiser].[AdvertiserID],Ad.[LanguageID],[CommonAdDT],[InternalNotes],[NoTakeAdReason],[AdLength],
			[Creative].PrimaryQuality AS[PrimaryCreativeQuality],[OriginalAdID],RecutAdId,FirstRunDate,LastRunDate, [TradeClass].Descrip as TradeClass,'' As   CoreSupplementalStatus,
			''  as Distributiontype ,[Advertiser].descrip as rcsadvertisername,[Pattern].MediaStream,Ad.RecutDetail, Market.Descrip as FirstRunMarket
			FROM Ad 
			INNER JOIN [Creative] ON Ad.[AdID] = [Creative].[AdId]
			INNER JOIN [Pattern] ON Ad.[AdID] = [Pattern].[AdID] 
			INNER JOIN [Advertiser] on [Advertiser].Advertiserid=Ad.[AdvertiserID] 
			left join [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
			left join [Market] on [Market].[MarketID] = [Ad].[FirstRunMarketID]
			Where  Ad.[AdID]=@AdiD and  [Creative].primaryindicator=1
		END  TRY
		BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetAdData]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH
END