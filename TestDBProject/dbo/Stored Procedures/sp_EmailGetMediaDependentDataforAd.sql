-- ======================================================================================
-- Author		: Karunakar
-- Create date	: 27/10/2015
-- Description	: Email Media Dependent Data for Ad
-- Exec			: sp_EmailGetMediaDependentDataforAd
-- Updated By	: 
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_EmailGetMediaDependentDataforAd] 
	@pOccurrenceId as bigint
AS
BEGIN
	
	SET NOCOUNT ON;

	   DECLARE @FirstRunDate AS VARCHAR(200) 
	   DECLARE @LastRunDate AS VARCHAR(200)			 
	   DECLARE @FirstRunMarket AS VARCHAR(200)

	   SELECT top 1 @FirstRunDate = AdDT,@FirstRunMarket = m.Descrip
		  FROM Pattern p inner join OccurrenceDetailEM o on p.patternid = o.patternid
		  LEFT JOIN Market m on o.MarketID = m.MarketID
	   WHERE o.OccurrenceDetailEMID = @pOccurrenceId
	   ORDER BY AdDT asc

	   SELECT top 1 @LastRunDate = AdDT
		  FROM Pattern p inner join OccurrenceDetailEM o on p.patternid = o.patternid
	   WHERE o.OccurrenceDetailEMID = @pOccurrenceId
	   ORDER BY AdDT desc
	   
	   IF ISDATE(@FirstRunDate) = 0 
		  SET @FirstRunDate = GETDATE()
	   IF ISDATE(@LastRunDate) = 0 
		  SET @LastRunDate = GETDATE()

	   Select '' as [length],
	   @FirstRunMarket as FirstRunMarket,CONVERT(DATETIME,@FirstRunDate) as [FirstRunDate],CONVERT(DATETIME,@LastRunDate) as [LastRunDate] 
	   --[AdDT],[Market].[Descrip],from  [dbo].[OccurrenceDetailEM] 
	   --inner join [Market] on  [OccurrenceDetailEM].[MarketID]=[Market].[MarketID]
	   --where [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]=@pOccurrenceId

END

