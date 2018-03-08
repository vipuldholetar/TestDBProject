
-- ==================================================================
-- Author			  :	Arun Nair 
-- Create date		  :	13/06/2015
-- Description		  :	Select Ad Details in DPF For Publication
-- Execution Process  :  sp_OutdoorGetAdData 8078
-- Updated By		  :	Updated By Karunakar on 28th july 2015
-- Updated By		  : Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- ==================================================================

CREATE Procedure [dbo].[sp_OutdoorGetAdData]
(@AdID as int)
As
BEGIN
SET NOCOUNT ON;

         BEGIN TRY
			 DECLARE @PatternId as INTEGER
			 DECLARE @FirstRunDate AS VARCHAR(200) 
			 DECLARE @LastRunDate AS VARCHAR(200)			 
			 DECLARE @FirstRunMarket AS VARCHAR(200)

			 SELECT top 1 @FirstRunDate = DatePictureTaken,@FirstRunMarket = m.Descrip
				FROM Pattern p inner join OccurrenceDetailODR o on p.patternid = o.patternid
				LEFT JOIN Market m on o.MTMarketID = m.MarketID
			 WHERE p.AdId = @AdID
			 ORDER BY DatePictureTaken asc

			 SELECT top 1 @LastRunDate = DatePictureTaken
				FROM Pattern p inner join OccurrenceDetailODR o on p.patternid = o.patternid
			 WHERE p.AdId = @AdID
			 ORDER BY DatePictureTaken desc

			 SELECT  Ad.[AdID] As [AdID],Ad.LeadAvHeadline ,[LeadText],[AdVisual],[Description],[Advertiser].[AdvertiserID],
			 Ad.[LanguageID],[CommonAdDT],[InternalNotes],[NoTakeAdReason],[AdLength],[Creative].PrimaryQuality,
			 [OriginalAdID],[RecutAdId], [TradeClass].[Descrip] as TradeClass,
			 '' As   CoreSupplementalStatus,''  as Distributiontype , [Advertiser].descrip as advertisername,
			 [Pattern].MediaStream,ad.recutdetail,@FirstRunMarket as FirstRunMarket,@FirstRunDate as [FirstRunDate],@LastRunDate as [LastRunDate]
			 FROM  Ad 
			 INNER JOIN  [Pattern] ON Ad.[AdID] = [Pattern].[AdID] 
			 left JOIN [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id and [Creative].PrimaryIndicator is not null
			 inner JOIN   [Advertiser] on [Advertiser].advertiserid=Ad.[AdvertiserID] 
			 Left join [TradeClass] on [Advertiser].[TradeClassID]=[TradeClass].[TradeClassID]
                 Where Ad.[AdID]=@AdID 
				-- Updated By PrimaryCreativeQuality to PrimaryCreativeIndicator
		 END TRY

		 BEGIN CATCH
		      DECLARE @error INT, @message VARCHAR(4000), @lineno INT
			  SELECT @error=Error_number(),@message=Error_message(),@lineno=Error_line()
			  RAISERROR('sp_OutdoorGetAdData: %d: %s',16,1,@error,@message,@lineno);
		 END CATCH
End