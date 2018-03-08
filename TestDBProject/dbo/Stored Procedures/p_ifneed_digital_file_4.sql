
CREATE procedure [dbo].[p_ifneed_digital_file_4]
	@p_InputPRCode varchar(200)
	, @p_CaptureStation varchar(200)
	, @p_CaptureDate date
	, @p_output_pr_code varchar(200) output
	, @p_MAP_CPTK_MC int output
	, @p_MTBADTP varchar(50) output
	, @p_CSM_NTCHNAM varchar(200) output
	, @p_MAP_PRIORITY int output
	, @p_MTADLEN int output
	, @p_MCHD_RESOLUTION varchar(2) output
as
begin
	declare @pattern varchar(255)

	Select @pattern = TVMMPRCodeCODE
	From Pattern p with (nolock)
	join TVMMPRCode m with (nolock) on p.CreativeSignature = m.OriginalPatternCode
	where m.OriginalPatternCode = @p_InputPRCode
	and (@p_CaptureDate between EffectiveStartDT and EffectiveEndDT
		or EffectiveStartDT is null
		or EffectiveEndDT is null)
	and exists(select 1 
				from TVStation t1 with (nolock)
				join TVRecordingSchedule trs with (nolock) on t1.tvstationid = trs.TVStationID
				where t1.marketID = m.ApprovedMarketID
				and isnull(trs.EffectiveEndDT, '31 DEC 2049') > @p_CaptureDate
				and trs.CaptureStationCode = @p_CaptureStation)

	if @pattern is null
	begin
		set @pattern = @p_InputPRCode
	end

	Select @p_output_pr_code = o.PRCODE
			, @p_MAP_CPTK_MC = a.AdID
			, @p_MTBADTP = config.Value
			, @p_CSM_NTCHNAM = t.StationShortName
			, @p_MAP_PRIORITY = p.priority
			, @p_MTADLEN = a.adlength
			, @p_MCHD_RESOLUTION = isnull(cd.CreativeResolution,'SD')
	From OccurrenceDetailTV o with (nolock)
	join TVStation t with (nolock) on t.TVStationID = o.StationID
	join Pattern p with (nolock) on p.PatternID = o.PatternID
	left join Ad a with (nolock) on p.AdID = a.AdID
	left join Creative c with (nolock) on a.AdID = c.AdID 
	left join Configuration config with (nolock) on config.ConfigurationID = c.PrimaryQuality
	left join CreativeDetailTV cd with (nolock) on c.PK_Id = cd.CreativeMasterID
	where o.PRCODE = @pattern
	and o.CaptureStationCode = @p_CaptureStation
	and cast(o.AirDT as Date) = @p_CaptureDate
end
