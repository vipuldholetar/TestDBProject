CREATE procedure [dbo].[sp_WWTListforDisplay] (
	@WhatWeTake WhatWeTakeData readonly
)
as
begin
	select
		case 
			when (i.IndustryName is null or i.IndustryName = '') then
			'ALL' else i.IndustryName end as IndustryName,
		case 
			when (a.Descrip is null or a.Descrip = '') then
			'ALL' else a.Descrip end as Descrip,
		--coalesce(i.IndustryName, '') as IndustryName,
		--coalesce(a.Descrip, '') as Descrip,
		rt.RuleType as RuleType,
		null as RuleName
	from
		@WhatWeTake wwt
	right join
		WWTRule r on wwt.RuleID = r.WWTRuleID
	inner join
		RuleType rt on r.RuleTypeID = rt.RuleTypeID
	inner join
		WWTRuleNote rn on r.WWTRuleNoteID = rn.WWTRuleNoteID
	right join
		WWTIndustry i on wwt.IndustryID = i.WWTIndustryID
	left join
		Advertiser a on wwt.AdvertiserID = a.AdvertiserID
	order by 
		a.Descrip, r.WWTRuleID
end