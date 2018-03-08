CREATE PROCEDURE [dbo].[sp_InsertAdvertiserAddress] (
	--@AdvertiserAddressID int out,
	@AdvertiserID int,
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(10),
	@ZipCode varchar(10),
	@CreatedByID int
)
as
begin
insert into AdvertiserAddress
values (
	@AdvertiserID,
	@Address1,
	@Address2,
	@City,
	@State,
	@ZipCode,
	CURRENT_TIMESTAMP,
	@CreatedByID,
	null,
	null
)
--select @AdvertiserAddressID = SCOPE_IDENTITY()
end
