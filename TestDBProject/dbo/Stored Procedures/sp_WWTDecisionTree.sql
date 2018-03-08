CREATE procedure [dbo].[sp_WWTDecisionTree] (
	@IndustryID int = null,
	@AdvertiserID int = null,
	@MediaStreamID varchar(50) = null,
	@PublicationID int = null,
	@Status varchar(50) output
)
as
begin
	declare @WhatWeTake WhatWeTakeData
	declare @PubGroupList PubGroupListData

	if @AdvertiserID is not null begin
		declare @advCount int
		select @advCount = count(1) 
		from WhatWeTake
		where AdvertiserID = @AdvertiserID
		and (EffectiveDT >= current_timestamp or EffectiveDT is null)
		and (EndDT <= current_timestamp or EndDT is null)
		print '@advCount: ' + cast(@advCount as varchar(10))

		if @advCount > 0 begin
			print '@advCount > 0...Advertiser found...'
			insert into @PubGroupList
			select pg.PubGroupID, pe.MarketID
			from PublicationGrouping pg
			inner join PubEdition pe on pg.PublicationID = pe.PublicationID
			where pg.PublicationID = @PublicationID
			select * from @PubGroupList

			insert into @WhatWeTake
			select 
				wwt.WWTIndustryID,
				wwt.AdvertiserID,
				pgl.PubGroupID,
				pgl.MarketID,
				wwt.PublicationID,
				wwt.WWTRuleID
			from WhatWeTake wwt, @PubGroupList pgl
			where wwt.AdvertiserID = @AdvertiserID
			and wwt.PublicationID = @PublicationID
			or (wwt.MarketID = pgl.MarketID
				and wwt.PubGroupID = pgl.PubGroupID
				and wwt.PublicationID is null
			)
			and (wwt.EffectiveDT >= current_timestamp or wwt.EffectiveDT is null)
			and (wwt.EndDT <= current_timestamp or wwt.EndDT is null)
			select * from @WhatWeTake

			if @@rowcount > 0 begin
				print 'Advertiser Match!'
				--exec sp_WWTListforDisplay @WhatWeTake
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
					a.AdvertiserID in (
						select AdvertiserID from @WhatWeTake
					)
			end
			else begin
				print 'No match...'
				declare @advMediaCount int
				select @advMediaCount = count(1)
				from WhatWeTake 
				where AdvertiserID = @AdvertiserID
				and MediaStream <> @MediaStreamID
				and (EffectiveDT >= current_timestamp or EffectiveDT is null)
				and (EndDT <= current_timestamp or EndDT is null)

				if @advMediaCount > 0 begin
					print 'NO TAKE - End Lookup'
					set @Status = 'No Take'
				end
			end
		end

		--final case
		insert into @WhatWeTake
		select distinct
			wwt.WWTIndustryID,
			wwt.AdvertiserID,
			wwt.PubGroupID,
			wwt.MarketID,
			wwt.PublicationID,
			wwt.WWTRuleID
		from WhatWeTake wwt
		inner join Advertiser a on wwt.AdvertiserID = a.AdvertiserID
		inner join WWTIndustryAdvertiser ia on wwt.WWTIndustryID = ia.WWTIndustryID
		where wwt.AdvertiserID = @AdvertiserID
		and wwt.AdvertiserID = a.AdvertiserID
		--or (
		--	--document specifies join from ia to a on IndustryGroupID. Incorrect? Doesn't exist
		--)
		and (wwt.EffectiveDT >= current_timestamp or wwt.EffectiveDT is null)
		and (wwt.EndDT <= current_timestamp or wwt.EndDT is null)
		select * from @WhatWeTake

		if @@rowcount = 0 begin
			print 'Nothing returned! Alert user.'
			set @Status = 'Empty'
		end
	end

	if @IndustryID is not null begin
		declare @indCount int
		select @indCount = count(1)
		from WhatWeTake
		where WWTIndustryID = @IndustryID
		--and MediaStream = @MediaStreamID
		and (EffectiveDT >= current_timestamp or EffectiveDT is null)
		and (EndDT <= current_timestamp or EndDT is null)
		print '@indCount: ' + cast(@indCount as varchar(10))

		if @indCount > 0 begin
			if @PublicationID is not null begin
				insert into @PubGroupList
				select pg.PubGroupID, pe.MarketID
				from PublicationGrouping pg
				inner join PubEdition pe on pg.PublicationID = pe.PublicationID
				where pg.PublicationID = @PublicationID
				--select * from @PubGroupList

				insert into @WhatWeTake
				select 
					wwt.WWTIndustryID,
					wwt.AdvertiserID,
					wwt.PubGroupID,
					wwt.MarketID,
					wwt.PublicationID,
					wwt.WWTRuleID
				from WhatWeTake wwt, @PubGroupList pgl
				where wwt.WWTIndustryID = @IndustryID
				and wwt.PublicationID = @PublicationID
				or (wwt.MarketID = pgl.MarketID
					and wwt.PubGroupID = pgl.PubGroupID
					and wwt.PublicationID is null
				)
				and (wwt.EffectiveDT >= current_timestamp or wwt.EffectiveDT is null)
				and (wwt.EndDT <= current_timestamp or wwt.EndDT is null)
				--select * from @WhatWeTake

				if @@rowcount > 0 begin
					print 'Industry Match!'
					--exec sp_WWTListforDisplay @WhatWeTake
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
						wwt.WWTIndustryID in (
							select IndustryID from @WhatWeTake
						)
				end
			end
		end
	end

	print 'NO TAKE - End Lookup'
	set @Status = 'No Take'
end