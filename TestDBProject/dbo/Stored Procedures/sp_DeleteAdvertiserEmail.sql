/****** Object:  StoredProcedure [dbo].[sp_DeleteAdvertiserEmail]    Script Date: 5/9/2016 10:38:37 AM ******/
CREATE PROCEDURE [dbo].[sp_DeleteAdvertiserEmail](
	@AdvertiserEmailID int
)
as
begin
	delete from AdvertiserEmail
	where AdvertiserEmailID = @AdvertiserEmailID
end