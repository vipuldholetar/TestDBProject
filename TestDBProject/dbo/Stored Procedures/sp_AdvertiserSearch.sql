CREATE PROCEDURE [dbo].[sp_AdvertiserSearch](
	@AdvertiserDescrip varchar (100)
)
AS
BEGIN
SELECT 
	a.AdvertiserID, 
	a.Descrip, 
	a.ShortName, 
	a.LanguageID, 
	a.ParentAdvertiserID,
	b.Descrip as ParentDescrip,
	a.TradeClassID, 
	a.IndustryID,  
	a.StartDT, 
	a.EndDT, 
	a.AdvertiserComments,
	a.CTLegacyINSTCOD, 
	a.[State]
FROM Advertiser a
left join Advertiser b on a.ParentAdvertiserID = b.AdvertiserID
WHERE a.Descrip = @AdvertiserDescrip
and isnull(a.EndDT,'31 DEC 2099') > SYSDATETIME()
END