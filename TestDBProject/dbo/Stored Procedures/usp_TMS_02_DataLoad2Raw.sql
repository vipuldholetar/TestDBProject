
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*
drop procedure usp_TMS_02_DataLoad2Raw
exec usp_TMS_02_DataLoad2Raw 'D:\POCDemo\TMSData\sunday1.txt',1,3872
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[usp_TMS_02_DataLoad2Raw] (@TMSData  DBO.TMSData_Old READONLY, 
										@FilePath AS NVARCHAR(250), 
                                        @EthnicId AS INT,
										@RecCountInFile AS INT) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

	 INSERT INTO [dbo].[TMS_RAWDATA] 
                      ([PROG_AIR_DT], 
                       [PROG_START_TIME], 
                       [PROG_TMS_CHANNEL], 
                       [PROG_NAME], 
                       [PROG_DURATION], 
                       [PROG_SOURCE_TYPE], 
                       [PROG_SYNDICATOR_ID], 
                       [PROG_EPISODE_ID], 
                       [PROG_EPISODE_NAME]) 
          SELECT [PROG_AIR_DT], 
                       [PROG_START_TIME], 
                       [PROG_TMS_CHANNEL], 
                       [PROG_NAME], 
                       [PROG_DURATION], 
                       [PROG_SOURCE_TYPE], 
                       [PROG_SYNDICATOR_ID], 
                       [PROG_EPISODE_ID], 
                       [PROG_EPISODE_NAME]
          FROM   @TMSData 

	DECLARE @ImportedRecCount INT 
	-- getting the filename and recourd count to make a entry to transalation log table
	DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
	DECLARE @RecCount INT
	DECLARE @Airdate datetime 
	SELECT @RecCount= COUNT(1) ,@Airdate= (select top 1 PROG_AIR_DT)
	FROM TMS_RAWDATA  group by PROG_AIR_DT

	set @ImportedRecCount=@RecCount
	
	
	--Creating log entry in TMS log file
	INSERT INTO TMS_FILE_LOGS([FileName],FileRecordCount,AirDate, RawDataCount,TranslationImportCount,MTFinalCount,ProcessedDate)
	VALUES (@FileName,@RecCountInFile,@Airdate,@RecCount,0,0,GETDATE())

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

        RAISERROR ('usp_TMS_02_DataLoad2Raw: %d: %s',16,1,@error,@message,@lineNo); 

        ROLLBACK TRANSACTION 
    END catch; 
END;
