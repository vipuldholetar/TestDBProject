/****** Object:  StoredProcedure [dbo].[sp_InsertAdTakeCount]    Script Date: 5/9/2016 11:16:44 AM ******/
CREATE PROCEDURE [dbo].[sp_InsertAdTakeCount] (
	@AdvertiserID int,
	@MediaStream int,
	@LanguageID int,
	@MonthYear varchar (50),
	@MaxTakeCount int
)
as
begin
insert into AdTakeCount
values (
	@AdvertiserID,
	@MediaStream,
	@LanguageID,
	@MonthYear,
	@MaxTakeCount
)
end