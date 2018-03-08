CREATE PROCEDURE [dbo].[sp_UpdateAdvertiserAddress](
	@AdvertiserAddressID int,
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(10),
	@ZipCode varchar(10),
	@ModifiedByID int
)
as
begin
	update AdvertiserAddress
	set
		Address1 = @Address1,
		Address2 = @Address2,
		City = @City,
		State = @State,
		ZipCode = @ZipCode,
		ModifiedByID = @ModifiedByID,
		ModifiedDT = CURRENT_TIMESTAMP
	where AdvertiserAddressID = @AdvertiserAddressID
end