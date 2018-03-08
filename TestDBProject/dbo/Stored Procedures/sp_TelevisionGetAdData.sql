
-- ==================================================================
-- Author			:	Arun Nair  
-- Create date		:	28th July 2015
-- Description		:	This Procedure is Used to Getting Ad for Television
-- Execution Process:   sp_TelevisionGetAdData 13166
-- Updated By		:	Updated By Karunakar on 28th july 2015
--					:	Arun on 08/13/2015 -Cleanup OnemT 
				
-- ==================================================================

CREATE PROCEDURE [dbo].[sp_TelevisionGetAdData]
(
@AdID AS INTEGER
)
AS
BEGIN
SET NOCOUNT ON;
			BEGIN TRY
				SELECT  Ad.[AdID] AS [AdID],Ad.LeadAvHeadline AS [LeadAudioHeadline],Ad.LeadText AS [Lead_Text],Ad.AdVisual AS [AD_Visual],[Description],[Advertiser].[AdvertiserID],
				ad.[LanguageID],[CommonAdDT],Ad.InternalNotes AS [Internal_Notes],[NoTakeAdReason],Ad.AdLength AS [Ad_Length],[Creative].PrimaryQuality AS [PrimaryCreativeQuality],
				[OriginalAdID],Ad.RecutAdId AS [Recut_AdId],Ad.FirstRunDate AS [First_Run_Date],Ad.LastRunDate AS [Last_Run_Date], [TradeClass].[Descrip] AS TradeClass,
				'' As   CoreSupplementalStatus,''  AS Distributiontype , [Advertiser].descrip AS advertisername,
				[Pattern].MediaStream,Ad.RecutDetail AS recut_detail, [Market].[Descrip] AS [First_Run_Market]
				FROM  AD 
				INNER JOIN  [Pattern] ON AD.[AdID] = [Pattern].[AdID] 
				LEFT JOIN [Creative] ON [Pattern].[CreativeID]=[Creative].PK_Id
				INNER JOIN   [Advertiser] ON [Advertiser].advertiserid=ad.[AdvertiserID] 
				LEFT JOIN [TradeClass] ON [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
				left join [Market] on [Market].[MarketID] = [Ad].[FirstRunMarketID]
                Where Ad.[AdID]=@AdID and [Creative].PrimaryIndicator IS NOT NULL
				
			END TRY
			 BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_TelevisionGetAdData]: %d: %s',16,1,@error,@message,@lineNo);
			END CATCH 

END