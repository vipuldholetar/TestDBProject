CREATE PROCEDURE [dbo].[sp_OutdoorGetMediaDependentDataforAd] 
	@pOccurrenceId as bigint
AS
BEGIN
	
	SET NOCOUNT ON;

	   DECLARE @FirstRunDate AS VARCHAR(200) 
	   DECLARE @LastRunDate AS VARCHAR(200)			 
	   DECLARE @FirstRunMarket AS VARCHAR(200)
	
	   SELECT top 1 @FirstRunDate = DatePictureTaken,@FirstRunMarket = m.Descrip
		  FROM Pattern p inner join OccurrenceDetailODR o on p.patternid = o.patternid
		  LEFT JOIN Market m on o.MTMarketID = m.MarketID
	   WHERE o.OccurrenceDetailODRID = @pOccurrenceId
	   ORDER BY DatePictureTaken asc

	   SELECT top 1 @LastRunDate = DatePictureTaken
		  FROM Pattern p inner join OccurrenceDetailODR o on p.patternid = o.patternid
	   WHERE o.OccurrenceDetailODRID = @pOccurrenceId
	   ORDER BY DatePictureTaken desc

	   IF ISDATE(@FirstRunDate) = 0 
		  SET @FirstRunDate = GETDATE()
	   IF ISDATE(@LastRunDate) = 0 
		  SET @LastRunDate = GETDATE()

	   Select '' as [length],
			 @FirstRunMarket as FirstRunMarket,CONVERT(DATETIME,@FirstRunDate) as [FirstRunDate],CONVERT(DATETIME,@LastRunDate) as [LastRunDate] 
	  --AdID,DatePictureTaken,[Market].[Descrip], from  [dbo].[OccurrenceDetailODR] 
	   --inner join [Market] on  [OccurrenceDetailODR].[MTMarketID]=[Market].[MarketID]
	   --where [dbo].[OccurrenceDetailODR].[OccurrenceDetailODRID]=@pOccurrenceId

END
