
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*

exec [usp_TMS_03_DataLoad2Translation] 'D:\POCDemo\TMSData\sunday1.txt'
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[usp_TMS_03_DataLoad2Translation] (@FilePath AS NVARCHAR(250)
                                      ) 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

		

	--Insert into Raw table before applying busssiness rules on TMS_TRANSLATION table
	INSERT INTO TMS_TRANSLATION(PROG_AIR_DT,PROG_START_TIME,PROG_TMS_CHANNEL,PROG_NAME,PROG_DURATION,PROG_SOURCE_TYPE,PROG_SYNDICATOR_ID,PROG_EPISODE_ID,PROG_EPISODE_NAME) 
	SELECT  PROG_AIR_DT,PROG_START_TIME,PROG_TMS_CHANNEL,PROG_NAME,PROG_DURATION,PROG_SOURCE_TYPE,PROG_SYNDICATOR_ID,PROG_EPISODE_ID,PROG_EPISODE_NAME 
	FROM  TMS_RAWDATA

   
	
	--Updating the Ethnic group id channel type and converting the program name to upper case   
   	UPDATE TMS_TRANSLATION
	SET ETHNIC_GROUP_ID =MTS.MT_ETHNIC_GROUP_ID,
	prog_name = UPPER(prog_name) 
	FROM TMS_TRANSLATION TT
	LEFT JOIN TMS_TV_STATION TS ON TS.TV_STATION_NAME=TT.PROG_TMS_CHANNEL
	LEFT JOIN STATION_MAP SM ON sm.TMS_STATION_ID=ts.TV_STATION_ID
	LEFT JOIN TV_STATIONS MTS ON MTS.MT_STATION_ID=SM.MT_STATION_ID

    DECLARE @ImportedRecCount INT 
	-- getting the filename and recourd count to make a entry to transalation log table
	DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
	DECLARE @RecCount INT
	DECLARE @Airdate datetime 
	SELECT @RecCount= COUNT(1) ,@Airdate= (select top 1 PROG_AIR_DT)
	FROM TMS_TRANSLATION  group by PROG_AIR_DT

	set @ImportedRecCount=@RecCount
	
	
	--Creating log entry in TMS log file
		UPDATE TMS_FILE_LOGS SET TranslationImportCount=@ImportedRecCount WHERE [FileName]=@FileName and AirDate=@Airdate
    COMMIT TRANSACTION 
	SELECT @ImportedRecCount as ImportedRecCount
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('usp_TMS_03_DataLoad2Translation: %d: %s',16,1,@error,@message,@lineNo); 

        ROLLBACK TRANSACTION 
    END catch; 
END;
