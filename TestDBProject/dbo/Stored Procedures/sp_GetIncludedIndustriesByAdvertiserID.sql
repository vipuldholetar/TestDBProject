CREATE procedure [dbo].[sp_GetIncludedIndustriesByAdvertiserID] (
	@AdvertiserID int
)
as
begin
	select
		i.WWTIndustryID,
		i.RefIndustryGroupID,
		i.IndustryName
	from
		WWTIndustry i
	inner join
		WWTIndustryAdvertiser ia on i.WWTIndustryID = ia.WWTIndustryID
	where 
		ia.AdvertiserID = @AdvertiserID
end