CREATE procedure [dbo].[sp_CPGetPhotoboardWorkQueue] (
	@MediaStream varchar(50),
	@Advertiser varchar(50),
	@AdCreateDTFrom datetime,
	@AdCreateDTTo datetime
)
as
begin
	declare @sql nvarchar(max)
	set @sql = '
	select
		--ad.[Priority]
		0 as [Priority],
		pb.AdID,
		adv.Descrip as Advertiser,
		ad.CreateDate,
		pb.StartedDT,
		(u.FName + '' '' + u.LName) as AssignedTo,
		case when pb.Status = ''R'' then ''Y'' else ''N'' end as [Replace],
		pb.PhotoboardID,
		pb.MediaStream,
		ad.AdvertiserID,
		ad.LeadText,
		ad.AdLength,
		case when ad.OriginalAdID is null then ''New'' else ''Recut'' end as NewRecut,
		ad.FirstRunDate,
		p.ProductName
	from 
		Photoboard pb 
	inner join 
		Ad ad on pb.AdID = ad.AdID 
	inner join 
		Advertiser adv on ad.AdvertiserID = adv.AdvertiserID 
	left join 
		[User] u on pb.AssignedToID = u.UserID 
	inner join 
		RefProduct p on ad.ProductId = p.RefProductID 
	where 
		(pb.Status is null or pb.Status not in (''F'', ''X'')) 
	and 
		pb.Deleted = 0 '

	if (@MediaStream <> '') begin
		set @sql += 'and pb.MediaStream in (' + @MediaStream + ') '
	end

	if (@Advertiser <> '') begin
		set @sql += 'and adv.Descrip LIKE ''%' + @Advertiser + '%'' '
	end

	if (@AdCreateDTFrom <> '' and @AdCreateDTTo <> '') begin
		set @sql += 'and ad.CreateDate between ''' + cast(@AdCreateDTFrom as varchar(50)) + ''' and ''' + cast(@AdCreateDTTo as varchar(50)) + ''' '
	end

	set @sql += 'order by pb.AdID asc'

	print @sql

	exec sp_executesql @sql
end