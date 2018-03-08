CREATE PROCEDURE [dbo].[sp_UpdateAdvertiserRegistration] 
@Address1 nvarchar(MAX),
@AdvertiserID int
AS

UPDATE Advertiser
SET Address1 = @Address1
WHERE AdvertiserID = @AdvertiserID