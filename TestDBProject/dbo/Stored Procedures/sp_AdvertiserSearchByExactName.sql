CREATE procedure [dbo].[sp_AdvertiserSearchByExactName](
	@AdvertiserName varchar (255)
)
as
begin
	select 
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
		a.State
	from Advertiser a
	left join Advertiser b on a.ParentAdvertiserID = b.AdvertiserID
	where a.Descrip = @AdvertiserName 
	and isnull(a.EndDT,DATEADD(DAY,1,GETDATE())) > GETDATE()
end