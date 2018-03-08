/****** Object:  StoredProcedure [dbo].[sp_UpdateAdTakeCount]    Script Date: 5/9/2016 11:20:10 AM ******/
CREATE PROCEDURE [dbo].[sp_UpdateAdTakeCount](
	@AdTakeCountID int,
	@MediaStream int,
	@LanguageID int,
	@MonthYear varchar(50),
	@MaxTakeCount int
)
as
begin
	update AdTakeCount
	set
		MediaStream = @MediaStream,
		LanguageID = @LanguageID,
		MonthYear = @MonthYear,
		MaxTakeCount = @MaxTakeCount
	where AdTakeCountID = @AdTakeCountID
end