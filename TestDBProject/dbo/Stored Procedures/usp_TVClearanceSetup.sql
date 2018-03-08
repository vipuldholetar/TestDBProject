
CREATE PROC [dbo].[usp_TVClearanceSetup] 
@startDate datetime = null,
@endDate datetime,
@testMode int = 0

AS 
  BEGIN 
      SET NOCOUNT ON 
      BEGIN TRY 

		/*
		the following parameters will be read from the ClearanceBucket table 
		*/

		declare @nationalShareNeeded float = 1.7
		declare @weightedMatchScoreThreshold int = 8
		declare @instanceShareThreshold float = .6
		declare @offset int = 0, @firstBasisMatch int = 0, @weightedAlignmentScore int = 0
		declare @loosenedAlignmentVarianceSyn  int = 90
		declare @loosenedAlignmentVarianceBroad  int = 90
		declare @loosenedAlignmentVarianceCable  int = 90

		declare @instanceShareThresholdSyn float = .5
		declare @instanceShareThresholdBroad float = .5
		declare @instanceShareThresholdCable float = .5
		declare @localShareThresholdForLocal float = .9
		declare @localShareThresholdForNational float = .1

		declare @alignedDistanceCheck int = 10



		/*
			We store all the occurrences gathered by the Clearance jobs in the temporary table #TempOccs so their attributes (stationID, network, advertiser, programID, ..) can be retrieved or calculated. The values of those attributes will be used for the evaluation of the clearance for each occurrence in the next steps.
			The fields to gather for all Occurrences are:
			#TempOccs 
			Occurrence ID (coming from the Occurrence Detail table)
			Station ID  (coming from the Occurrence Detail table)
			Network  (coming from the master TV station table)
			Air Date (coming from the Occurrence Detail table)
			Air Time (coming from the Occurrence Detail table)
			Matchup ID- This is Pattern ID if Pattern.AdID is NULL; Otherwise it is AdID
			Advertiser - This is Ad.AdvertiserID
			Parent AdID
			Parent Advertiser
			Subcategory  (coming from the master TV program table)
			Ad Length (in seconds)- This is Occurrence.Length if Pattern.AdID is NULL; Otherwise Ad.Length
			Program ID (see 4.1.3)
			Episode ID (see 4.1.3)
			Elapsed Time (see 4.1.3)
			ClearanceBucket (see 4.1.4)
			Decision Priority (see 4.1.6.2)
			Current Clearance Value (see 4.1.10)
			Episode Instance Length (in seconds) (i.e. Episode Instance End DTM – Episode Instance Start DTM)
			ChunkID  (see 4.1.4)
			EpisodeInstance ID  (see 4.1.6.3)
			ClearanceMethod  (see 4.1.6.3)
			NationalClearanceId  (see 4.1.6.3)

		*/
		declare @occs as table(
			[OccurrenceDetailTVID] int
			,[Clearance] varchar(20)
		  ,[ClearanceMethod] char(1)
		  ,[AirDT] date
		  ,[AirTime] datetime
		  ,[AirHour] time
		  ,[TVStationID] int
		  ,[TVNetworkID] int
		  ,[ProgramID] int
		  ,[EpisodeID] varchar(20)
		  ,[ElapsedTime] int
		  ,AdLength int
		  ,[NationalClearanceID] int
		  ,[MatchupID] int
		  ,[AdID] int
		  ,[ParentAdID] int
		  ,AdvertiserID int
		  ,ParentAdvertiserID int
		  ,Subcategory int
		  ,[PatternID] int
		  ,[Valid] bit
		  ,[DecisionPriority] char
		  , ChunkID int
	  		)


		/*
		Each Processable Chunk is defined in a temporary table:
			#Chunk
				Chunk ID
				ClearanceBucket
				Station ID (filled for the Local and Independent buckets only)
				Network  (filled for the Cable buckets only)
				Air Date (aka BroadcastDay)
				Hour
				NumberOfRecordingSchedule  (filled for the Cable buckets only)
				ProgramID
				EpisodeID
				Episode Instance Start DTM (start of the Hour for the cable bucket otherwise we look up the TV schedule table)
				Episode Instance End DTM (end of the Hour for the cable bucket otherwise we look up the TV schedule table)
				Episode Instance Length (in seconds) (i.e. Episode Instance End DTM – Episode Instance Start DTM)
				DecisionProcess (Y/N)
				CriticalMass (Y/N)
		*/
		declare @chunk as table(
		 ChunkID int identity,
		 Clearance varchar(20),
		 StationID int,
		 NetworkID int,
		 AirDT date,
		 AirHour time,
		 NumberOfRecordingSchedule int,
		 ProgramID int,
		 EpisodeID varchar(20),
		 EpisodeStartTime datetime,
		 EpisodeEndTime datetime, 
		 EpisodeLength int,
		 DecisionProcess bit,
		 CriticalMass bit
		)


		/*
			There should be 3 separate groups of TV Clearance jobs that will be gathering ad occurrence records from 3 different date ranges:
			•	Jobs processing the occurrences from the current day: records from 0 to 1 day old.  
			The universe of recent airplays is extremely dynamic as it is impacted by the MT’s pattern recognition process and the MT’s indexing process
			 (that are both posting and updating records in the table OccurrenceDetailTV) but also by the Nielsen ingestion that is providing post-airing 
			 program schedules for most of the TV stations tracked.
			•	Jobs gathering recent occurrences (records from day 2 to day 7).  
			•	Jobs processing older occurrences (records from day 7 to day 90).  The universe of older airplays is less dynamic than the “recent” 
			airplays because it will not be as impacted by the PR and indexing processes and the final TV program schedules will have been ingested. 
			Those older occurrences are mostly records that need reprocessing.


			For all the clearance jobs, a filter is applied to exclude all the occurrence records that are already being processed by other TV Clearance jobs to avoid having different Clearance processes work on the same records: all station-broadcast days actively processed by a Clearance job can be identified as the records from the table TVClearanceProcessLog for which the field EndDTM is still null (the clearance job started at the time BeginDTM and is still active since there is no end time yet).

			To summarize, for each TV Clearance job (per date range and station universe), its universe of Ad occurrences to process is defined by the records (from OccurrenceDetailTV) meeting the 3 following conditions:  
			•	 All the (non-deleted) occurrence records from OccurrenceDetailTV with a valid PatternID (the AdID is not mandatory) that have the field OccurrenceDetailTV.AirDate in the given date range of the job and the field OccurrenceDetailTV.StationId within the given station universe. 
			•	Occurrence records from OccurrenceDetailTV that are not part of a station-broadcast day being actively processed by another Clearance job: the combination station id-broadcast day is not yet in the table TVClearanceProcessLog OR its field TVClearanceProcessLog. EndDTM is not null (meaning that the clearance job that processed the StationID-broadcastDay records has already completed)
			•	Occurrence records from OccurrenceDetailTV that have not yet been processed by the Clearance engine OR records that require reprocessing: the field ClearanceStatus is null.

		*/
		
		INSERT INTO @occs (
		[OccurrenceDetailTVID]
      ,[AirDT]
      ,[AirTime]
	  ,[AirHour]
      ,[TVStationID]
      ,[TVNetworkID]
      ,[AdLength]
      ,[MatchupID]
      ,[AdID]
      ,[PatternID]
	  ,[AdvertiserID] 
	  ,[ParentAdvertiserID]
	  ,[ParentADID]
      )

		SELECT  [OccurrenceDetailTVID]
			  ,[AirDT]
			  ,[AirTime]
			  ,convert(varchar(10), datepart(hour, [AirTime])) + ':00'
			  ,trs.[TVStationID]
			  ,stat.[NetworkID]
			  ,odtv.AdLength
			  , case when ad.[ADID] is null then [PatternID]
					else ad.[ADID] 
				end
			  ,ad.[AdID]
			  ,[PatternID]
			  ,adv.AdvertiserID
			  ,adv.ParentAdvertiserID
			  ,ad.OriginalADID
				FROM [OccurrenceDetailTV] odtv
				INNER JOIN TVRecordingSchedule trs on trs.TVRecordingScheduleID = odtv.TVRecordingScheduleID
				INNER JOIN TVStation stat on stat.TVStationID = trs.TVStationID
				--AD is not required
				LEFT join Ad ad on ad.AdID = odtv.AdID
				LEFT join Advertiser adv on adv.AdvertiserID = ad.AdvertiserID
				WHERE 
				NOT EXISTS(SELECT [OccurrenceDetailTVID] 
				FROM [OccurrenceClearanceTV] octv
				WHERE octv.[OccurrenceDetailTVID] = odtv.[OccurrenceDetailTVID]) 
				and (odtv.AirDT >= @startDate AND odtv.AirDT <= @endDate)
				AND odtv.[PatternID] IS NOT NULL 
				AND ad.[AdID] IS NOT NULL 
				AND [Deleted]=0



		/*
		For each occurrence in our table #TempOccs we retrieve the Program ID and TMSEpisode ID from the table TVProgramSchedule.

		Using the ProgramStartTime we calculate the ElapsedTime (in seconds) as the occurrence’s Air Date Time – Program Air Date Start Time.
		We post the Program ID, TMSEpisode and ElapsedTime to OccurrenceDetailTV and the temp table #TempOccs :

		*/
		update @occs 
		set ProgramID = tps.MtProgramID,
			EpisodeID = tps.TMSEpisodeID,
			ElapsedTime = datediff(second, tt.AirTime, a.AirTime)

		from @occs a 
		INNER JOIN TVProgramSchedule tps on tps.MTStationID = a.TVStationID
		INNER JOIN (SELECT *, convert(varchar(20), ProgAirDT, 101)  + ' ' + 
		convert(datetime, (SUBSTRING(ProgStartTime, 1, 2) + ':' + SUBSTRING(ProgStartTime, 3, 3) + 'M')) airTime from TMSTranslation) tt on tt.ProgEpisodeID = tps.TMSEpisodeID
		WHERE CAST(a.AirDT AS DATE) = CAST(tps.MTAirDT AS DATE)
		--AND (tps.MTAirDT >= @startDate AND tps.MTAirDT <= @endDate)
		AND CAST(tt.ProgAirDT AS DATE) = CAST(tps.MTAirDT AS DATE)
		AND (a.AirTime >= tt.airTime AND a.AirTime <= DATEADD(minute, tt.ProgDuration,tt.airTime))

