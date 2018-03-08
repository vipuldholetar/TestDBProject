CREATE procedure [dbo].[sp_WWTListforDisplayDemo] (
	@IndustryID int
)
as
begin
	select distinct
		i.IndustryName,
		a.Descrip,
		rt.RuleType,
		rn.RuleNote
	from
		RefIndustryGroup rig
	inner join 
		WWTIndustry i on rig.RefIndustryGroupID = i.RefIndustryGroupID
	inner join
		WhatWeTake wwt on i.WWTIndustryID = wwt.WWTIndustryID
	inner join
		Advertiser a on wwt.AdvertiserID = a.AdvertiserID
	left join
		WWTRule r on wwt.WWTRuleID = r.WWTRuleID
	left join
		RuleType rt on r.RuleTypeID = rt.RuleTypeID
	left join
		WWTRuleNote rn on r.WWTRuleNoteID = rn.WWTRuleNoteID
	where
		rig.RefIndustryGroupID = @IndustryID
end