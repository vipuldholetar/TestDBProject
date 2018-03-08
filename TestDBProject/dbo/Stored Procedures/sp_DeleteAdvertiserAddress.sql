CREATE PROCEDURE [dbo].[sp_DeleteAdvertiserAddress](
	@AdvertiserAddressID int
)
as
begin
	delete from AdvertiserAddress
	where AdvertiserAddressID = @AdvertiserAddressID
end