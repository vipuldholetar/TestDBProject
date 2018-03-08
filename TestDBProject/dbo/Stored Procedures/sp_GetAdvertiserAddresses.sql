CREATE PROCEDURE [dbo].[sp_GetAdvertiserAddresses] (
	@AdvertiserID int
)
AS
BEGIN
	select
		AdvertiserAddressID,
		AdvertiserID,
		Address1,
		Address2,
		City,
		State,
		ZipCode,
		CreatedDT,
		CreatedByID,
		ModifiedDT,
		ModifiedByID
	from AdvertiserAddress
	where AdvertiserID = @AdvertiserID
END
