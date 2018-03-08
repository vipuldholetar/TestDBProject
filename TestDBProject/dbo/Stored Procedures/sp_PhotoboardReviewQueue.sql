CREATE PROCEDURE [dbo].[sp_PhotoboardReviewQueue] (
	@MediaStream varchar(50),
	@AdvertiserID varchar(50),
	@CreateFrom date,
	@CreateTo date)
AS
begin
declare @sql nvarchar(max)
	
set @sql = 'SELECT	0 as Priority,
					a.AdID as AdID,
					c.Descrip as Advertiser,
					b.CreateDate,
					a.FinishedDT,
					(d.FName + '' '' + d.Lname) as FinishedBy,
					CASE WHEN Status = ''R'' THEN ''Y''
						ELSE ''N'' END as Replace,
					(select Fname + '' '' + Lname from [User] where isnull(a.AuditByID,0) = UserId) + ''/'' + cast(a.AuditDT as varchar(50)) as AuditedBy,
					a.PhotoboardID as PhotoboardID,
					a.MediaStream,
					b.AdvertiserID as AdvertiserID
			FROM	Photoboard a, Ad b, Advertiser c, [User] d
			WHERE	b.AdID = a.AdID
					AND 
					c.AdvertiserID = b.AdvertiserID
					AND 
					d.UserID = a.FinishedByID
					AND
					a.Status IN (''F'',''R'')
					AND 
					a.Deleted = 0'

		if (@MediaStream <> '') begin
			set @sql += ' and pb.MediaStream in (' + @MediaStream + ') '
		end

		if (@AdvertiserID <> 0) begin
			set @sql += ' and b.AdvertiserID = ' + @AdvertiserID  +  ''
		end

		if (@CreateFrom <> '' and @CreateTo <> '') begin
			set @sql += ' and b.CreateDate between ''' + cast(@CreateFrom as varchar(50)) + ''' and ''' + cast(@CreateTo as varchar(50)) + ''' '
		end

	set @sql += ' ORDER BY Priority, AdID ASC'

	exec sp_executesql @sql
end