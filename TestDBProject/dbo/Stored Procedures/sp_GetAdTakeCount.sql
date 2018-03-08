/****** Object:  StoredProcedure [dbo].[sp_GetAdTakeCount]    Script Date: 5/6/2016 11:22:59 PM ******/
CREATE PROCEDURE [dbo].[sp_GetAdTakeCount] (
	@AdvertiserID int
)
AS
BEGIN
	select
		AdTakeCountID,
		AdvertiserID,
		MediaStream,
		l.LanguageID,
		l.Description,
		MonthYear,
		MaxTakeCount
		from AdTakeCount ad
		 join
		 Language l
	on	 ad.LanguageId = l.LanguageId
	where AdvertiserID = @AdvertiserID
END