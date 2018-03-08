CREATE procedure [dbo].[sp_GetIncludedIndustries]
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

end