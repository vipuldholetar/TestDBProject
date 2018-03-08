/****** Object:  StoredProcedure [dbo].[sp_InsertAdvertiserEmail]    Script Date: 5/9/2016 11:16:16 AM ******/
CREATE PROCEDURE [dbo].[sp_InsertAdvertiserEmail] (
	--@AdvertiserEmailID int out,
	@AdvertiserID int,
	@MarketID int,
	@Email varchar(50),
	@CreatedByID int
)
as
begin
insert into AdvertiserEmail
values (
	@AdvertiserID,
	@MarketID,
	@Email,
	CURRENT_TIMESTAMP,
	@CreatedByID,
	null,
	null
)
--select @AdvertiserEmailID = SCOPE_IDENTITY()
end