-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/09/2015   
-- Description:  Insert the occurences and patterns.  
-- Query :   
/* exec Usp_ODRInsertOccrncNPatterns 
*/ 
-- ================================================================================================================   
CREATE PROCEDURE [dbo].[Usp_ODRInsertOccrncNPatterns]
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

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
		    INSERT INTO [OccurrenceDetailODR]([MTMarketID],[AdFormatID],ImageFileName,SourceFTPFolder,[CMSImageDT],CMSImageSize,Advertiser,DisplayLocation,DatePictureTaken,FileSource,FileSourceType,WorkType,[CreatedDT])
			SELECT DBO.ODRGetMarketMapId(RD.CMSMARKET)[MARKET],DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)[FORMAT],
			RD.CMSFileName,RD.CMSSOURCEFOLDER,RD.CMSFILEDATE,RD.CMSFILESIZE,
			CMSAdvertiser,
			CMSLocation,
			CMSDatePictureTaken ,
			'CMS'[FileSource],
			'.JPG'[FileSourceType],
			'INGESTION',
			GETDATE()
			FROM 
			CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(RD.CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)<>'UnmappedFormat'

			--INSERT PATTERNS
			INSERT INTO [PatternStaging]([CreativeSignature],[CreatedDT],[CreatedByID])
			SELECT RD.CMSFileName,GETDATE(),1
			FROM 
			CMSRAWDATA RD
			WHERE INGESTIONSTATUS IS NULL
			AND DBO.ODRGetMarketMapId(RD.CMSMARKET)<>'UnmappedMarket'
			AND DBO.ODRGetSourceFormatMapId(RD.CMSFORMAT)<>'UnmappedFormat'
			
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

          RAISERROR ('Usp_ODRInsertOccrncNPatterns: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;