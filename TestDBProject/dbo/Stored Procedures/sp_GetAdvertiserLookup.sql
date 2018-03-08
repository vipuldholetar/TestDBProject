/****** Object:  StoredProcedure [dbo].[sp_GetAdvertiserLookup]    Script Date: 5/13/2016 2:09:24 PM ******/
CREATE PROCEDURE [dbo].[sp_GetAdvertiserLookup] (
	@UserInput varchar(100)
)
AS
BEGIN
select distinct
		a.AdvertiserID,
		a.Descrip,
		wi.WWTIndustryID as WWTIndustryID, --as RefIndustryGroupID,
		wi.IndustryName
	from 
		Advertiser as a 
		join WWTIndustryAdvertiser wia on wia.AdvertiserId = a.AdvertiserId
		join WWTIndustry wi on wi.WWTIndustryID = wia.WWTIndustryID
	where 
		(a.Descrip like '%'+ @UserInput + '%' 
		or wi.IndustryName like '%'+ @UserInput + '%')
		and isnull(a.EndDT,'31 DEC 2099') > SYSDATETIME ( )
END