-----TODO - need to process Nielson Data HERE
			
		/*
			We are assigning each Ad occurrence record stored in the temporary table #TempOccs  (see section 4.1.1), 
			to a Clearance Bucket (Cable, Independent, Local, Syndication, Broadcast Network), and within each 
			of those buckets each Ad occurrence record is assigned to a Processable Chunk.
		*/
		update @occs 
		set Clearance = 
			case net.NetworkShortName
			WHEN 'CAB' then 'Cable'
			WheN 'SYN' then 'Syndicated'
			when 'IND' then 'Independent'
			when 'LOC' then 'Local'
			else 'Broadcast Network'
			end

		from @occs a 
		INNER JOIN TVStation stat on stat.TVStationID = a.TVStationID
		INNER JOIN TVNetwork net on net.TVNetworkID = stat.NetworkID

		/*
		If Program Network (PGCHAN) is Local (LOC)	The Occurrence belongs to the Local Clearance Bucket. In the table #TempOccs we set the field ClearanceBucket to ‘Local’.
		Within that bucket the occurrences do not need to be divided in Processable Chunks: the Clearance will be determined by executing the Comparison Process in section 4.1.8.
		*/
		INSERT INTO @chunk (Clearance, NetworkID, AirHour, AirDT, StationID, DecisionProcess, CriticalMass)
		select min(Clearance), TVNetworkID,  AirHour, min(AirDT), TVStationID, 0, 0
		from @occs
		WHERE Clearance = 'Local'
		Group by TVNetworkID,TVStationID, AirHour

		/*
		If Station’s Network is Independent (IND) OR Station’s Clearance Bucket is IND ??.	The Occurrence belongs to the Independent Clearance Bucket. In the table #TempOccs we set the field ClearanceBucket to ‘Independent’.
		Within that bucket the occurrences do not need to be divided in Processable Chunks: the occurrences are assigned a StationID level clearance based on the station’s market in section 4.1.9.
		*/
		INSERT INTO @chunk (Clearance, NetworkID, AirHour, AirDT, StationID, DecisionProcess, CriticalMass)
		select min(Clearance), TVNetworkID,  AirHour, min(AirDT), TVStationID, 0, 0
		from @occs
		WHERE Clearance = 'Independent'
		Group by TVNetworkID,TVStationID, AirHour

		/*
		If Station’s Network has Market = National Cable.

		The Occurrence belongs to the National Cable Clearance Bucket. In the table #TempOccs we set the field ClearanceBucket to ‘Cable’.
		Within that bucket the occurrences are grouped by Cable Network-Hour to form Processable Chunks.
		*/
		INSERT INTO @chunk (Clearance, NetworkID, StationID, AirHour, AirDT, DecisionProcess, CriticalMass)
		select min(Clearance), TVNetworkID, TVStationID,  AirHour, min(AirDT), 0, 0
		from @occs
		WHERE Clearance = 'Cable'
		Group by TVNetworkID, TVStationID, AirHour


		/*
			Note: When the number of recording schedules is calculated for the evaluation of the critical mass for each given chunk, it is posted to the field #Chunk.NumberOfRecordingSchedule.
	
		*/
		update @chunk
		set NumberOfRecordingSchedule = d.RecordingSchedules
		from 
		@chunk e
		inner join
		(select c.ChunkID,  count(*) RecordingSchedules
		FROM 
		@chunk c
		inner join TVStation a on  a.NetworkID = c.NetworkID and c.StationID = a.TVStationID 
		inner join TVRecordingSchedule b on a.TVStationID = b.TVStationID
		where
		c.AirHour between CAST(b.StartDT as time) and CAST(b.EndDt as time)
		GROUP BY c.ChunkID, a.TVStationID
		) d on d.ChunkID = e.ChunkID

		/*
			If Program Network (PGCHAN) is Syndicated (SYN)	The Occurrence belongs to the Syndicated Clearance Bucket. In the table #TempOccs we set the field ClearanceBucket to ‘Syndicated’.
			Within that bucket the occurrences are grouped by ProgramID-EpisodeID to form Processable Chunks:
 
			Note: For the Syndicated Programming, we are processing Ad occurrences of a broadcast day +-3 days.

		*/
		INSERT INTO @chunk (Clearance, ProgramID, EpisodeID, EpisodeLength, AirDT, DecisionProcess, CriticalMass)
		select min(Clearance),  ProgramID, EpisodeID,  min(ElapsedTime), min(AirDT), 0, 0
		from @occs
		WHERE Clearance = 'Syndicated'
		Group by AirDT, ProgramID, EpisodeID

		/*
		The Occurrence belongs to the Broadcast Network Clearance Bucket. In the table #TempOccs we set the field ClearanceBucket to ‘Broadcast Network’.
		Within that bucket the occurrences are grouped by ProgramID-EpisodeID to form Processable Chunks.
		*/
		INSERT INTO @chunk (Clearance, ProgramID, EpisodeID, AirDT,EpisodeLength, DecisionProcess, CriticalMass)
		select min(Clearance),  ProgramID, EpisodeID,  AirDT,  min(ElapsedTime), 0, 0
		from @occs
		WHERE Clearance = 'Broadcast Network'
		Group by AirDT,  ProgramID, EpisodeID

		/*
		update associated occs records with chunk id
		*/
		update @occs
		set ChunkID = b.ChunkID
		from @occs a
		inner join @chunk b on a.Clearance = b.Clearance and  a.TVNetworkID = b.NetworkID and a.AirHour = b.AirHour 
		where b.Clearance = 'Cable'

		/*
		update associated occs records with chunk id
		*/
		update @occs
		set ChunkID = b.ChunkID
		from @occs a
		inner join @chunk b on a.Clearance = b.Clearance and a.ProgramID = b.ProgramID and a.EpisodeID = b.EpisodeID
		where b.Clearance = 'Syndicated'

		/*
		update associated occs records with chunk id
		*/
		update @occs
		set ChunkID = b.ChunkID
		from @occs a
		inner join @chunk b on a.Clearance = b.Clearance and a.ProgramID = b.ProgramID and a.EpisodeID = b.EpisodeID  and a.AirDT = b.AirDT
		where b.Clearance = 'Broadcast Network'

		/*
		If in the table TVClearance there is at least one record with the value NationalClearanceID > 0 for the given Network-Broadcast Day-Hour combo of the given Processable chunk.
		Then the Decision process has already been run for the given chunk.
		*/
		update @chunk
		set DecisionProcess = 1
		from @chunk a 
		inner join TVNationalClearance b on a.CLearance = b.Clearance and CAST(a.AirDT as DATE) = CAST(b.AirDate as DATE) and a.AirHour = convert(varchar(10), datepart(hour, b.AirTime)) + ':00'
		where a.Clearance = 'Cable' and b.Clearance = 'Cable'

		/*
		If in the table TVClearance there is at least one record with the value NationalClearanceID > 0 for the given ProgramID-EpisodeID combo within +/- 3 days of the given broadcast day of the given Processable chunk.
		Then the Decision process has already been run for the given chunk.
		Note: the condition + / - 3 days applies to Syndication Processable Chunks because only in Syndication can the same episode of a show run on different stations on different dates.
		*/
		update @chunk
		set DecisionProcess = 1
		from @chunk a 
		inner join TVNationalClearance b on a.CLearance = b.Clearance and a.ProgramID = b.ProgramID and a.EpisodeID = b.EpisodeID 
		where a.Clearance = 'Syndicated' and b.Clearance = 'Syndicated'
		and CAST(b.AirDate as DATE) between DateAdd(day, -3, a.AirDT) and DateAdd(day, 3, a.AirDT)

		/*
		If in the table TVClearance there is at least one record with the value NationalClearanceID > 0 for the given ProgramID-EpisodeID-Broadcast day combo of the given Processable chunk.
		Then the Decision process has already been run for the given chunk.
		*/
		update @chunk
		set DecisionProcess = 1
		from @chunk a 
		inner join TVNationalClearance b on a.CLearance = b.Clearance and a.ProgramID = b.ProgramID and a.EpisodeID = b.EpisodeID and CAST(a.AirDT as DATE) = CAST(b.AirDate as DATE)
		where a.Clearance = 'Broadcast Network' and b.Clearance = 'Broadcast Network'


		/*
		when the following is not true we set critical mass = 1
		During the given hour, the given cable network has more than one active recording schedule.
		AND
		-No more than 1 Station ID has 4 or more Occurrences in given Chunk
		AND
		Current Date – Broadcast Day <= 7

		*/
		BEGIN
			update @chunk
			set CriticalMass = 1
			from @chunk a1
			INNER JOIN
			(select a.TVNetworkID,  a.AirHour
			from
			(select b.TVNetworkID, b.TVStationID, b.AirHOur, count(*) stations 
			from @occs b
			inner join @chunk c on c.NetworkID = b.TVNetworkID 
			where b.Clearance = 'Cable'
			group by b.tvNetworkID, b.TVStationID, b.AirHour
			having count(*) > 4) a
			where a.TVNetworkID in (select NetworkID from @chunk group by NetworkID having sum(NumberOfRecordingSchedule) > 1)
			group by   a.TVNetworkID, a.AirHour
			having count(*) > 1) b1
			on a1.NetworkID = b1.TVNetworkID and a1.AirHour = b1.AirHour
		END

		/*
		We only consider occurrences captured on Decision Stations (stations that are present in the table DecisionStations) between the chunk’s broadcast-day -3 days and the chunk’s broadcast-day + 3 days.

		when the following is not true we set critical mass = 1
		-For the programID-EpisodeID, no more than 5 Station IDs have 10 or more Occurrences ( in given Chunk)
		AND
		-Current Date – Broadcast Day <= 4
		OR
		-the Chunk has a record in the table TVClearanceProcessLog with EndDTM = NULL and BeginDTM within last 12 hours.
		*/
		update @chunk
		set CriticalMass = 1
		from @chunk a1
		INNER JOIN
		(select  a.ProgramID, a.EpisodeID, count(*) countOf
		from
		(
		select b.TVStationID,  b.ProgramID, b.EpisodeID, count(*) countOf
		from @occs b
		inner join @chunk c on c.ChunkID = b.ChunkID 
		inner join DecisionStation d on d.TVStationID = b.TVStationID
		where b.Clearance = 'Syndicated'
		group by b.TVStationID, b.ProgramID, b.EpisodeID
		having count(*) > 10
		) a
		group by    a.programid, a.episodeid
		having count(*) > 5) b1
		on a1.ProgramID = b1.ProgramID and a1.EpisodeID = b1.EpisodeID

		/*
		We only consider occurrences captured on Decision Stations (stations that are present in the table DecisionStations).

		when the following is not true we set critical mass = 1
		-For the programID-EpisodeID, no more than 5 Station IDs have 10 or more Occurrences (in given Chunk)
		AND
		-Current Date – Broadcast Day <= 7
		*/
		update @chunk
		set CriticalMass = 1
		from @chunk a1
		INNER JOIN
		(select  a.ProgramID, a.EpisodeID, count(*) countOf
		from
		(
		select b.TVStationID,  b.ProgramID, b.EpisodeID, count(*) countOf
		from @occs b
		inner join @chunk c on c.ChunkID = b.ChunkID 
		inner join DecisionStation d on d.TVStationID = b.TVStationID
		where b.Clearance = 'Broadcast Network'
		group by b.TVStationID, b.ProgramID, b.EpisodeID
		having count(*) > 10
		) a
		group by    a.programid, a.episodeid
		having count(*) > 5) b1
		on a1.ProgramID = b1.ProgramID and a1.EpisodeID = b1.EpisodeID


		/*
		For each Chunk with a critical mass of occurrences (CriticalMass = ‘Yes’), we reduce the number occurrences prior to executing adequately the Decision Process: The Clearance Bucket-specific logic will be applied to the remaining “Decision Occurrences”.
		-For Chunks from the Broadcast Network and Syndication buckets, we only keep occurrences from Decision Stations (stations that are present in the table DecisionStations)
		-For Chunks from the Cable buckets, we only keep occurrences from the 2 Station IDs with the lowest DecisionStations.Priority which have at least 4 Occurrences.

		*/

		update @occs
		set DecisionPriority = 'N'

		update @occs 
		set DecisionPriority = 'Y'
		from @occs a
		inner join @chunk b on a.ChunkID = b.ChunkID and b.CriticalMass = 1

		update @occs
		set DecisionPriority = 'N'
		--delete from @occs
		from @occs a
		inner join 
		(
			select b.TVNetworkID, b.TVStationID, b.AirHOur, count(*) stations 
			from @occs b
			inner join @chunk c on c.NetworkID = b.TVNetworkID 
			where b.Clearance = 'Cable'
			group by b.tvNetworkID, b.TVStationID, b.AirHour
			having count(*) <= 4			
		) b  on  a.TVStationID = b.TVStationID


		declare @episodeInstanceSynBroad as table(
					EpisodeInstanceID int identity,
					ChunkID int ,
					Clearance varchar(20),
					StationID int,
					NetworkID int,
					AirDT date,
					ProgramID int,
					EpisodeID varchar(20),
					EpisodeStartTime datetime,
					EpisodeEndTime datetime, 
					EpisodeLength int,
					ClearancePriority int
				)

		/*
		Each Processable Chunk with a critical mass of occurrences (that needs the Decision Process) from the Cable, Syndication and Broadcast Network Clearance Buckets, is now only composed of “Decision Occurrences”, on which we are going to apply the Clearance Bucket-specific logic to identify:
		-National Occurrences
		-Spot Occurrences
		-Occurrences with Unknown Clearance
		-Suspicious Occurrences (for Analyst review)

		To execute the Decision Process, within each processable chunk we are grouping decision occurrences together to form Episode Instances. The Episode Instances are defined
		-at the Station ID-Broadcast Day-Program ID-Episode ID level in Broadcast and Syndication buckets 
		*/
		insert into @episodeInstanceSynBroad (
			ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				ProgramID ,
				EpisodeID ,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority
				)
		select DISTINCT a.ChunkID ,
				a.Clearance ,
				b.TVStationID,
				a.NetworkID ,
				a.AirDT ,
				a.ProgramID ,
				a.EpisodeID ,
				b.AirTime ,
				DATEADD(minute, b.ElapsedTime, b.AirTime) , 
				(b.ElapsedTime * 60) EpisodeLength ,
				c.ClearancePriority
		from @chunk a
		inner join @occs b on a.chunkID = b.ChunkID
		inner join DecisionStation c on c.TVStationID = b.TVStationID
		WHERE a.Clearance in ('Syndicated', 'Broadcast Network')
		and a.DecisionProcess = 0

		declare @episodeInstanceCable as table(
				EpisodeInstanceID int identity,
				ChunkID int ,
				Clearance varchar(20),
				StationID int,
				NetworkID int,
				AirDT date,
				AirHour time,
				EpisodeStartTime datetime,
				EpisodeEndTime datetime, 
				EpisodeLength float,
				ClearancePriority int
			)

		/*
		Each Processable Chunk with a critical mass of occurrences (that needs the Decision Process) from the Cable, Syndication and Broadcast Network Clearance Buckets, is now only composed of “Decision Occurrences”, on which we are going to apply the Clearance Bucket-specific logic to identify:
		-National Occurrences
		-Spot Occurrences
		-Occurrences with Unknown Clearance
		-Suspicious Occurrences (for Analyst review)

		To execute the Decision Process, within each processable chunk we are grouping decision occurrences together to form Episode Instances. The Episode Instances are defined
		-at the Station ID-Hour level in Cable buckets

		*/
		insert into @episodeInstanceCable (
			ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				AirHour,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority
				)
		select DISTINCT a.ChunkID ,
				a.Clearance ,
				b.TVStationID,
				a.NetworkID ,
				a.AirDT ,
				a.AirHour,
				a.AirHour EpisodeStartTime ,
				DATEADD(hour, 1, a.AirHour)  EpisodeEndTime , 
				1 EpisodeLength ,
				--(b.ElapsedTime/60.0) EpisodeLength ,
				c.ClearancePriority
		from @chunk a
		inner join @occs b on a.chunkID = b.ChunkID
		inner join DecisionStation c on c.TVStationID = b.TVStationID
		WHERE a.Clearance in ('Cable')
		and a.DecisionProcess = 0

		declare @nationalTemplate table(
			ElapsedTime time,
			TVNationalOccurrenceID int,
			NetworkID int,
			ClearanceCount int
		)


		/*

		MACTH PROCESS DOCUMENTAION
					In the section 4.1.6.3 we mentioned calls to the Clearance Comparison procedure to
		- compare two Episode Instances against each other, to produce a National Template (decision mode)
		- compare two Episode Instances against the National Template to identify national occurrences (comparison mode)

		The Clearance Comparison procedure has the following input parameters:
		-A list of Occurrences we want to evaluate against a basis array: the Comparison Array (CA)
		-A list of “National” Occurrences that we are using as a reference: the Basis Array (BA) 
		-A parameter indicating from which Clearance Bucket the Episode Instances are issued
		-A flag indicating whether to run the procedure in Decision Mode or Comparison Mode
		-A flag indicating whether a National Template has already been established 

		The Clearance Comparison procedure will align the 2 input Arrays to derive a Weighted Match Score for all matches between the 2 arrays and produce a Match Array as an output.

		ClearanceComparison (Comparison Array; Basis Array; Clearance bucket; Mode; National template flag)
		Output: Match Array

		MatchArray
		CA.OccurrenceID
		CA.MatchupID
		CA. Occurrence.ElapsedTime
		CA.Occurrence.Clearance
		CA.Occurrence.ClearanceMethod
		CA. Occurrence.Ad length
		Offset (between CA& BA records)
		BA.OccurrenceID
		Weighted Match Score

		The business logic to produce the output Match Array is the following:

		a -Load the clearance bucket-specific parameters from the table ClearanceBucketParameter and set the parameter values  offset, FirstBasisMatch  and weighted alignment score to 0. 

		b-We align the Comparison Array to Basis Array as follows:

		i) We loop through all the occurrences in the Basis array (ordered by ElapsedTime ascending) and for each occurrence (row L) BA[L] we are looking through all the records of the Comparison array to find an occurrence CA[X] with the same MatchupID:
		ii) We loop through all the occurrences in the Comparison array (ordered by ElapsedTime ascending) and for each occurrence (row X) we are checking if BA[L]. MatchupID= CA[X]. MatchupID

		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.

		We are now going to check if the following occurrences from both arrays are also “matching”:
		We have BA[L]. MatchupID  = CA[X]. MatchupID, and for i=1 to N (X+N being the last item in the Basis Array) we are checking if the weighted alignment score between BA[L+i]and CA[X+i] is satisfactory:

		IF  [ BA[L+i]. MatchupID  = CA[X+i]. MatchupID  OR BA[L+i]. ParentID  = CA[X+i]. ParentID  
		OR  BA[L+i]. Adviser  = CA[X+i]. Adviser  AND BA[L+i]. Subcategory  = CA[X+i]. Subcategory  ]
		AND
		[(BA[L+i]. ElapsedTime  -  BA[L]. ElapsedTime ) - (CA[X+i]. ElapsedTime  -  CA[X]. ElapsedTime)> Offset Margin of Error]
		THEN we calculate the weighted alignment score between BA[L+i]and CA[X+i]:
		We first evaluate the Match Score between BA[L+i]and CA[X+i] (see Appendix 15.3 Match Score) and set Weighted Match Score[i] = Weighted Match Score[i-1] + Match Score(L+i,X+i)4  x X+i.Ad.Length (seconds)30 
		Note: the Offset Margin of Error is stored in the table ClearanceBucketParameter.

		IF the Weighted Match Score[i]  is NOT > Weighted Alignment Threshold:
		THEN we establish that we do not have enough matches in a row, and we start over the loop: we reset the offset, the FirstBasisMatch and the weighted alignment score to 0, and go back to step i) with L=L+i.
		ELSE we have enough matches in row: 
		We set  offset  = L.Elapsed Time - X.ElapsedTime
			FirstBasisMatch = L
			FirstComparisonMatch  = X
		and we go to the next step:

		iii) If the value ABS(offset )  > 60 seconds, we  fetch additional occurrences before producing the Match array, since a potentially significant portion of what we want to compare is missing due to the substantial misalignment:

		IF offset   >60
		THEN we Fetch all Occurrences (within the clearance bucket)with the same stationID as the  Comparison array current item’s station ID (CA[X].StationID )with an Air Date Time between the AirDateTime of the first occurrence of the Comparison Array CA[0] and that CA[0].AirDateTime - Offset

		IF offset   < 60
		THEN we Fetch all Occurrences (within the clearance bucket)with the same stationID as the  Comparison array current item’s station ID (CA[X].StationID )with an Air Date Time between the AirDateTime of the last occurrence of the Comparison Array and that AirDateTime – Offset

		We add any occurrences that we might have fetched above to the Comparison Array (and we sort the Comparison Array occurrences by ascending ElapsedTime) and we change the current Basis Array index from L to L + count of the fetched occurrences if the offset > 60

		iv) In the case where the NationalTemplate flag =’No’, if the StationId.ClearancePriority of the Comparison Array is >StationId.ClearancePriority of the Basis Array, then to make sure that the National Template is built from the higher-ranking stations (in terms of DecisionStations.ClearancePriority), we invert the 2 arrays: we switch the Basis Array and Comparison Array; we also switch the index values X and L for each array and we set the value Offset = Offset x (-1).

		v) Before we insert the ‘matches’ found between the Comparison array and Basis array in the Match Array, we are trying to identify additional matches among ‘earlier’ occurrences, as we loop through occurrences from the Comparison array starting at item X:
			For each occurrence (row Y = X and continuing back through beginning of Comparison array if needed) of the Comparison array we are comparing with items from the Basis array starting at row M=L and continuing back through beginning of Basis array if needed:
		For each occurrence (row M) of the Basis array:
		IF for the occurrences CA[Y]and BA[M] we have:
		(Same MatchupID) OR (Same ParentAdID) OR (Same Advertiser AND Subcategory) OR (Same Parent Advertiser)
		AND 
		ABS(Y.ElapsedTime + Offset - M.ElapsedTime) < Loosened Alignment Variance
		AND (Matchup Score = 4 OR Aligned Distance < Alignment Variance)
		THEN a match is found:
		-we log the occurrences records CA[Y]and BA[M] in the Match array:
		We insert Y.OccurrenceID, Y.ElapsedTime, Y.Clearance, Y.Ad.Length, Offset,M.OccurrenceID, and the Weighted Match Score between CA[Y]and BA[M] in the Match Array.
					-we set Total Weighted Match Score = Total Weighted Match Score + Weighted Match Score
						And IF Total Weighted Match Score >= Loosened Alignment Variance
								THEN we set Alignment Variance= Loosened Alignment Variance
		(This loosening is often needed for Syndicated programming during which Stations have modest leeway in choosing where to insert their own locally sold ads)
		ELSE  no match is found, but
					IF the Basis Array contains a row N for which 
				ABS(Y.ElapsedTime + Offset - N.Elapsed Time) < Offset Margin of Error
				THEN we log the occurrences records CA[Y]and BA[N] in the Match array as a ‘Mismatch’: 
		We insert Y.OccurrenceID, Y.ElapsedTime, Y.Clearance, Y.Ad.Length, Offset,N.OccurrenceID and the Match Score = -1 (i.e. Mismatch) in the Match Array.
				ELSE we log the occurrences records CA[Y]and BA[N] in the Match array as a ‘No Match’: 
		We insert Y.OccurrenceID, Y.ElapsedTime, Y.Clearance, Y.Ad.Length, Offset,N.OccurrenceID and the Match Score = 0 (i.e. No Match) in the Match Array.
     
		We loop with the next occurrence M of the Basis array and the same occurrence Y of the Comparison array until M is the last occurrence of the Basis array.

		Note: the Loosened Alignment Variance  and Offset Margin of Error are stored in the table ClearanceBucketParameter and the Match Score calculation is described in Appendix 15.3.

		vi) We go back to step v) and loop again with the next occurrence Y in the Comparison array until Y is the last occurrence of the Comparison array.

		vii) Once we are done identifying the matches between the Comparison array and Basis array, we need to evaluate if we have found enough matches (records with the Match Score > 0 in the Match Array):
		IF (Weighted Match Score) x (Episode Instance Length in seconds1800 )< Weighted Match Score Threshold
		THEN we exit the procedure because not enough matches were identified for reliable conclusions.
		ELSE we are going to send our Match array to the Local Checker procedure to perform additional checks on the ‘local’ occurrences:
			IF the Clearance bucket is not ‘local’
			THEN we call the Local Checker procedure to assess whether any occurrences identified as ‘local’ in the Match Array (Match Score = 0) align sufficiently with a critical mass of occurrences in other Episode Instances to warrant the addition of a new National Buy or the update to an existing one (adding or updating National template records).
			To do so we pass in as an input parameter our Match Array to the Local Checker procedure that will return an output Match Array that may or may not be altered from the original input.

		Note: the Episode Instance Length is retrieved from the field #EpisodeInstance. EpisodeInstanceLength of the Episode Instance the occurrences belong to; the Weighted Match Score Threshold is a parameter stored in the table ClearanceBucketParameter.

		viii) The Match array (the output from the Local Checker procedure) is returned to the caller procedure.

		15.2 Clearance Method Values
		Listed below are all the possible values for the field Clearance Method.

		IF the Clearance is determined through	Set
		Comparison Mode	Clearance Method = ‘C’
		Matchup ID’s History	Clearance Method = ‘H’
		Local Avail Logic	Clearance Method = ‘A’
		National Occurrence identified in Local Checker	Clearance Method = ‘N’
		Independent	Clearance Method = ‘I’

		15.3 Match Score
		Listed below is the logic to calculate the Match Score between 2 Ad occurrences A and B:  

		If Occurrence A and Occurrence B have the same 
		Matchup ID OR 
		Parent Ad ID OR 
		Advertiser & Subcategory OR 
		Parent Advertiser 
		The Match Score is > 0 :

		IF for Occurrence A and Occurrence B	Set
		A.Matchup ID = B.Matchup ID	Match Score = 4
		A. Parent AD ID = B. Parent AD ID	Match Score = 3
		A. Advertiser = B. Advertiser	Match Score = 2
		A.Parent Advertiser = B. Parent Advertiser AND
		A.Subcategoty= B. Subcategoty	Match Score = 1
		Else	Match Score = 0

		Then to calculate the Weighted Match Score:
		WMS = MATCH SCORE4   X  AD.LENGTH IN SECONDS30 
		*/
		declare @matchArray table(
			OccurrenceID int,
			MatchupID int,
			ElapsedTime float,
			Clearance varchar(20),
			ClearanceMethod char(1),
			AdLength int,
			Offset int,
			BaOccurrence int,
			WeightedMatchScore float
		)

		/*
		Within each Processable Chunk we sort all the Episodes Instances by Clearance Priority (retrieved from the DecisionStations table), and we set the Episode Instance with the lowest ClearancePriority as the Basis array BA. 

		iii) We loop through all remaining episode instances within a given chunk to use them as the Comparison array (CA) to call the Clearance Comparison procedure.
		-If a National Template array already exists (and is not null), we use it as the  basis array BA (instead of the Episode Instance with the lowest Clearance Priority) and we set the National Template flag to ‘yes’:
		call ClearanceComparison (CA; BA; Clearance bucket; ‘Decision mode’; National template flag)
				See Appendix 15.1  for the details of the Clearance Comparison procedure.

		*/
		drop table #ba
		;WITH cteBA AS
		(
			SELECT *,
					ROW_NUMBER() OVER (PARTITION BY ProgramID, EpisodeID ORDER BY ClearancePriority DESC) AS top1
			FROM @episodeInstanceSynBroad 
		)
		select *, cast(null as time) AirHour into #ba
		FROM cteBA
		WHERE top1 = 1
			
		/*
		Within each Processable Chunk we sort all the Episodes Instances by Clearance Priority (retrieved from the DecisionStations table), and we set the Episode Instance with the lowest ClearancePriority as the Basis array BA. 

		iii) We loop through all remaining episode instances within a given chunk to use them as the Comparison array (CA) to call the Clearance Comparison procedure.
		-If a National Template array already exists (and is not null), we use it as the  basis array BA (instead of the Episode Instance with the lowest Clearance Priority) and we set the National Template flag to ‘yes’:
		call ClearanceComparison (CA; BA; Clearance bucket; ‘Decision mode’; National template flag)
				See Appendix 15.1  for the details of the Clearance Comparison procedure.
		*/
		drop table #baCable
		;WITH cteBA AS
		(
			SELECT *,
					ROW_NUMBER() OVER (PARTITION BY AirHour ORDER BY ClearancePriority DESC) AS top1
			FROM @episodeInstanceCable 
		)
		select * into #baCable
		FROM cteBA
		WHERE top1 = 1
			
			
		/*
		create basis array
		*/
		insert into #ba (ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				AirHour,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority)

		select ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				AirHour,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority
		from #baCable


		/*
		variables used in match process
		TODO -- we need to pull these from a RefClearanceBucket table
		*/

		drop table #ca

		/*
		create a place holder column to hold hour for cable entries
		*/
		select *, cast(null as time) AirHour 
		into #ca 
		from @episodeInstanceSynBroad a 
		where
		a.EpisodeInstanceID not in (select EpisodeInstanceID from #ba)

		/*
		create comparison array
		*/
		insert  into #ca(
		ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				AirHour,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority)
		select ChunkID ,
				Clearance ,
				StationID,
				NetworkID ,
				AirDT ,
				AirHour,
				EpisodeStartTime ,
				EpisodeEndTime , 
				EpisodeLength ,
				ClearancePriority from @episodeInstanceCable a where
		a.EpisodeInstanceID not in (select EpisodeInstanceID from #ba)

		/*
		create match score column and full basis array
		*/
		drop table #baAll
		select  0 as MatchScore, b.EpisodeInstanceID, a.* into #baAll from @occs a
		inner join #ba b on b.ChunkID = a.ChunkID and a.TVStationID = b.StationID

		/*
		create comparison array with episode instances
		*/
		drop table #caAllTemp
		select  b.EpisodeInstanceID, a.* into #caAllTemp from @occs a
		inner join #ca b on b.ChunkID = a.ChunkID and a.TVStationID = b.StationID
		/*
		create full comparison array with weighted match and match score column place holders
		*/
		drop table #caAll
		select DISTINCT cast(0 as float) as WeightedMatchScore,  0 as MatchScore,b.OccurrenceDetailTVID as BaOccurrence, b.ElapsedTime as BaElapsedTime, 0 as Offset,   a.* into #caAll 
		from #caAllTemp a
		inner join #baAll b on b.ChunkID = a.ChunkID 
		
		--select * from tvstation
		--select * from #baall
		--select * from TVProgramSchedule
		--select * from tvrecordingschedule
		--select * from OccurrenceDetailTV where tvsta
		--select * from @occs where TVStationID in (772)
		--select * from @chunk
		--select * from #caAllTemp
		

		/*
		A.Matchup ID = B.Matchup ID	Match Score = 4
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAll 
		set MatchScore = 4
		,WeightedMatchScore = (4/4.0) * (a.AdLength/30.0)
		,BaOccurrence = b.OccurrenceDetailTVID
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		--select a.* fro
		from #caAll a
		inner join #baAll b on a.ChunkID = b.ChunkID and a.MatchupID = b.MatchupID
		where a.MatchupID is not null and b.MatchupID is not null

		/*
		A. Parent AD ID = B. Parent AD ID	Match Score = 3
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAll 
		set MatchScore = 3
		,WeightedMatchScore = ((3/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.OccurrenceDetailTVID
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAll a
		inner join #baAll b on a.ChunkID = b.ChunkID and a.ParentAdID = b.ParentAdID
		where a.MatchScore = 0 and
		(a.ParentAdID is not null and b.ParentAdID is not null)

		/*
		A. Advertiser = B. Advertiser	Match Score = 2
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAll 
		set MatchScore = 2
		,WeightedMatchScore = ((2/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.OccurrenceDetailTVID
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAll a
		inner join #baAll b on a.ChunkID = b.ChunkID and a.AdvertiserID = b.AdvertiserID
		where a.MatchScore = 0 and
		(a.AdvertiserID is not null and b.AdvertiserID is not null)

		/*
		A.Parent Advertiser = B. Parent Advertiser AND
		A.Subcategoty= B. Subcategoty	Match Score = 1
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAll 
		set MatchScore = 1
		,WeightedMatchScore = ((1/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.OccurrenceDetailTVID
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAll a
		inner join #baAll b on a.ChunkID = b.ChunkID and a.ParentAdvertiserID = b.ParentAdvertiserID
		where a.MatchScore = 0 and
		(a.ParentAdvertiserID is not null and b.ParentAdvertiserID is not null)

		--select * from #caall

		/*
		The business logic to produce the output Match Array is the following:

		a -Load the clearance bucket-specific parameters from the table ClearanceBucketParameter and set the parameter values  offset, FirstBasisMatch  and weighted alignment score to 0. 

		b-We align the Comparison Array to Basis Array as follows:

		i) We loop through all the occurrences in the Basis array (ordered by ElapsedTime ascending) and for each occurrence (row L) BA[L] we are looking through all the records of the Comparison array to find an occurrence CA[X] with the same MatchupID:
		ii) We loop through all the occurrences in the Comparison array (ordered by ElapsedTime ascending) and for each occurrence (row X) we are checking if BA[L]. MatchupID= CA[X]. MatchupID

		*/
		insert into @matchArray(
						OccurrenceID ,
						MatchupID ,
						ElapsedTime ,
						Clearance ,
						ClearanceMethod,
						AdLength ,
						Offset ,
						BaOccurrence ,
						WeightedMatchScore)
		select distinct a.OccurrenceDetailTVID
			,a.MatchupID
			,a.ElapsedTime
			,a.Clearance
			,'C'
			,a.AdLength
			,a.Offset
			,a.BaOccurrence
			,a.MatchScore
		from 
		#caAll a
		where  a.MatchScore > 0 

		--select * from #caAll

		drop table #localCheck
		select DISTINCT cast(.0 as float) as KnownLocalShare, a.* 
		into #localCheck 
		from #caAll  a
		inner join @chunk b on a.ChunkID = b.ChunkID
		where a.Clearance = 'Cable'
		and b.NumberOfRecordingSchedule = 1
		and a.MatchScore = 0


		--select * from #localCheck 
		--a
		--inner join @chunk b on a.ChunkID = b.ChunkID
		--where a.Clearance = 'Cable'
		--and b.NumberOfRecordingSchedule = 1

		--!!REMOVE THIS LINE IT IS FOR TESTING
		truncate table TVNationalOccurrence

		/*
		Once the Episode Instances have been formed, within a given processable chunk, the Decision Process will consist in 3 steps:
		•	We compare two Episode Instances against each other, to first produce a National Template (through the Clearance Comparison procedure in decision mode).

		•	We then compare the Episode Instances against the National Template (through the Clearance Comparison procedure in comparison mode) to identify the national occurrences. 
		*/
		insert into TVNationalOccurrence(
		NationalID, StationNetworkID, AirDate, AirTime, ProgramID, EpisodeID, MatchupID)
		select DISTINCT a.BaOccurrence, b.TVNetworkID, b.AirDT, b.AirTime, b.ProgramID, b.EpisodeID, a.MatchupID
		from @matchArray a
		inner join @occs b on a.BaOccurrence = b.OccurrenceDetailTVID

		/*
			the output of the procedure is a Match array that contains the Weighted Match Score of each record of the Episode Instance against the National Template records. 
			For each occurrence of the Comparison array that is present in the Match array with a Matchup Score > 0 we mark the clearance as ‘national ‘, the NationalClearanceID  is set to the BA.OccurrenceID and the ClearanceMethod is updated to ‘C’  for Comparison Mode (see Appendix 15.2 Clearance Method Values) in the table #TempOccs.
		*/
		update @occs
		set NationalClearanceID = b.BaOccurrence
		,Clearance = 'National'
		, ClearanceMethod = 'C'
		from @occs a
		inner join @matchArray b on a.OccurrenceDetailTVID = b.OccurrenceID

		INSERT INTO [dbo].[TVNationalClearance]
				   ([Clearance]
				   ,[ClearanceMethod]
				   ,[AirDate]
				   ,[AirTime]
				   ,[ProgramID]
				   ,[EpisodeID]
				   ,[MatchupID]
				   ,[ElapsedTime])
		select DISTINCT Clearance
				, ClearanceMethod
				, AirDT
				, AirTime
				, ProgramID
				, EpisodeID
				, MatchupID
				, ElapsedTime
		from #caAll
		where (WeightedMatchScore * AdLength) > @weightedMatchScoreThreshold

		/*
			c) Local Checker procedure 

			The purpose of the Local Checker procedure is to assess whether any Local airings in the Match Array (Matchup Score = 0) that were not identified as ‘national’ by the Clearance Comparison procedure are actually a part of a not-yet-identified National Buy.
			Most calls to the Local Checker procedure are made directly from the Clearance Comparison procedure.
			The input parameters are the Comparison Array;the Clearance Bucket;the  Match Array and the Cable Single Feed flag:
			ClearanceComparison (Comparison Array; Clearance bucket;Match Array;  Cable-Single Feed flag)
			The output of the procedure is a Match Array (same structure as the input array) whose values may or may not be altered from the original input Match Array.

			The Local Checker procedure should apply the following business logic:

			Cable bucket logic
			We first check if the occurrences are coming from the “Cable” Clearance bucket, because some business rules are specific to Cable occurrences, especially if there was only 1 feed for a given Cable station: for single-feed stations we attempt to identify as many National and Local airings as we can despite the absence of any other feed to compare against based on each Matchup ID's National/Local history:

			i) IF the Clearance bucket =’Cable’ AND NumberOfRecordingSchedule =1
			THEN for each distinct occurrence/MatchupID of the Comparison array with a local clearance (ie each occurrence with the Matchup Score = 0 in the Match array), we calculate the Known Local Share to evaluate its clearance:

			count(All records with same MatchupID AND ClearanceMethod <> H and Clearance = Local)
			/( Count(All Records with  same MatchupID AND ClearanceMethod <> H and Clearance = Local) + count(Distinct National Clearance IDs with same MatchupID and ClearanceMethod <> H))

			IF the Known Local Share is > Local Share Threshold for Local
			THEN we set the Clearance to ‘local’ and the ClearanceMethod to ‘H’ (Matchup ID’s History)
			ELSE 
				 IF   Known Local Share > 0 AND Known Local Share  <  Local Share Threshold for National
				 THEN we set the Clearance to ‘local’ and the ClearanceMethod to ‘H’ 

			The values Clearance and ClearanceMethod are updated in the Match Array that will be returned; both values Local Share Threshold for Local and Local Share Threshold for National are defined in the table ClearanceBucketParameter:

			ClearanceBucketParameter
			ParameterID  4266
			BucketType   Cable
			Decision        MatchupHistory
			Parameter     Local Share Threshold for Local
			Value            0.9
				ClearanceBucketParameter
			ParameterID  4887
			BucketType   Cable 
			Decision        MatchupHistory
			Parameter    Local Share Threshold for National
			Value            0.1


			The next step is to apply another set of business rules specific to the Cable bucket to assess whether or not some additional actions are needed toward the non-national airings (Matchup Score = 0 in the Match array passed in as a parameter to the Local Checker procedure): each Cable Network Hour must contains no more than 2-3 minutes of Local occurrences, no block of local Ad occurrences must be too long and there must not be too many blocks of local Ad occurrences:

			ii) we assess whether the non-national occurrences in the Match array meet the 3 Local Avail Criteria:
			-the total length in seconds of all the local Ads (per hour) is <=180
			-the number of blocks is <=3 (note:  a non-discontinued list of local Ad occurrences constitutes a block)
			-each block of local Ads is <= 120 seconds in length

			If all 3 Local Avail Criteria are not met, we are going to remove some local occurrences and classify them as ‘national’. In order to comply with the 3 conditions we execute the following logic:

			If any block is too long
			 IF for any block of local Ads the length is > 120 seconds 
			THEN - we calculate the Known Local Share (see above in i)) for the first and last matchupID of the block
			- for the occurrence with the lowest non-zero Known Local Share AND the Matchup Score = 0 we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic)
			-in case of a tie we do nothing, otherwise we go back to step ii)

			If too many blocks
			 IF the number of local blocks is > 3 
			THEN - we calculate the Known Local Share (see above in i)) for each matchupID in each local block
					   -We keep the 3 local blocks with the highest minimum Known Local Share as ‘local’
					For all other Local blocks we change the Clearance to ‘national’ and the ClearanceMethod to ‘A’       for all the occurrences within those blocks.  
			-In case of a tie for 3rd we keep the extra blocks.
			-If any change was made we go back to step ii)


			If total seconds is too high
			 IF the total length of all Local Ads(for that 1 hour)  is > 180 seconds 
			THEN - we calculate the Known Local Share (see above in i)) for each Local matchupID in the Match array
			- for the occurrence with the lowest non-zero Known Local Share  we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic) in the Match array.
			-in case of the tie we do nothing, otherwise we go back to step ii)

			If all 3 Local Avail Criteria are still unmet, we log into the table TVClearanceExceptionLog the reason:

*/ 


				/*
				All Clearance buckets logic
				The next operations apply to occurrences from all Clearance buckets:
				If any Comparison Array occurrence with a ‘local’ Clearance (Matchup Score = 0 in the Match array) has a MatchupID which appears during enough Episode Instances then we can create a new National occurrence: either we replace (by adding one record and removing one) or we add a record in the existing National template.

				We loop through all the ‘local’ occurrences in the Comparison array to check if any new “national occurrence” should be added to the National template:
				For each ‘local’ occurrence CA[i] from the Comparison array we do:
				** Begin
				i) We fetch all occurrences from our temp table #TempOccs  within the same Processable Chunk (identified through ChunkID) from Decision Stations (station IDs in the table DecisionStations) having: 
				a Match Score (see Appendix 15.3 for the formula) with the given occurrence CA[i]  > 0 
				AND ABS(ElapsedTime + Offset - CA[i] 's ElapsedTime + Offset) < Aligned Distance Check 

				ii) IF count of the occurrences fetched above count of distinct Decision StationIDs for the given Processable Chunk < Instance Share Threshold
				THEN we insert the given occurrence CA[i] of the Comparison array in the National template and we update the Clearance (to ‘national’) and the ClearanceMethod (to ‘A’) of the occurrence CA[i] in the output Match array.
				Note: When we insert the occurrence’s attributes in the National template, we replace the occurrence’s StationID by the occurrence’s Network.

				** End

				The Aligned Distance Check also called Loosened Alignment Variance and the Instance Share Threshold are bucket specific, and are stored in the table ClearanceBucketParameter.

 

				If any record was added to National template we determine whether any pre-existing record in the National Template should be deleted as a result of the above addition(s):

				#NationalTemplate
				ElapsedTime
				National ID
				Network  
				ClearanceCount
					NationalOccurrence
				National ID
				MatchUpID
				Station ID/Network 
				AirDate
				AirTime
				ProgramID
				EpisodeID
					#TempOccs 
				Occurrence ID
				Station ID
				Network
				Air Date
				Air Time
				Matchup ID 
				National ClearanceID


				For each occurrence in the National template that does not exist in the Comparison Array (that means all the National template records for which the value NationalTemplate[i].NationalID is not among the list [ select all NationalClearanceID from #TempOccs  where Occurrence ID in the  Comparison Array] ), we go through the loop: 

				*Begin
				-For the given occurrence’s MatchupID (NationalTemplate. MatchUpID), we fetch all the occurrences within the processable chunk (same ChunkID) linked to the current Comparison Array (OccurrenceID
				 Is in the array) that have a Match Score > 2 (see Appendix 15.3 for the Match Score calculation).
				-Count the distinct Decision Station IDs   of the occurrence gathered above.
				- IF  Count the distinct Decision Station IDs   of the occurrence gathered above Count of the distinct Decision Station IDs for the given processable chunk   > National Share Needed 
				THEN we keep the occurrence in the National Template 
				ELSE we delete occurrence from the National Template (This scenario happens when an occurrence that was un-indexed (MatchupId=PatternID) is indexed (MatchupId=AdID) .
				*End

				Note: the National Share Needed is stored in the table ClearanceBucketParameter.


				iii) The Match array is returned to the caller procedure, and any update (clearance or clearance method) is reflected to the occurrences in the table #TempOccs.

				Note: whenever we update the Clearance to ‘national’ in the output Match array, we also ‘artificially’ update the Match Score from 0 to 1, so the occurrences will not be identified as ‘local’ by the caller procedure (which is usually the case when a Match Score = 0 ).
				*/

		--select distinct * from #localCheck

		update @occs 
		set Clearance = 'Local' 
		, ClearanceMethod = 'H'
		from @occs g
		inner join
		(select DISTINCT ( cast(f.totalLocal as float) / (f.totalLocal + f.totalNational) ) KnownLocalShare,  f.BaOccurrence from 
		(
			select distinct c.totalLocal, ISNULL( e.totalNational, 0) totalNational, d.* from #localCheck d
			inner join (
			select distinct a.MatchupID, count(*) totalLocal from @occs a
			where a.Clearance = 'Local' group by a.MatchupID) c on c.MatchupID = d.MatchupID
			left join (
			select distinct a.NationalClearanceID, a.MatchupID, count(*) totalNational from @occs a
						group by a.NationalClearanceID, a.MatchupID) e on e.MatchupID = d.MatchupID
		) f ) h on h.BaOccurrence = g.OccurrenceDetailTVID
		where h.KnownLocalShare > @localShareThresholdForLocal
		or (h.KnownLocalShare > 0 and h.KnownLocalShare < @localShareThresholdForNational)

		--DEBUG
		if (@testMode = 1)
		BEGIN

			/*

			If any block is too long
				IF for any block of local Ads the length is > 120 seconds 
			THEN - we calculate the Known Local Share (see above in i)) for the first and last matchupID of the block
			- for the occurrence with the lowest non-zero Known Local Share AND the Matchup Score = 0 we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic)
			-in case of a tie we do nothing, otherwise we go back to step ii)

			If too many blocks
				IF the number of local blocks is > 3 
			THEN - we calculate the Known Local Share (see above in i)) for each matchupID in each local block
						-We keep the 3 local blocks with the highest minimum Known Local Share as ‘local’
					For all other Local blocks we change the Clearance to ‘national’ and the ClearanceMethod to ‘A’       for all the occurrences within those blocks.  
			-In case of a tie for 3rd we keep the extra blocks.
			-If any change was made we go back to step ii)


			If total seconds is too high
				IF the total length of all Local Ads(for that 1 hour)  is > 180 seconds 
			THEN - we calculate the Known Local Share (see above in i)) for each Local matchupID in the Match array
			- for the occurrence with the lowest non-zero Known Local Share  we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic) in the Match array.
			-in case of the tie we do nothing, otherwise we go back to step ii)

			If all 3 Local Avail Criteria are still unmet, we log into the table TVClearanceExceptionLog the reason:
			*/
			declare @minID int

			set @minID = (select min(OccurrenceDetailTVID) from @occs)

			--select a.AdID from @occs a
			--inner join Ad b on a.AdID = b.AdID
			--where adName = 'No Match'
			update @occs
			set NationalClearanceID = @minID
			from @occs a
			where a.AdID in (select distinct AdID from Ad
			where adName = 'No Match')
		END

			--select * from @occs

			--select DISTINCT ( cast(f.totalLocal as float) / (f.totalLocal + f.totalNational) ) KnownLocalShare,  f.BaOccurrence from 
			--		(
			--			select c.totalLocal, ISNULL( e.totalNational, 0) totalNational, d.* from #localCheck d
			--			inner join (
			--			select distinct a.MatchupID, count(*) totalLocal from @occs a
			--			where a.Clearance = 'Local' group by a.MatchupID) c on c.MatchupID = d.MatchupID
			--			left join (
			--			select distinct a.NationalClearanceID, a.MatchupID, count(*) totalNational from @occs a
			--			group by a.NationalClearanceID, a.MatchupID) e on e.MatchupID = d.MatchupID
			--		) f 

			declare @minBlockID int 
			set @minBlockID = (select min(baOccurrence) from #localCheck)
			drop table #cableBlockCheck
			;WITH cteCable AS
			(
				SELECT *,
						ROW_NUMBER() OVER (PARTITION BY BaOccurrence ORDER BY AirHour DESC) AS top1
				FROM #localCheck 
			)
			select * into #cableBlockCheck
			FROM cteCable
			WHERE BaOccurrence = @minBlockID

			/*
			the following test block is used in to help verify auto testing - we are deliberately setting intermediate values to create
			test scenarios referenced in the TV Clearance SRD
			*/
			if @testMode = 1
			begin
					--select * from #localcheck
					/*
					The length a block of local Ads is defined by the ElapsedTime of the last occurrence of the ‘local’ block - 
					ElapsedTime of the first occurrence of the ‘local’ block + Ad length of the last occurrence of the ‘local’ block
					*/
					update #localCheck
					set AirTime = '08:45',
					AirHour = '08:0',
					AdLength = 60
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 1
			
					update #localCheck
					set AirTime = '08:46',
					AirHour = '08:00',
					AdLength = 60
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 2
			
					update #localCheck
					set AirTime = '08:50',
					AirHour = '08:00',
					AdLength = 61
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 3

					update #localCheck
					set AirTime = '08:51',
					AirHour = '08:00',
					AdLength = 61
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 4

					--select * from #localcheck

					--update @occs 
					--set Clearance = 'Local' 
					--from @occs g
					--inner join
			
					drop table #totalSecsTooHigh
					--IF the total length of all Local Ads(for that 1 hour)  is > 180 seconds 
					select l.* into #totalSecsTooHigh from
					(select adid, airdt, airhour, sum(adlength) totalLength from #localCheck
					group by AdID, AirDT, AirHour
					having sum(adlength) > 180) k
					inner join #localCheck l on l.AdID = k.AdID and l.AirDT = k.AirDT and l.AirHour = k.AirHour
					
					--select * from #totalSecsTooHigh
			
					update #localCheck
					set AirTime = '08:10',
					AirHour = '08:00',
					AdLength = 60
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 5
			
					/*
					select * from #localcheck
						 IF for any block of local Ads the length is > 120 seconds 
						THEN - we calculate the Known Local Share (see above in i)) for the first and last matchupID of the block
						- for the occurrence with the lowest non-zero Known Local Share AND the Matchup Score = 0 we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic)
						-in case of a tie we do nothing, otherwise we go back to step ii)
					*/
					update #localCheck
					set AirTime = '08:10:30',
					AirHour = '08:00',
					AdLength = 60,
					BaOccurrence = (select min(NationalClearanceID) from @occs where EpisodeID = 'EP7770820184' and NationalClearanceID is not null)
					,MatchupID = (select min(MatchupId) from @occs )
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 6

					update @occs
					set MatchupID = (select min(MatchupId) from @occs )
					from @occs a
					where a.OccurrenceDetailTVID in (select b.OccurrenceDetailTVID from #localCheck b where b.AirHour = '08:00' and b.airtime = '08:10:30')
			
					update #localCheck
					set AirTime = '08:11',
					AirHour = '08:00',
					AdLength = 90
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 7

					update #localCheck
					set AirTime = '08:35:30',
					AirHour = '08:00',
					AdLength = 60
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 8
			
					update #localCheck
					set AirTime = '08:36',
					AirHour = '08:00',
					AdLength = 60
					from #localCheck a
					inner join #cableBlockCheck b on b.OccurrenceDetailTVID = a.OccurrenceDetailTVID and b.BaOccurrence = a.BaOccurrence
					where b.top1 = 9

					
					--select * from #blocks
			end

			-- TEST IF for any block of local Ads the length is > 120 seconds 
			drop table #blockIsTooLong
			--IF the total length of all Local Ads(for that 1 hour)  is > 180 seconds 
			select a.* into #blockIsTooLong from
			(select *, airtime  as startTime, dateadd(second, adlength, airtime) as endtime from #localCheck
			) a
			--inner join #localCheck l on l.AdID = k.AdID and l.AirDT = k.AirDT and l.AirHour = k.AirHour

			drop table #blockTooLongTemp			
			select a.* into #blockTooLongTemp from (	
			select a.AirDT, a.AirHour, a.OccurrenceDetailTVID,a.startTime, a.endtime,b.OccurrenceDetailTVID as parentOccurrenceID, b.startTime as parentStartTime, b.endtime as parentEndTime from #blockIsTooLong a
			left join #blockIsTooLong b on a.AdID = b.AdID and a.AirDT = b.AirDT and a.AirHour = b.AirHour
			where a.startTime <> b.startTime and 
			a.startTime between b.startTime and b.endtime) a
			
			drop table #blockTooLongMins
			select c.* into #blockTooLongMins from (
			select a.* from #blockTooLongTemp a
			where not exists (select * from #blockTooLongTemp b where a.parentStartTime > b.parentStartTime and a.parentStartTime <= b.endtime) 	
			) c

			drop table #blocks
			select a.* into #blocks from (
			select AirDT, AirHour, parentStartTime as blockStartTime, max(endtime) blockEndTime from #blockTooLongMins
			group by AirDT, AirHour, parentStartTime
			) a

			--select * from #blocktoolongmins


			--select * from #blocks

			drop table #blocksTooLong
			select a.blockStartTime, a.blockEndTime, b.* into #blocksTooLong from #blocks a
			inner join #localCheck b on a.AirDT = b.AirDT and a.AirHour = b.AirHour 
			where b.AirTime  between a.blockStartTime and a.blockEndTime
			AND DATEDIFF(second, a.blockStartTime, a.blockEndTime) > 120

			/*

			 IF for any block of local Ads the length is > 120 seconds 
			THEN - we calculate the Known Local Share (see above in i)) for the first and last matchupID of the block
			- for the occurrence with the lowest non-zero Known Local Share AND the Matchup Score = 0 we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic)
			-in case of a tie we do nothing, otherwise we go back to step ii)

			*/

			update @occs
			set Clearance = 'National',
			ClearanceMethod = 'A'

			--select d.* 
			from @occs d
			inner join
			(
			select case 
				when c.minLocalShare > 0 and (c.minLocalShare < c.maxLocalShare) then c.minMatch
				when c.maxLocalShare > 0 and (c.maxLocalShare < c.minLocalShare) then c.maxMatch
				else 0
				end as minMatchupID 
				, c.blockStartTime
				,c.AirDT
				from 
			(
			select b.minMatch,  (b.minMatchCount / (b.minMatchCount * 1.0 + b.nationalMinCount * 1.0)) as minLocalShare
					,b.maxMatch,  (b.maxMatchCount / (b.maxMatchCount * 1.0 + b.nationalmaxCount * 1.0)) as maxLocalShare
					,b.blockStartTime, b.airDT
			 from 
			(
			select minMatch,  (select count(*) from #localCheck where MatchupID = a.minMatch) as minMatchCount,
					(select count(*) from @occs where MatchupID = a.minMatch and NationalClearanceID is not null) as nationalMinCount,
					maxMatch, (select count(*) from #localCheck where MatchupID = a.maxMatch) as maxMatchCount, 
					(select count(*) from @occs where MatchupID = a.maxMatch and NationalClearanceID is not null) as nationalMaxCount,
					blockStartTime, airDT
					 from 
			(select min(MatchupID) minMatch, max(MatchupID) maxMatch,  blockStartTime, airDT from #blocksTooLong a group by airDt,  blockStartTime) a
			)b
			)c
			) e on e.minMatchupId = d.MatchupID and  d.Clearance = 'Cable'
			inner join #blocksTooLong f on e.AirDT = f.AirDT and e.blockStartTime = f.blockStartTime and e.minMatchupID = f.MatchupID 
			and f.OccurrenceDetailTVID = d.OccurrenceDetailTVID


			/*
				If too many blocks
				 IF the number of local blocks is > 3 
				THEN - we calculate the Known Local Share (see above in i)) for each matchupID in each local block
						   -We keep the 3 local blocks with the highest minimum Known Local Share as ‘local’
						For all other Local blocks we change the Clearance to ‘national’ and the ClearanceMethod to ‘A’       for all the occurrences within those blocks.  
				-In case of a tie for 3rd we keep the extra blocks.
				-If any change was made we go back to step ii)

			*/

			drop table #tooManyBlocks
			select airDt, airHour into #tooManyBlocks from #blocks a
			group by  airDt, AirHour
			having count(*) > 3

			drop table #tooManyBlocksDetail
			select b.* into #tooManyBlocksDetail from #tooManyBlocks a
			inner join #localCheck b on b.airDt = a.airDt and b.AirHour = a.AirHour
			--inner join #blocks c on c.AirDT = c.AirHour
			
			drop table #tooManyBlocksLocalShare
			select * into #tooManyBlocksLocalShare from (
			select b.MatchupID,  (b.MatchCount / (b.MatchCount * 1.0 + b.nationalCount * 1.0)) as LocalShare
								,b.airHour, b.airDT
			 from 
			(			select distinct MatchUpID,  (select count(*) from #localCheck where MatchupID = a.MatchupID) as MatchCount,
					(select count(*) from @occs where MatchupID = a.MatchupID and NationalClearanceID is not null) as nationalCount
					,a.airHour, airDT
					 from  #tooManyBlocksDetail a
			) b
			)c

			drop table #tooManyBlocksNumbered
			;WITH cteTooManyBlocks AS
			(
				SELECT a.LocalShare, a.MatchupID,  b.*,
						ROW_NUMBER() OVER (PARTITION BY a.AirDt, a.AirHour, a.MatchupID ORDER BY a.localShare DESC) AS top1
				FROM #tooManyBlocksLocalShare a
				inner join #blocks b on a.AirDT = b.AirDT and a.AirHour = b.AirHour
			)
			select * into #tooManyBlocksNumbered
			FROM cteTooManyBlocks

			update @occs
			set Clearance = 'Local'
			from @occs c
			inner join (
			select a.* from #localCheck a
			inner join #tooManyBlocksNumbered b
			on a.AirDT = b.AirDT and a.AirHour = b.AirHour and a.MatchupID = b.MatchupID
			and cast(a.AirTime as time) between cast(b.blockStartTime as time) and cast(b.blockEndTime as time)
			where b.top1 <= 3
			)d on d.OccurrenceDetailTVID = c.OccurrenceDetailTVID

			update @occs
			set Clearance = 'National'
			, ClearanceMethod = 'A'
			from @occs c
			inner join (
			select a.* from #localCheck a
			inner join #tooManyBlocksNumbered b
			on a.AirDT = b.AirDT and a.AirHour = b.AirHour and a.MatchupID = b.MatchupID
			and cast(a.AirTime as time) between cast(b.blockStartTime as time) and cast(b.blockEndTime as time)
			where b.top1 > 3
			)d on d.OccurrenceDetailTVID = c.OccurrenceDetailTVID


			/*
				If total seconds is too high
				 IF the total length of all Local Ads(for that 1 hour)  is > 180 seconds 
				THEN - we calculate the Known Local Share (see above in i)) for each Local matchupID in the Match array
				- for the occurrence with the lowest non-zero Known Local Share  we change the Clearance to ‘national’ and the  ClearanceMethod to ‘A’ (Local Avail Logic) in the Match array.
				-in case of the tie we do nothing, otherwise we go back to step ii)
			*/
			
			drop table #tooManySeconds
			select sum(datediff(second, blockStartTime, blockEndTime)) as totalSeconds, airDt, airHour into #tooManySeconds from #blocks a
			group by  airDt, AirHour
			having sum(datediff(second, blockStartTime, blockEndTime)) > 120

			--select * from #tooManySeconds

			drop table #tooManySecondsDetail
			select b.* into #tooManySecondsDetail from #tooManySeconds a
			inner join #localCheck b on b.airDt = a.airDt and b.AirHour = a.AirHour
			--inner join #blocks c on c.AirDT = c.AirHour
			
			drop table #tooManySecondsLocalShare
			select * into #tooManySecondsLocalShare from (
			select b.MatchupID,  (b.MatchCount / (b.MatchCount * 1.0 + b.nationalCount * 1.0)) as LocalShare
								,b.airHour, b.airDT
			 from 
			(			select distinct MatchUpID,  (select count(*) from #localCheck where MatchupID = a.MatchupID) as MatchCount,
					(select count(*) from @occs where MatchupID = a.MatchupID and NationalClearanceID is not null) as nationalCount
					,a.airHour, airDT
					 from  #tooManySecondsDetail a
			) b
			)c

			drop table #tooManySecondsNumbered
			;WITH ctetooManySeconds AS
			(
				SELECT a.LocalShare, a.MatchupID,  b.*,
						ROW_NUMBER() OVER (PARTITION BY a.AirDt, a.AirHour, a.MatchupID ORDER BY a.localShare DESC) AS top1
				FROM #tooManySecondsLocalShare a
				inner join #blocks b on a.AirDT = b.AirDT and a.AirHour = b.AirHour
			)
			select * into #tooManySecondsNumbered
			FROM ctetooManySeconds

			update @occs
			set Clearance = 'National'
			, ClearanceMethod = 'A'
			from @occs c
			inner join (
			select a.* from #localCheck a
			inner join #tooManySecondsNumbered b
			on a.AirDT = b.AirDT and a.AirHour = b.AirHour and a.MatchupID = b.MatchupID
			and cast(a.AirTime as time) between cast(b.blockStartTime as time) and cast(b.blockEndTime as time)
			where b.top1 < 2
			)d on d.OccurrenceDetailTVID = c.OccurrenceDetailTVID

			/*
				All Clearance buckets logic
				The next operations apply to occurrences from all Clearance buckets:
				If any Comparison Array occurrence with a ‘local’ Clearance (Matchup Score = 0 in the Match array) has a MatchupID which appears during enough Episode Instances then we can create a new National occurrence: either we replace (by adding one record and removing one) or we add a record in the existing National template.

				We loop through all the ‘local’ occurrences in the Comparison array to check if any new “national occurrence” should be added to the National template:
				For each ‘local’ occurrence CA[i] from the Comparison array we do:
				** Begin
				i) We fetch all occurrences from our temp table #TempOccs  within the same Processable Chunk (identified through ChunkID) from Decision Stations (station IDs in the table DecisionStations) having: 
				a Match Score (see Appendix 15.3 for the formula) with the given occurrence CA[i]  > 0 
				AND ABS(ElapsedTime + Offset - CA[i] 's ElapsedTime + Offset) < Aligned Distance Check 

				ii) IF count of the occurrences fetched above count of distinct Decision StationIDs for the given Processable Chunk < Instance Share Threshold
				THEN we insert the given occurrence CA[i] of the Comparison array in the National template and we update the Clearance (to ‘national’) and the ClearanceMethod (to ‘A’) of the occurrence CA[i] in the output Match array.
				Note: When we insert the occurrence’s attributes in the National template, we replace the occurrence’s StationID by the occurrence’s Network.

				** End

			*/


			--testing with current sampling
			set @instanceShareThreshold = 3000

			drop table #findInstanceShare
			select distinct f.* into #findInstanceShare
			from (
			select c.* from @occs c
			inner join (
			select DISTINCT a.* from #caAll a
			inner join #caAll b on a.chunkID = b.chunkID and b.MatchScore > 0
			inner join DecisionStation ds on ds.TVStationID = a.TVStationID
			where a.MatchScore <= 0) d on d.MatchupID = c.MatchupID
			inner join #caAll e on e.OccurrenceDetailTVID = c.OccurrenceDetailTVID
			where e.OccurrenceDetailTVID <> d.OccurrenceDetailTVID
			AND ABS((e.ElapsedTime + e.offset)  - (e.elapsedTime + e.offset)) < @alignedDistanceCheck
			)f

			drop table #NatTempInstThresh
			select instanceShare.* into #NatTempInstThresh from
			(
			select f.ChunkID, ((f.TotalOccurrences*1.0)/(e.decisionStations*1.0)) as instanceThreshold
			from 
			(select chunkID, count(*) totalOccurrences from #findInstanceShare group by chunkID) f
			inner join
			(select c.chunkID, count(*) decisionStations from (
			select distinct a.chunkID, b.TVStationID from @occs a
			inner join DecisionStation b on a.TVStationID = b.TVStationID
			) c
			group by c.ChunkID) e
			on f.ChunkID = e.ChunkId) thresholdMatch
			inner join #findInstanceShare instanceShare on thresholdMatch.ChunkID = instanceShare.ChunkID
			
			if @testMode = 1
			begin
				update #NatTempInstThresh
				set NationalClearanceID = null
				where Clearance = 'Syndicated'

				update @occs 
				set NationalClearanceID = (select max (b.NationalClearanceID) + 1 from #caAll a
											inner join @occs b on a.OccurrenceDetailTVID = b.OccurrenceDetailTVID
											where b.nationalClearanceID is not null )
				from @occs a
				where a.NationalClearanceID is null
				and a.EpisodeID = 'EP9990820184'

				--select (select max (b.NationalClearanceID) + 1 from #caAll a
				--							inner join @occs b on a.OccurrenceDetailTVID = b.OccurrenceDetailTVID
				--							where b.nationalClearanceID is not null )
				--from @occs a
				--where a.NationalClearanceID is null
				--and a.EpisodeID = 'EP9990820184'


			end

			/*
				*Begin
				-For the given occurrence’s MatchupID (NationalTemplate. MatchUpID), we fetch all the occurrences within the processable chunk (same ChunkID) linked to the current Comparison Array (OccurrenceID
				 Is in the array) that have a Match Score > 2 (see Appendix 15.3 for the Match Score calculation).
				-Count the distinct Decision Station IDs   of the occurrence gathered above.
				- IF  Count the distinct Decision Station IDs   of the occurrence gathered above Count of the distinct Decision Station IDs for the given processable chunk   > National Share Needed 
				THEN we keep the occurrence in the National Template 
				ELSE we delete occurrence from the National Template (This scenario happens when an occurrence that was un-indexed (MatchupId=PatternID) is indexed (MatchupId=AdID) .
				*End
			*/

			drop table #NatShareNeeded


			select a.* into #NatShareNeeded from (
			--select a.* from (
			select distinct b.MatchScore, a.* from @occs a
			inner join #caAll b on a.chunkID = b.ChunkID and b.MatchScore > 2
			where a.NationalClearanceID is not null
			and a.OccurrenceDetailTVID not in (
			select distinct a.OccurrenceDetailTVID from #caAll a
			inner join @occs b on a.OccurrenceDetailTVID = b.OccurrenceDetailTVID
			where b.nationalClearanceID is not null 
			) 
			) a


			drop table #NatShareThresh
			select NationalThreshold, nationalShare.* into #NatShareThresh from
			(
			select f.ChunkID, ((f.TotalOccurrences*1.0)/(e.decisionStations*1.0)) as NationalThreshold
			from 
			(select chunkID, count(*) totalOccurrences from #NatShareNeeded group by chunkID) f
			inner join
			(select c.chunkID, count(*) decisionStations from (
			select distinct a.chunkID, b.TVStationID from @occs a
			inner join DecisionStation b on a.TVStationID = b.TVStationID
			) c
			group by c.ChunkID) e
			on f.ChunkID = e.ChunkId) thresholdMatch
			inner join #NatShareNeeded nationalShare on thresholdMatch.ChunkID = nationalShare.ChunkID 


			if @testMode = 1
			begin
				insert into #NatShareThresh (OccurrenceDetailTVID, NationalThreshold, MatchScore)
				values( (select min(occurrenceDetailTVID) from @occs), 1.7 , 4 )
			end

			--select * from #NatShareNeeded
			--select * from #NatShareThresh

			--select * from @occs
			--select * from #caall
			--select * from #NatShareThresh

			update @occs 
			set Clearance = 'National'
			where OccurrenceDetailTVID in 
			(select OccurrenceDetailTVID from #NatShareThresh where NationalThreshold > @nationalShareNeeded)

			update @occs 
			set Clearance = 'NotNational'
			where OccurrenceDetailTVID in 
			(select OccurrenceDetailTVID from #NatShareThresh where NationalThreshold <= @nationalShareNeeded)

			--select * from #localcheck
			--select * from @occs order by clearance
			--where not exists (select occurrenceDetailTVID from #caAll b where a.OccurrenceDetailTVID = b.OccurrenceDetailTVID)

			/*
			4.1.7. Execute Comparison Process for non-Decision Occurrences
			In section 4.1.6.2 we identified the Decision Occurrences to produce a National template, but the TV clearance need to be calculated for all remaining Cable, Network, and Syndicated airplays that were “reduced” (#TempOccs .Decision Priority=’N’).
			All those occurrences are grouped into Episode Instances (see section 4.1.6.3) within their Processable Chunk (field #TempOccs.ChunkID ) before we execute the Comparison process (only the Clearance Comparison in comparison mode since a National Template has already been produced) to determine their clearance:
			For each Episode Instance within the processable chunk we call:
			ClearanceComparison (Episode Instance; National template; Clearance bucket; ‘Comparison mode’;’Yes’)

			The output of the procedure is a Match array that contains the Weighted Match Score of each record of the Episode Instance against the National Template. For each row of Episode Instance that is present in the Match array with its Matchup Score > 0 we update the clearance as ‘national , the NationalClearanceID  is set to the ; National template.OccurrenceID (ID in the table NationalClearance) and the ClearanceMethod is set to ‘C’ (see Appendix 15.2 Clearance Method Values) in the table #TempOccs.

			*/

		--select * from tvNationalClearance
		drop table #baAllNonDecision
		select a.* into #baAllNonDecision
		from (
		select 
				b.Clearance ,
				b.AirDate,
				b.AirTime,
				b.ProgramID,
				b.EpisodeID,
				b.MatchupID,
				b.TVNationalClearanceID as BaOccurrence
				,b.ElapsedTime
				,a.[AdID]
				,0 as [PatternID]
				,c.[AdvertiserID] 
				,c.[ParentAdvertiserID]
				,a.OriginalAdID as ParentADID
		from TVNationalClearance b
		inner join Ad a on a.adID = b.MatchupID
		inner join Advertiser c on a.AdvertiserID = c.AdvertiserID 
		inner join @occs  d on d.MatchupID = b.MatchupID and d.AirDT = b.AirDate and d.EpisodeID = b.EpisodeID 
		) a
		order by a.ProgramID, a.EpisodeID, a.ElapsedTime



		drop table #caAllNonDecision

		/*
		create a place holder column to hold hour for cable entries
		*/
		select c.* into #caAllNonDecision
		from (
		select distinct cast(0 as float) as WeightedMatchScore,  0 as MatchScore,a.OccurrenceDetailTVID as BaOccurrence, a.ElapsedTime as BaElapsedTime, 0 as Offset,
				a.[Clearance]
				,a.[ClearanceMethod]
				,a.[AirDT]
				,a.[AirTime]
				,a.[ProgramID]
				,a.[EpisodeID]
				,a.[MatchupID]
				,a.[AdID]
				,a.[PatternID]
				,a.[AdvertiserID] 
				,a.[ParentAdvertiserID]
				,a.adLength
				,a.OccurrenceDetailTVID
				,a.ElapsedTime
				,a.ParentADID
		from @occs a
		--inner join TVNationalClearance  b on  a.AirDT = b.AirDate and a.EpisodeID = b.EpisodeID
		where a.Clearance in ('Cable', 'Syndicated', 'Broadcast Network') and DecisionPriority = 'N'
		) c


		/*
		A.Matchup ID = B.Matchup ID	Match Score = 4
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllNonDecision 
		set MatchScore = 4
		,WeightedMatchScore = (4/4.0) * (a.AdLength/30.0)
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		--select a.* fro
		from #caAllNonDecision a
		inner join #baAllNonDecision b on a.MatchupID = b.MatchupID
		where a.MatchupID is not null and b.MatchupID is not null

		/*
		A. Parent AD ID = B. Parent AD ID	Match Score = 3
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllNonDecision 
		set MatchScore = 3
		,WeightedMatchScore = ((3/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllNonDecision a
		inner join #baAllNonDecision b on  a.ParentAdID = b.ParentAdID
		where a.MatchScore = 0 and
		(a.ParentAdID is not null and b.ParentAdID is not null)

		/*
		A. Advertiser = B. Advertiser	Match Score = 2
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllNonDecision 
		set MatchScore = 2
		,WeightedMatchScore = ((2/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllNonDecision a
		inner join #baAllNonDecision b on a.AdvertiserID = b.AdvertiserID
		where a.MatchScore = 0 and
		(a.AdvertiserID is not null and b.AdvertiserID is not null)

		/*
		A.Parent Advertiser = B. Parent Advertiser AND
		A.Subcategoty= B. Subcategoty	Match Score = 1
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllNonDecision 
		set MatchScore = 1
		,WeightedMatchScore = ((1/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllNonDecision a
		inner join #baAllNonDecision b on  a.ParentAdvertiserID = b.ParentAdvertiserID
		where a.MatchScore = 0 and
		(a.ParentAdvertiserID is not null and b.ParentAdvertiserID is not null)

		--select * from #caall

		/*
		The business logic to produce the output Match Array is the following:

		a -Load the clearance bucket-specific parameters from the table ClearanceBucketParameter and set the parameter values  offset, FirstBasisMatch  and weighted alignment score to 0. 

		b-We align the Comparison Array to Basis Array as follows:

		i) We loop through all the occurrences in the Basis array (ordered by ElapsedTime ascending) and for each occurrence (row L) BA[L] we are looking through all the records of the Comparison array to find an occurrence CA[X] with the same MatchupID:
		ii) We loop through all the occurrences in the Comparison array (ordered by ElapsedTime ascending) and for each occurrence (row X) we are checking if BA[L]. MatchupID= CA[X]. MatchupID

		*/

		delete from @matchArray

		insert into @matchArray(
						OccurrenceID ,
						MatchupID ,
						ElapsedTime ,
						Clearance ,
						ClearanceMethod,
						AdLength ,
						Offset ,
						BaOccurrence ,
						WeightedMatchScore)
		select distinct a.OccurrenceDetailTVID
			,a.MatchupID
			,a.ElapsedTime
			,a.Clearance
			,'C'
			,a.AdLength
			,a.Offset
			,a.BaOccurrence
			,a.MatchScore
		from 
		#caAllNonDecision a
		where  a.MatchScore > 0 

		--select * from @occs	
		--select * from tvNationalClearance

		--select * from #caallNonDecision

		--select * from @matchArray

		update @occs 
		set Clearance = 'National'
		, NationalClearanceID = b.BaOccurrence
		, ClearanceMethod = 'C'
		from @occs a
		inner join @matchArray b on a.OccurrenceDetailTVID = b.OccurrenceID



		/*

		4.1.8. Execute Comparison Process for all Local Programming
		In section 4.1.4 we identified the occurrences that belong to the Local Clearance Bucket. We execute the Comparison process (Clearance Comparison in comparison mode) to determine their clearance.
		The Basis Array used for the comparison mode should consist of all National airings for the given Network-Broadcast Day plus all Syndicated Airings for the given Broadcast Day. The list should be ordered by Program ID, Episode ID and Elapsed Time.  
		The National airings are retrieved from the table NationalClearance where the National Templates that were produced in 4.1.6.3 are stored with their stationID, AirDate, AirTime, ProgramID, EpisodeID and ElapsedTime:
 
		The output of the procedure is a Match array that contains the Match Score of each record of the Episode Instance (from the Local Clearance Bucket) against the National Template. For each row of the local Episode Instance that is present in the Match array with its Matchup Score > 0 we update its clearance to ‘national , its NationalClearanceID  is set to the ; National template.OccurrenceID (ID in the table NationalClearance) and the ClearanceMethod is set to ‘C’ (see Appendix 15.2 Clearance Method Values) in the table #TempOccs.



		Within each Processable Chunk we sort all the Episodes Instances by Clearance Priority (retrieved from the DecisionStations table), and we set the Episode Instance with the lowest ClearancePriority as the Basis array BA. 

		iii) We loop through all remaining episode instances within a given chunk to use them as the Comparison array (CA) to call the Clearance Comparison procedure.
		-If a National Template array already exists (and is not null), we use it as the  basis array BA (instead of the Episode Instance with the lowest Clearance Priority) and we set the National Template flag to ‘yes’:
		call ClearanceComparison (CA; BA; Clearance bucket; ‘Decision mode’; National template flag)
				See Appendix 15.1  for the details of the Clearance Comparison procedure.

		*/
		--select * from tvNationalClearance
		drop table #baAllLocal
		select a.* into #baAllLocal
		from (
		select 
				b.Clearance ,
				b.AirDate,
				b.AirTime,
				b.ProgramID,
				b.EpisodeID,
				b.MatchupID,
				b.TVNationalClearanceID as BaOccurrence
				,b.ElapsedTime
				,a.[AdID]
				,0 as [PatternID]
				,c.[AdvertiserID] 
				,c.[ParentAdvertiserID]
				,a.OriginalAdID as ParentADID
		from TVNationalClearance b
		inner join Ad a on a.adID = b.MatchupID
		inner join Advertiser c on a.AdvertiserID = c.AdvertiserID 
		inner join @occs  d on d.MatchupID = b.MatchupID and d.AirDT = b.AirDate and d.EpisodeID = b.EpisodeID 
		) a
		order by a.ProgramID, a.EpisodeID, a.ElapsedTime



		drop table #caAllLocal

		/*
		create a place holder column to hold hour for cable entries
		*/
		select c.* into #caAllLocal
		from (
		select distinct cast(0 as float) as WeightedMatchScore,  0 as MatchScore,a.OccurrenceDetailTVID as BaOccurrence, a.ElapsedTime as BaElapsedTime, 0 as Offset,
				a.[Clearance]
				,a.[ClearanceMethod]
				,a.[AirDT]
				,a.[AirTime]
				,a.[ProgramID]
				,a.[EpisodeID]
				,a.[MatchupID]
				,a.[AdID]
				,a.[PatternID]
				,a.[AdvertiserID] 
				,a.[ParentAdvertiserID]
				,a.adLength
				,a.OccurrenceDetailTVID
				,a.ElapsedTime
				,a.ParentADID
		from @occs a
		--inner join TVNationalClearance  b on  a.AirDT = b.AirDate and a.EpisodeID = b.EpisodeID
		where a.Clearance = 'Local'
		) c


		/*
		A.Matchup ID = B.Matchup ID	Match Score = 4
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllLocal 
		set MatchScore = 4
		,WeightedMatchScore = (4/4.0) * (a.AdLength/30.0)
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		--select a.* fro
		from #caAllLocal a
		inner join #baAllLocal b on a.MatchupID = b.MatchupID
		where a.MatchupID is not null and b.MatchupID is not null

		/*
		A. Parent AD ID = B. Parent AD ID	Match Score = 3
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllLocal 
		set MatchScore = 3
		,WeightedMatchScore = ((3/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllLocal a
		inner join #baAllLocal b on  a.ParentAdID = b.ParentAdID
		where a.MatchScore = 0 and
		(a.ParentAdID is not null and b.ParentAdID is not null)

		/*
		A. Advertiser = B. Advertiser	Match Score = 2
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllLocal 
		set MatchScore = 2
		,WeightedMatchScore = ((2/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllLocal a
		inner join #baAllLocal b on a.AdvertiserID = b.AdvertiserID
		where a.MatchScore = 0 and
		(a.AdvertiserID is not null and b.AdvertiserID is not null)

		/*
		A.Parent Advertiser = B. Parent Advertiser AND
		A.Subcategoty= B. Subcategoty	Match Score = 1
		IF BA[L]. MatchupID  is different from CA[X]. MatchupID
		THEN we go back to ii) to go through the loop with the next iteration X+1 of the Comparison array.
		ELSE we look through subsequent rows of both Arrays to see if enough consecutive occurrences match to pass the Weighted Alignment Threshold:
		Note: the Weighted Alignment Score   = Match Score4   x  X.Ad.Length in seconds30 

		First we calculate the Weighted Alignment Score between BA[L] and CA[X]: 
		Given that BA[L]. MatchupID= CA[X]. MatchupID the Match Score is 4 (see Appendix 15.3 Match Score), and therefore the Weighted Alignment Score between BA[L] and CA[X] is = CA[X].Ad.length /30.
		*/
		update #caAllLocal 
		set MatchScore = 1
		,WeightedMatchScore = ((1/4.0) * (a.AdLength/30.0))
		,BaOccurrence = b.BaOccurrence
		,BaElapsedTime = b.ElapsedTime
		,Offset = ABS(b.ElapsedTime - a.ElapsedTime)
		from #caAllLocal a
		inner join #baAllLocal b on  a.ParentAdvertiserID = b.ParentAdvertiserID
		where a.MatchScore = 0 and
		(a.ParentAdvertiserID is not null and b.ParentAdvertiserID is not null)

		--select * from #caall

		/*
		The business logic to produce the output Match Array is the following:

		a -Load the clearance bucket-specific parameters from the table ClearanceBucketParameter and set the parameter values  offset, FirstBasisMatch  and weighted alignment score to 0. 

		b-We align the Comparison Array to Basis Array as follows:

		i) We loop through all the occurrences in the Basis array (ordered by ElapsedTime ascending) and for each occurrence (row L) BA[L] we are looking through all the records of the Comparison array to find an occurrence CA[X] with the same MatchupID:
		ii) We loop through all the occurrences in the Comparison array (ordered by ElapsedTime ascending) and for each occurrence (row X) we are checking if BA[L]. MatchupID= CA[X]. MatchupID

		*/

		delete from @matchArray

		insert into @matchArray(
						OccurrenceID ,
						MatchupID ,
						ElapsedTime ,
						Clearance ,
						ClearanceMethod,
						AdLength ,
						Offset ,
						BaOccurrence ,
						WeightedMatchScore)
		select distinct a.OccurrenceDetailTVID
			,a.MatchupID
			,a.ElapsedTime
			,a.Clearance
			,'C'
			,a.AdLength
			,a.Offset
			,a.BaOccurrence
			,a.MatchScore
		from 
		#caAllLocal a
		where  a.MatchScore > 0 

		--select * from @occs
		--select * from tvNationalClearance

		--select * from #caalllocal

		--select * from @matchArray

		update @occs 
		set Clearance = 'National'
		, NationalClearanceID = b.BaOccurrence
		, ClearanceMethod = 'C'
		from @occs a
		inner join @matchArray b on a.OccurrenceDetailTVID = b.OccurrenceID

		/*
			4.1.9. Process Independent Airplay
			In section 4.1.4 we identified the Occurrences that belong to the Independent Clearance Bucket.
			For each of those occurrences we use its StationID and the following use cases:

			IF the Station is 	Set
			The station belongs to a National Cable network: for the given station the DMA = ‘National Cable’ 
 
	


			Clearance = ‘National’


			Note: As of today the scope of stations meeting that criteria is limited to some domestic Asian-Language Cable stations & Canadian Cable stations.

		*/
		update @occs 
		set Clearance = 'National'
		, ClearanceMethod = 'I'
		from @occs a
		--select a.* from @occs a
		inner join TVStation b on a.TVStationID = b.TVStationID
		inner join Market c on b.MarketID = c.MarketID
		where 
		a.Clearance = 'Independent'
		and c.NielsenDMAName = 'National Cable'

		update @occs
		set Clearance = 'Local'
		,ClearanceMethod = 'I'
		where Clearance = 'Independent'

		--select * from @occs

	
	/*
		Update
		When a record is updated in the TV Clearance table, we are logging the old and new values in the table TVClearanceLog .

 

		TVClearanceLog
		LogID                 466433
		TVClearanceID   5363
		Field                    CleranceMethod 
		OldValue              A
		NewValue            N
		CreateDTM           8/20/2015 3:10PM



		2 kinds of update are prohibited and should be rejected:
		-Any update to a record with a National clearance that would change it into an occurrence being part of a local buy.
		-Any update to a record whose ClearanceLockDTM is not NULL: it means that a Data Analyst has intentionally locked the record to prevent further updates to it.

	*/

	INSERT INTO [dbo].[OccurrenceClearanceLogTV]
           ([OccurrenceClearanceTVID]
           ,[OldClearance]
           ,[OldDeleted]
           ,[NewClearance]
           ,[NewDeleted]
           ,[InsertedDT])
	SELECT b.[OccurrenceDetailTVID] 
			,b.[Clearance] 
		  ,b.[ClearanceMethod]
			,a.[Clearance] 
		  ,a.[ClearanceMethod]
		  ,GETDATE()
		  from @occs a
		  inner join OccurrenceClearanceTV b
		  on a.[OccurrenceDetailTVID] = b.[OccurrenceDetailTVID]
		  where not ( b.Clearance = 'National' and a.Clearance = 'Local')
		  and b.ClearanceLockDT is null;


	INSERT INTO [dbo].[OccurrenceClearanceRejectedLogTV]
				([OccurrenceClearanceTVID]
				,[Reason]
				,[CreateDT])
     SELECT b.[OccurrenceDetailTVID] 
			,'National clearance would be changed to Local'
		  ,GETDATE()
		  from @occs a
		  inner join OccurrenceClearanceTV b
		  on a.[OccurrenceDetailTVID] = b.[OccurrenceDetailTVID]
		  where b.Clearance = 'National' and a.Clearance = 'Local'
		  

	INSERT INTO [dbo].[OccurrenceClearanceRejectedLogTV]
				([OccurrenceClearanceTVID]
				,[Reason]
				,[CreateDT])
     SELECT b.[OccurrenceDetailTVID] 
			,'Clearance record is locked'
		  ,GETDATE()
		  from @occs a
		  inner join OccurrenceClearanceTV b
		  on a.[OccurrenceDetailTVID] = b.[OccurrenceDetailTVID]
		  where b.ClearanceLockDT is null;


		  
	INSERT INTO [dbo].[OccurrenceClearanceTV]
           ([OccurrenceDetailTVID]
           ,[Clearance]
           ,[ClearanceMethod]
           ,[AirDT]
           ,[AirTime]
           ,[ProgramID]
           ,[EpisodeID]
           ,[ElapsedTime]
           ,[Offset]
           ,[TVNationalClearanceID]
           ,[MatchupID]
           ,[AdID]
           ,[PatternID]
           ,[Valid]
           ,[Deleted]
           --,[CreatedDT]
           --,[CreatedByID]
           --,[ModifiedDT]
           --,[ModifiedByID]
		   )

	SELECT [OccurrenceDetailTVID] 
			,[Clearance] 
		  ,[ClearanceMethod]
		  ,[AirDT] 
		  ,[AirTime] 
		  ,[ProgramID] 
		  ,[EpisodeID] 
		  ,[ElapsedTime] 
		  ,0 as Offset --??? Where does this value come from
		  ,[NationalClearanceID] 
		  ,[MatchupID] 
		  ,[AdID] 
		  ,[PatternID] 
		  ,[Valid] 
		  ,0
		  from @occs a
		  WHERE NOT EXISTS ( SELECT 1 from OccurrenceClearanceTV
		  WHERE a.[OccurrenceDetailTVID] = [OccurrenceDetailTVID])


		  --select * from occurrenceClearanceTV


/*
	4.1.11. Post results to the Client-Facing Occurrence Table
	From our universe of Ad occurrence records in the TV Clearance table, we post to the Client Facing table all the distinct combinations (AdID/ Station ID/ Air Date/Air Time/Program ID): NOT all the records from TVClearance are inserted to the Client Facing table: only the airings that are part of local buys and the national airings are posted to OccurrenceClientFacingTV. 
	Note: Only clearance records with a valid AdId are posted to the Client Facing table. Records for which the MatchupID is not a valid AdID  are not sent to OccurrenceClientFacingTV.
	For each Ad occurrence record stored in the temporary table #TempOccs we look up the fields Clearance and NationalClearanceID to determine which record should be posted to the Client Facing table:


	IF for an occurrence record	Action

	The clearance is local

	All occurrences from a local buy will have a record in the Client Facing table.	The occurrence’s attributes from the TV Clearance table are posted to the Client Facing table:
	TVClearance ID
	Station ID 
	Air Date
	Air Time
	Program ID 
	Clearance
	AdId


	The Clearance is National

	For N airings from a national buy with the same NationalClearanceID there will be 1 record in the Client Facing table: we are posting records from the table NationalClearance rather than all occurrences from the TV Clearance table.	We are posting the attributes from the table NationalClearance:
	NationalClearanceID (and not the TVClearanceID)
	Station ID (Network of the Station ID of the National Template)
	Air Date
	Air Time
	Program ID 
	Clearance
	AdId


	All Inserts/Updates/Deletions to the TV Clearance table are reflected in Client Facing table except for TV Clearance records for which the MatchupID is not a valid AdID.

	When the inserts and updates to the Client Facing table are performed, a trigger updates the field EditDate for the associated record in the AdChangeLogTV tracking table. That table will be used by the Costing downstream process.

*/

	INSERT INTO [dbo].[OccurrenceClientFacingTV]
           ([OccurrenceDetailTVId]
           ,[AdID]
           ,[OccurrenceClearanceTVId]
           ,[AirDate]
           ,[AirStartTime]
           ,[CreatedDT]
           ,[CreatedByID]
           )
	SELECT 
			 a.[OccurrenceDetailTVId]
           ,a.[AdID]
           ,a.[OccurrenceClearanceTVId]
           ,a.[AirDT]
           ,a.[AirTime]
           ,GETDATE()
           ,0
           
	FROM OccurrenceClearanceTV a
	INNER JOIN @occs b on a.OccurrenceDetailTVID = b.OccurrenceDetailTVID
	INNER JOIN Ad c on b.AdID = c.AdID
	WHERE b.Clearance = 'Local'



	INSERT INTO [dbo].[OccurrenceClientFacingTV]
           (
           TVNationalClearanceID
		   ,Clearance
		   ,ClearanceMethod
           ,[AirDate]
           ,[AirStartTime]
           ,[AdID]
           ,ProgramID
		   ,EpisodeID
		   
		   	)
	SELECT DISTINCT [TVNationalClearanceID]
		  ,b.[Clearance]
		  ,b.[ClearanceMethod]
		  ,b.[AirDT]
		  ,b.[AirTime]
		  ,c.[AdID]
		  ,b.[ProgramID]
		  ,b.[EpisodeID]
	  FROM [dbo].[TVNationalClearance] a
	  INNER JOIN @occs b on a.MatchupID = b.MatchupID
		INNER JOIN Ad c on b.AdID = c.AdID
		WHERE not exists (SELECT 1 from OccurrenceClientFacingTV d where d.TVNationalClearanceID = a.TVNationalClearanceID)

	--select * from tvnationalclearance
	--select * from occurrenceclearancetv
	--select * from occurrenceclientfacingtv
	--select * from ad
	select * from @occs

			/*
		--DEBUG ONLY!!!!
		run the following line if running multiple times

		truncate table tvNationalClearance
		delete from occurrenceclientfacingtv
		truncate table occurrenceclearancelogtv
		delete from occurrenceclearancetv

		*/


      END TRY 
      BEGIN CATCH 
          DECLARE @ERROR   INT,
                  @MESSAGE VARCHAR(4000),
                  @LINENO  INT
          SELECT @ERROR = ERROR_NUMBER(),
                 @MESSAGE = ERROR_MESSAGE(),
                 @LINENO = ERROR_LINE() RAISERROR ('usp_TVClearanceSetup : %d: %s',16,1,@ERROR,@MESSAGE,@LINENO)
      END CATCH; 
  END;