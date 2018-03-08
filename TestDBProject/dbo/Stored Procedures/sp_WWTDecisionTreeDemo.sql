CREATE procedure [dbo].[sp_WWTDecisionTreeDemo] (
	@IndustryID int = null,
	@AdvertiserID int = null,
	@MediaStreamID varchar(50) = null,
	@PublicationID int = null--,
	--@Status varchar(50) output
)
as
begin
	if @AdvertiserID is not null and @AdvertiserID <> 0 begin
		select distinct
			case 
				when (i.IndustryName is null or i.IndustryName = '') then
				'ALL' else i.IndustryName end as IndustryName,
			case 
				when (a.Descrip is null or a.Descrip = '') then
				'ALL' else a.Descrip end as Descrip,
			rt.RuleType,
			rn.RuleNote
		from
			WhatWeTake wwt
		join
			Advertiser a on wwt.AdvertiserID = a.AdvertiserID
		join
			WWTRule r on wwt.WWTRuleID = r.WWTRuleID
		join
			RuleType rt on r.RuleTypeID = rt.RuleTypeID
		left join
			WWTRuleNote rn on r.WWTRuleNoteID = rn.WWTRuleNoteID
		left join
			WWTIndustry i on wwt.WWTIndustryID = i.WWTIndustryID
		where
			a.AdvertiserID = @AdvertiserID

		--set @Status = 'Advertiser Match'
	end

	if @IndustryID is not null and @IndustryID <> 0 begin
		--select distinct
		--	case 
		--		when (i.IndustryName is null or i.IndustryName = '') then
		--		'ALL' else i.IndustryName end as IndustryName,
		--	case 
		--		when (a.Descrip is null or a.Descrip = '') then
		--		'ALL' else a.Descrip end as Descrip,
		--	rt.RuleType,
		--	rn.RuleNote
		--from
		--	WhatWeTake wwt
		--join
		--	Advertiser a on wwt.AdvertiserID = a.AdvertiserID
		--join
		--	WWTRule r on wwt.WWTRuleID = r.WWTRuleID
		--join
		--	RuleType rt on r.RuleTypeID = rt.RuleTypeID
		--left join
		--	WWTRuleNote rn on r.WWTRuleNoteID = rn.WWTRuleNoteID
		--left join
		--	WWTIndustry i on wwt.WWTIndustryID = i.WWTIndustryID
		--where
		--	wwt.WWTIndustryID = @IndustryID

		select distinct
			case 
				when (i.IndustryName is null or i.IndustryName = '') then
				'ALL' else i.IndustryName end as IndustryName,
			case 
				when (a.Descrip is null or a.Descrip = '') then
				'ALL' else a.Descrip end as Descrip,
			rt.RuleType,
			rn.RuleNote
		from
			WWTIndustry i 
		inner join 
			WWTIndustryAdvertiser IA on IA.WWTIndustryID=i.WWTIndustryID
		inner join
			WhatWeTake wwt on i.WWTIndustryID = wwt.WWTIndustryID
		inner join
			Advertiser a on IA.AdvertiserID = a.AdvertiserID
		left join
			WWTRule r on wwt.WWTRuleID = r.WWTRuleID
		left join
			RuleType rt on r.RuleTypeID = rt.RuleTypeID
		left join
			WWTRuleNote rn on r.WWTRuleNoteID = rn.WWTRuleNoteID
		where
			i.WWTIndustryId = @IndustryID

		--set @Status = 'Industry Match'
	end

	--if @@rowcount < 1 begin
	--	print 'NO TAKE - End Lookup'
	--	set @Status = 'No Take'
	--end
end