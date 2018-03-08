CREATE procedure [dbo].[sp_GetAdvertiserIndustryByID] (
	@AdvertiserID int
)
as
begin
	--select
	--	a.AdvertiserID,
	--	a.Descrip,
	--	rig.RefIndustryGroupID,
	--	rig.IndustryName
	--from 
	--	Advertiser as a 
	--left join
	--	AdvertiserIndustryGroup aig on a.AdvertiserID = aig.AdvertiserID
	--left join 
	--	RefIndustryGroup AS rig on aig.IndustryGroupID = rig.RefIndustryGroupID
	--where
	--	a.AdvertiserID = @AdvertiserID
	select distinct
		a.AdvertiserID,
		a.Descrip,
		ia.WWTIndustryID,
		--rig.RefIndustryGroupID, --L.E.6.15 app expecting WWTIndustryID
		rig.IndustryName
	from 
		Advertiser as a 
	left join
		AdvertiserIndustryGroup aig on a.AdvertiserID = aig.AdvertiserID
	left join 
		RefIndustryGroup AS rig on aig.IndustryGroupID = rig.RefIndustryGroupID
	left join
		WWTIndustryAdvertiser ia on a.AdvertiserID = ia.AdvertiserID
	left join
		WWTIndustry i on ia.WWTIndustryID = i.WWTIndustryID
	where
		a.AdvertiserID = @AdvertiserID
end