/****** Object:  StoredProcedure [dbo].[sp_WTRRecords]    Script Date: 5/18/2016 10:33:15 PM ******/
CREATE PROCEDURE [dbo].[sp_WTRRecords] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	/****** Script for SelectTopNRows command from SSMS  ******/

SELECT TOP 10 [OccurrenceID]
      ,[Advertiser]
      ,[Subject]
      ,[Sender]
      ,[Priority]
      ,[Tradeclass]
      ,[Market]
      ,[MarketCode]
      ,[AdDate]
      ,[ImageAge]
      ,[OfficeLocation]
      ,[AdID]
      ,[SourceEmail]
      ,[LandingPageURL]
      ,[DistributionDate]
      ,[PatternMasterID]
      ,[TradeClassID]
      ,[LocationCode]
      ,[AdvertiserID]
      ,[CreateDate]
      ,[Query]
      ,[OccurrenceStatus]
      ,[MapStatus]
      ,[IndexStatus]
      ,[ScanStatus]
      ,[QCStatus]
      ,[RouteStatus]
      ,[LanguageID]
      ,[Language]
      ,[UserID]
      ,[QryRaisedOn]
      ,[ParentOccurrenceId]
      ,[MarketID]
  FROM [OneMT_Dev].[dbo].[vw_EmailWorkQueueData]
  order by newid()
END