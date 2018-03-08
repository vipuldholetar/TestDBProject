-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Insert the csv file data to the db.  
-- Query :   
/* exec sp_ODRInsertCsvFileDataToDb '15648381142',  
*/ 
-- ================================================================================================================   
Create PROCEDURE [dbo].[sp_ODRInsertCsvFileDataToDb] (@ODRData 
dbo.ODRFtpSiteInventory readonly) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

		  --TRUNCATE TABLE FOR EVERY INSTANCE;
          TRUNCATE TABLE ftpsiteinventory; 

		  --INSERT DATA FROM CSV FILE;
          INSERT INTO ftpsiteinventory 
                      ([CMSFileName], 
                       cmsfilesize, 
                       cmssourcefolder, 
                       cmsfiledate) 
          SELECT pk_cmsfilename, 
                 cmsfilesize, 
                 cmssourcefolder, 
                 cmsfiledate 
          FROM   @ODRData; 

		  --INSERT DATA TO RAW TABLE FROM FTPSITEINVENTORY;
		  INSERT INTO CMSRAWDATA(CMSFileName,CMSFileSize,CMSFileDate,CMSSourceFolder,CMSAdvertiser,CMSMarket,CMSFormat,CMSLocation,CMSDatePictureTaken,IngestionStatus,[IngestionDT])

	        SELECT SI.[CMSFileName][FileName],SI.CMSFileSize[FileSize],CAST(SI.CMSFileDate AS DATE)[FileDate],SI.CMSSourceFolder,
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid' THEN dbo.ODRGetSplitStringByRowNo(SI.[CMSFileName],',',1)
				 END
			[CMSAdvertiser],
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid' THEN dbo.ODRGetSplitStringByRowNo(SI.[CMSFileName],',',2)
				 END
			[CMSMarket],
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid' THEN dbo.ODRGetSplitStringByRowNo(SI.[CMSFileName],',',3)
				 END
			[CMSFormat],
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid' THEN dbo.ODRGetSplitStringByRowNo(SI.[CMSFileName],',',4)
				 END
			[CMSLocation],
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid' THEN replace(dbo.ODRGetSplitStringByRowNo(SI.[CMSFileName],',',5),'.jpg','')
				 END
			[CMSDatePictureTaken],
			CASE WHEN DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Invalid'
				 THEN 'BADFILENAME'
			END
			[IngestionStatus],GETDATE()
			FROM FTPSITEINVENTORY SI
			LEFT OUTER JOIN CMSRAWDATA RD ON SI.[CMSFileName]=RD.CMSFILENAME
			--AND SI.CMSFILESIZE=RD.CMSFILESIZE AND CAST(SI.CMSFileDate AS DATE)=RD.CMSFILEDATE
			WHERE RD.CMSFILESIZE IS NULL and RD.CMSFILENAME IS NULL AND RD.CMSFILEDATE IS NULL

			--UPDATE FOR EXISTING RECORDS
			UPDATE RD 
			SET INGESTIONSTATUS=(CASE WHEN RD.CMSFILENAME IS NOT NULL AND (SI.CMSFILESIZE<>RD.CMSFILESIZE OR CAST(SI.CMSFileDate AS DATE)<>RD.CMSFILEDATE) AND DBO.ODRGetRawDataParseStatus(SI.[CMSFileName],',')='Valid'
				 THEN 'UPDATEDMEDIA'
			END),CMSFileSize=SI.CMSFileSize,CMSFileDate=CAST(SI.CMSFileDate AS DATE)
			FROM FTPSITEINVENTORY SI
			INNER JOIN CMSRAWDATA RD ON SI.[CMSFileName]=RD.CMSFILENAME
			--AND SI.CMSFILESIZE=RD.CMSFILESIZE AND CAST(SI.CMSFileDate AS DATE)=RD.CMSFILEDATE
			WHERE ((RD.CMSFILENAME=SI.[CMSFileName]) AND (SI.CMSFILESIZE<>RD.CMSFILESIZE OR CAST(SI.CMSFileDate AS DATE)<>RD.CMSFILEDATE))

          SELECT Count(*)[ImportedRecCount] 
          FROM   ftpsiteinventory 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_ODRInsertCsvFileDataToDb: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
