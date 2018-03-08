-- ===========================================================================================
-- Author			: Ramesh Bangi
-- Create date		: 7/28/2015
-- Description		: This stored procedure is used to Getting Exception Queue View Data
-- Execution		: [dbo].[sp_ExceptionAlternateCreative] '14F7HQLL.PA2','Television',0,0
-- Updated By		: Karunakar on 7th Sep 2015  
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_ExceptionAlternateCreative]  
(
 @CreativeSignature AS NVARCHAR(MAX),
 @MediaStreamId AS NVARCHAR(MAX),
 @AdID AS INT,
 @OccurrenceID AS INT  
)
AS


BEGIN
		Declare @Pk_Id INT
		BEGIN TRY
		--select @Pk_Id=Pk_Id from PATTERNMASTERSTGCIN where [FK_CreativeSignature] = @CreativeSignature
		Declare @MediaStreamValue As NVARCHAR(50)
		Select @MediaStreamValue = Value From [Configuration] Where SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamId

		IF(@MediaStreamValue='RAD')	
		Begin
			--Declare @PatternmasterStgId As Int
			--Select  @PatternmasterStgId=[PatternStgID] from PatternStaging Where CreativeSignature=@CreativeSignature			
			SELECT [OccurrenceDetailRAID] as [OccurrenceID], CONVERT(NVARCHAR(10),[OccurrenceDetailRA].[AirDT], 101) As AirDate, 
			convert(char(5), [OccurrenceDetailRA].[AirStartDT], 108) As AirTime,  
			RCSRADIOSTATION.ShortName AS Station,(DATEDIFF(SECOND,[OccurrenceDetailRA].[AirStartDT],[OccurrenceDetailRA].[AirEndDT]))As [Length]
			FROM    [OccurrenceDetailRA]
			INNER JOIN PatternStaging ON PatternStaging.PatternID = [OccurrenceDetailRA].PatternID
			INNER JOIN RCSRADIOSTATION ON [OccurrenceDetailRA].[RCSStationID] = RCSRADIOSTATION.[RCSRadioStationID] 
			INNER JOIN RadioStation ON RCSRADIOSTATION.[RCSRadioStationID] = RadioStation.[RCSStationID] 
			Where PatternStaging.CreativeSignature=@CreativeSignature and  
			RadioStation.[EffectiveDT]<=[AirStartDT]  
			and RadioStation.[EndDT]>=[AirStartDT]  and
			[OccurrenceDetailRA].[PatternID] is Null
			Order by convert(char(5), [OccurrenceDetailRA].[AirStartDT], 108) ASC,RCSRADIOSTATION.ShortName ASC 
		End
		IF(@MediaStreamValue='TV')		 
		BEGIN
			SELECT        [OccurrenceDetailTV].[OccurrenceDetailTVID] As OccurrenceId, CONVERT(NVARCHAR(10),[OccurrenceDetailTV].[AirDT], 101) AS AirDate, convert(char(5), 
			[OccurrenceDetailTV].AirTime, 108) As AirTime, [OccurrenceDetailTV].AdLength AS [Length], [TVStation].StationShortName AS Station
			FROM          [OccurrenceDetailTV] 
			INNER JOIN	  [PatternStaging] ON [OccurrenceDetailTV].[PRCODE] = [PatternStaging].[CreativeSignature] 
			INNER JOIN    TVRecordingSchedule ON [OccurrenceDetailTV].[TVRecordingScheduleID] = TVRecordingSchedule.[TVRecordingScheduleID] 
			INNER JOIN    [TVStation] ON TVRecordingSchedule.[TVStationID] = [TVStation].[TVStationID] 
			Where		  [PatternStaging].[CreativeSignature]=@CreativeSignature and [PatternStaging].[MediaStream] = 144 and [OccurrenceDetailTV].[PatternID] Is Null
			Order By   convert(char(5), [OccurrenceDetailTV].AirTime, 108) ASC,[TVStation].StationShortName ASC
		END
		END TRY
		BEGIN CATCH
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_ExceptionAlternateCreative: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END