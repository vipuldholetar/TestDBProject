-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/09/2015   
-- Description:  Insert the occurences and patterns.  
-- Query :   
/* exec sp_ODRInsertOccrncNPatterns 
*/ 
-- ================================================================================================================   
CREATE PROCEDURE [dbo].[sp_ODRInsertOccrncNPatterns]
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 
		   declare @worktype as int;
		   declare @mediaStreamId as int;

		   set @worktype=(select value from [Configuration] where componentname='WorkType' and systemName='All' and ValueTitle='Ingestion');

		   select @mediaStreamId = ConfigurationId from [Configuration] where ComponentName = 'Media Stream' and value = 'OD';
		   
		  --UPDATE RAW DATA FOR UNMAPPED MARKET AND FORMAT.
			UPDATE RD 
			SET INGESTIONSTATUS=
			CASE WHEN DBO.ODRGetMarketMapId(RD.CMSMARKET)='UnmappedMarket' THEN 'UnmappedMarket'
				 WHEN DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)='UnmappedFormat' THEN 'UnmappedFormat'
			END
			FROM CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND (DBO.ODRGetMarketMapId(RD.CMSMARKET)='UnmappedMarket'
			OR DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)='UnmappedFormat');

		    --INSERT THE OCCURENCES DATA--
		    INSERT INTO [OccurrenceDetailODR]([PatternId], [MTMarketID],[AdFormatID],ImageFileName,SourceFTPFolder,[CMSImageDT],CMSImageSize,Advertiser,DisplayLocation,DatePictureTaken,FileSource,FileSourceType,WorkType,[CreatedDT])
			SELECT (Select PatternId from Pattern where CreativeSignature = RD.CMSFileName and MediaStream = @mediaStreamId),
			DBO.ODRGetMarketMapId(RD.CMSMARKET)[MARKET],DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)[FORMAT],
			RD.CMSFileName,RD.CMSSOURCEFOLDER,RD.CMSFILEDATE,RD.CMSFILESIZE,
			CMSAdvertiser,
			CMSLocation,
			CMSDatePictureTaken ,
			'CMS'[FileSource],
			'JPG'[FileSourceType],
			@worktype,
			GETDATE()
			FROM 
			CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(RD.CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)<>'UnmappedFormat'
			and not exists (select 1 from OccurrenceDetailODR where ImageFileName = RD.CMSFileName)

			--INSERT PATTERN
			INSERT INTO [Pattern]([CreativeSignature], [MediaStream],[Status], [CreateDate],[CreateBy],[Query],[Exception],[Priority], [AdvertiserNameSuggestion])
			SELECT RD.CMSFileName, @mediaStreamId,'Valid',GETDATE(),1,0,0, 1, RD.CMSAdvertiser
			FROM 
			CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(RD.CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)<>'UnmappedFormat'
			and not exists (select 1 from Pattern where CreativeSignature = RD.CMSFileName and MediaStream = @mediaStreamId)

			--INSERT PATTERN STAGING
			INSERT INTO [PatternStaging]([PatternId], [CreativeSignature], [MediaStream], [Status],[LanguageID],[CreatedDT],[CreatedByID],[Query],[Exception], [Priority], [AdvertiserNameSuggestion])
			SELECT (Select PatternId from Pattern where CreativeSignature = RD.CMSFileName and MediaStream = @mediaStreamId), RD.CMSFileName, @mediaStreamId,'Valid',1,GETDATE(),1,0,0, 1, RD.CMSAdvertiser
			FROM 
			CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(RD.CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)<>'UnmappedFormat'
			and exists (select 1 from Pattern where CreativeSignature = RD.CMSFileName and MediaStream = @mediaStreamId and [AdId] is null)
			and not exists (select 1 from PatternStaging where CreativeSignature = RD.CMSFileName and MediaStream = @mediaStreamId)

			update [OccurrenceDetailODR]
			set PatternId = (select PatternId from Pattern where CreativeSignature = ImageFileName and MediaStream = @mediaStreamId)
			where [CreatedDT] >= cast(getDate() as date)
			and PatternID is null
			
			--UPDATE INGESTION STATUS FOR INGESTED RECORDS.
			UPDATE
			CMSRAWDATA SET INGESTIONSTATUS='INGESTED'
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(CMSFORMAT)<>'UnmappedFormat'

            SELECT Count(*)[ImportedRecCount] 
            FROM   [PatternStaging] 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_ODRInsertOccrncNPatterns: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;