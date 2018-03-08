--USE [OneMT_Dev]
CREATE PROCEDURE [dbo].[sp_UpdatePatternStatistics]
	@MediaStream int
AS
BEGIN
   declare @processID int
   declare @startDate datetime
   declare @endDate datetime
   declare @mediaStreamValue varchar(4)

   select @mediaStreamValue = Value
   from Configuration with (NOLOCK)
   where ComponentName = 'Media Stream'
   and ConfigurationID = @MediaStream

   select @endDate = GETDATE()

   select @startDate = isnull(max(LastProcessedDT),'1900-01-01')
   from [PatternStatisticProcess]
   where MediaStream = @MediaStream


   select @startDate = LastProcessedDT, @endDate = CreatedDT
   from [PatternStatisticProcess]
   where [PatternStatisticProcessID] = SCOPE_IDENTITY()

   if @mediaStreamValue = 'OD' -- outdoor
	   begin
			--update first, otherwise we end up updating the same records we just inserted.
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.DatePictureTaken) over (partition by o.PatternID)  FirstRunDT
				, max(o.DatePictureTaken) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(o.MTMarketID) over (partition by o.PatternID order by o.DatePictureTaken) FirstMediaOutletID
				from OccurrenceDetailODR o with (NOLOCK)
				inner join  (select distinct PatternId from OccurrenceDetailODRLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT,
				PatternStatistic.FirstMediaOutletID = q.FirstMediaOutletID
			from q
			where PatternStatistic.PatternID = q.PatternID;
				
			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.DatePictureTaken) over (partition by o.PatternID)  FirstRunDT
			, max(o.DatePictureTaken) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(o.MTMarketID) over (partition by o.PatternID order by o.DatePictureTaken) FirstMediaOutletID
			from OccurrenceDetailODR o with (NOLOCK)
			inner join  (select distinct PatternId from OccurrenceDetailODRLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);		
		end
	else if @mediaStreamValue = 'EM' -- email
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(o.MarketID) over (partition by o.PatternID order by o.AdDT) FirstMediaOutletID
				from OccurrenceDetailEM o
				inner join  (select distinct PatternId from OccurrenceDetailEMLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT,
				PatternStatistic.FirstMediaOutletID = q.FirstMediaOutletID
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(o.MarketID) over (partition by o.PatternID order by o.AdDT) FirstMediaOutletID
			from OccurrenceDetailEM o
			inner join  (select distinct PatternId from OccurrenceDetailEMLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'TV' -- TV
		begin	

		/*
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(o.StationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
				from OccurrenceDetailTV o with (NOLOCK)
				where isnull(Deleted,0) = 0
				and PatternId in (select distinct PatternId from OccurrenceDetailTVLog l with (NOLOCK) where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
				and exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT,
				PatternStatistic.FirstMediaOutletID = q.FirstMediaOutletID
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(o.StationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
			from OccurrenceDetailTV o with (NOLOCK)
			where isnull(Deleted,0) = 0
			and PatternId in (select distinct PatternId from OccurrenceDetailTVLog l with (NOLOCK) where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
			and not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);*/


			--Updated 11.18.2017 to try a join instead of "in" in Where clause
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(o.StationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
				from OccurrenceDetailTV o with (NOLOCK)
					inner join  (select distinct PatternId from OccurrenceDetailTVLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where isnull(Deleted,0) = 0
				--and PatternId in (select distinct PatternId from OccurrenceDetailTVLog l with (NOLOCK) where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
				and exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT,
				PatternStatistic.FirstMediaOutletID = q.FirstMediaOutletID
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(o.StationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
			from OccurrenceDetailTV o with (NOLOCK)
					inner join  (select distinct PatternId from OccurrenceDetailTVLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where isnull(Deleted,0) = 0
			--and PatternId in (select distinct PatternId from OccurrenceDetailTVLog l with (NOLOCK) where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
			and not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);

		end
	else if @mediaStreamValue = 'RAD' -- Radio
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(o.RCSStationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
				from OccurrenceDetailRA o
				inner join  (select distinct PatternId from OccurrenceDetailRALog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where isnull(Deleted,0) = 0
				--and PatternId in (select distinct PatternId from OccurrenceDetailRALog l where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
				and exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT,
				PatternStatistic.FirstMediaOutletID = q.FirstMediaOutletID
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(o.RCSStationID) over (partition by o.PatternID order by o.AirDT) FirstMediaOutletID
			from OccurrenceDetailRA o
			inner join  (select distinct PatternId from OccurrenceDetailRALog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where isnull(Deleted,0) = 0
			--and PatternId in (select distinct PatternId from OccurrenceDetailRALog l where l.PatternId = o.PatternID and l.LogTimeStamp between @startDate and @endDate)
			and not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @MediaStream = 'CIN' -- Cinema
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, null FirstMediaOutletID
				from OccurrenceDetailCIN o
				inner join  (select distinct PatternId from OccurrenceDetailCINLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AirDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AirDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, null FirstMediaOutletID
			from OccurrenceDetailCIN o
			inner join  (select distinct PatternId from OccurrenceDetailCINLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'OND' -- Online Display
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(s.WebsiteID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
				from OccurrenceDetailOND o
				inner join  (select distinct PatternId from OccurrenceDetailONDLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				join ScrapeSession s on s.ScrapeSessionID = o.ScrapeSessionID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(s.WebsiteID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
			from OccurrenceDetailOND o
			inner join  (select distinct PatternId from OccurrenceDetailONDLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			join ScrapeSession s on s.ScrapeSessionID = o.ScrapeSessionID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'ONV' -- Online Video
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(s.WebsiteID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
				from OccurrenceDetailONV o
				inner join  (select distinct PatternId from OccurrenceDetailONVLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				join ScrapeSession s on s.ScrapeSessionID = o.ScrapeSessionID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(s.WebsiteID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
			from OccurrenceDetailOND o
			inner join  (select distinct PatternId from OccurrenceDetailONVLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			join ScrapeSession s on s.ScrapeSessionID = o.ScrapeSessionID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'MOB' -- Mobile
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(s.MobileTrackingMediaID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
				from OccurrenceDetailMOB o
				inner join  (select distinct PatternId from OccurrenceDetailMOBLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				join MobileCaptureSession s on CaptureSessionID = MobileCaptureSessionID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.OccurrenceDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.OccurrenceDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(s.MobileTrackingMediaID) over (partition by o.PatternID order by OccurrenceDT) FirstMediaOutletID
			from OccurrenceDetailMOB o
			inner join  (select distinct PatternId from OccurrenceDetailMOBLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			join MobileCaptureSession s on CaptureSessionID = MobileCaptureSessionID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'CIR' -- Circular
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AdDate) over (partition by o.PatternID)  FirstRunDT
				, max(o.AdDate) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, null FirstMediaOutletID
				from OccurrenceDetailCIR o
				inner join  (select distinct PatternId from OccurrenceDetailCIRLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AdDate) over (partition by o.PatternID)  FirstRunDT
			, max(o.AdDate) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, null FirstMediaOutletID
			from OccurrenceDetailCIR o
			inner join  (select distinct PatternId from OccurrenceDetailCIRLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'PUB' -- Publication
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, null FirstMediaOutletID
				from OccurrenceDetailPUB o
				inner join  (select distinct PatternId from OccurrenceDetailPubLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, null FirstMediaOutletID
			from OccurrenceDetailPUB o
			inner join  (select distinct PatternId from OccurrenceDetailPubLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end
	else if @mediaStreamValue = 'SOC' -- Social Brand
		begin	
		    --update first, otherwise we end up updating the same records we just inserted.					
			with q as (select distinct o.PatternID
				, count(*) over (partition by o.PatternID) TotalCount
				, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
				, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
				, null TotalSpend
				, first_value(WebsiteID) over (partition by o.PatternID order by AdDT) FirstMediaOutletID
				from OccurrenceDetailSOC o
				inner join  (select distinct PatternId from OccurrenceDetailSOCLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
				where exists (select 1 from [PatternStatistic] where PatternId = o.PatternID)
				)
			update PatternStatistic
			set PatternStatistic.TotalOccrncCount = q.TotalCount,
			    PatternStatistic.FirstRunDT = q.FirstRunDT,
				PatternStatistic.LastRunDT = q.LastRunDT
			from q
			where PatternStatistic.PatternID = q.PatternID;

			insert into [PatternStatistic]
			select distinct o.PatternID
			, count(*) over (partition by o.PatternID) TotalCount
			, min(o.AdDT) over (partition by o.PatternID)  FirstRunDT
			, max(o.AdDT) over (partition by o.PatternID)  LastRunDT
			, null TotalSpend
			, first_value(WebsiteID) over (partition by o.PatternID order by AdDT) FirstMediaOutletID
			from OccurrenceDetailSOC o
			inner join  (select distinct PatternId from OccurrenceDetailSOCLog with (NOLOCK) where  LogTimeStamp between @startDate and @endDate) l
						on l.PatternId = o.PatternID
			where not exists (select 1 from [PatternStatistic] where PatternId = o.PatternID);
		end

	   if exists (select 1 from [PatternStatisticProcess] where MediaStream = @MediaStream)
		   begin
			   insert into [PatternStatisticProcess] (MediaStream, LastProcessedDT, CreatedDT)
			   values ( @MediaStream, @startDate, @endDate)
		   end
	   else
		   begin
			  insert into [PatternStatisticProcess] (MediaStream, LastProcessedDT, CreatedDT)
			  values (@MediaStream, '1900-01-01', @endDate)
			end


END
