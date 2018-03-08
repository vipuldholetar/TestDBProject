CREATE PROCEDURE [dbo].[sp_GetAdvertiserAddress] (
	@AdvertiserID int
)
as
begin
select 
	Address1,
	Address2,
	City,
	State,
	ZipCode
from AdvertiserAddress 
where AdvertiserID = @AdvertiserID
end
