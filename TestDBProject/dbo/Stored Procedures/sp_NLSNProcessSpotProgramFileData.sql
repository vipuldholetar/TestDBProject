
-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 11/03/2015   
-- Description: Insert spot files data into database tables.  
-- Query :   
/*  
exec sp_NLSNProcessSpotFilesData '',  
drop procedure sp_NLSNProcessSpotProgramFileData
*/ 
-- =============================================  

CREATE PROCEDURE [dbo].[sp_NLSNProcessSpotProgramFileData] (@NLSNPFData dbo.NLSNPFData readonly, @SpotProgramFileName varchar(100)) 
AS 
  BEGIN 
     -- SET nocount ON; 
      BEGIN TRY 
        BEGIN TRANSACTION 

		--Ingestion of Program file data

		DECLARE @MarketCode varchar(10)

		select @MarketCode = column2
		from @NLSNPFData where column1 = '11'

	
				INSERT INTO NLSNSpotProgramSchedule
				(
					ProgramName,
					ProgramSource,
					NLSNMarketCode,
					[MarketID],
					[NLSNStationID],
					[TVStationID],
					[AirDT],
					[QuarterHourID],
					ProgramStartTime,
					ProgramEndTime,
					NLSNStartTime,
					NLSNEndTime,
					[CreatedDT],
					[CreatedByID]
				)
				select Program, case programSource when 'S' then 'SYN'
                          when 'TEL'  then 'TELA'
						  when 'UMA'  then 'UNIM'
						  when 'UNI '  then 'UNIV'
						  else programSource end, @MarketCode, MarketID, NLSNStationId, TVStationID, 
						  case when x.StartTime > x.EndTime AND q.StartTime >= cast('00:00AM' AS TIME)  then AirDate
						       when q.StartTime >=  cast('00:00AM' AS TIME) and q.StartTime < cast('05:00AM' as time) then DATEADD(day, -1, AirDate) 
							   else AirDate end AirDate, 
						  q.QuarterHourID
						  , x.StartTime, x.EndTime, q.StartTime, q.EndTime, getdate(), 1
				from (
				select Column7 Program,
				case when (Column13 = '' or column13 is null) then column12 else column13 end ProgramSource,
				(select MarketID from NLSNMarketStationMap where [NLSNStationID] = column2) MarketID,
				Column2 NLSNStationId,
				(select TVStationID from NLSNMarketStationMap where [NLSNStationID] = column2) TVStationID,
				cast(Column4 as date) AirDate,
				cast(Column4 as time) StartTime,
				cast(format(dateadd(s,-1,Column5),'MM/dd/yyyy hh:mm:sstt') as time) EndTime
				from NLSNPFData where column1 = '12'
				and column2 in (select distinct [NLSNStationID] from NLSNMarketStationMap where Tracked = 1 and NLSNDMACode = @MarketCode )
				) x, QuarterHour q
				where q.StartTime between x.StartTime and x.EndTime or (x.EndTime < x.StartTime and (x.StartTime <= q.StartTime or x.EndTime >= q.EndTime ))

		SELECT @SpotProgramFileName = REPLACE(@SpotProgramFileName, '.txt', '.zip')
		UPDATE NLSNFTPLog
		SET [ProcessDT] = GETDATE(),
		[UnzipDT] = DATEADD(Minute, -1, GETDATE())
		WHERE FTPFileName = @SpotProgramFileName

		--select * from @NLSNSpotProgramSchedule
		--select * from NLSNSpotProgramSchedule

		COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSNProcessSpotProgramFileData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;