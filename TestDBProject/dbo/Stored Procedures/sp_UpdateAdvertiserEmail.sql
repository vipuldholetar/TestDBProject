/****** Object:  StoredProcedure [dbo].[sp_UpdateAdvertiserEmail]    Script Date: 5/9/2016 11:19:43 AM ******/
CREATE PROCEDURE [dbo].[sp_UpdateAdvertiserEmail](
	@AdvertiserEmailID int,
	@MarketID int,
	@Email varchar(50),
	@ModifiedByID int
)
as
begin
	update AdvertiserEmail
	set
		MarketID = @MarketID,
		Email = @Email,
		ModifiedByID = @ModifiedByID,
		ModifiedDT = CURRENT_TIMESTAMP
	where AdvertiserEmailID = @AdvertiserEmailID
end