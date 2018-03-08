
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*

exec sp_TMSDataLoad2Raw 'D:\POCDemo\TMSData\sunday1.txt',1,3872
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_TMSDataLoad2Raw] (@TMSData  DBO.TMSData READONLY, 
										@FilePath AS NVARCHAR(250), 
                                        @EthnicId AS INT,
										@RecCountInFile AS INT) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

	 INSERT INTO [dbo].[TMSRawData] 
                      ([ProgAirDT],
                       [ProgStartTime],
                       [ProgTMSChannel],
                       [ProgName],
                       [ProgDuration],
                       [ProgSrcType],
                       [ProgSyndicatorID], 
                       [ProgEpisodeID],
                       [ProgEpisodeName]) 
          SELECT [ProgAirDate],
                 [ProgStartTime],
                 [ProgTMSChannel],
                 [ProgName],
                 [ProgDuration],
                 [ProgSrcType],
                 [ProgSyndicatorId], 
                 [ProgEpisodeId],
                 [ProgEpisodeName]
          FROM   @TMSData 

	DECLARE @ImportedRecCount INT 
	-- getting the filename and recourd count to make a entry to transalation log table
	DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
	DECLARE @RecCount INT
	DECLARE @Airdate datetime 
	SELECT @RecCount= COUNT(1) ,@Airdate= (select top 1 [ProgAirDT])
	FROM [TMSRawData]  group by [ProgAirDT]

	set @ImportedRecCount=@RecCount
	
	
	--Creating log entry in TMS log file
	INSERT INTO [TMSFileLogs]([FileName],FileRecordCount,[AirDT], RawDataCount,TranslationImportCount,FinalCount,[ProcessedDT])
	VALUES (@FileName,@RecCountInFile,@Airdate,@RecCount,0,0,GETDATE())

    COMMIT TRANSACTION 
	SELECT @ImportedRecCount as ImportedRecCount
END try 

    BEGIN catch 
        DECLARE @Error   INT, 
                @Message VARCHAR(4000), 
                @LineNo  INT 

        SELECT @Error = Error_number(), 
               @Message = Error_message(), 
               @LineNo = Error_line() 

        RAISERROR ('sp_TMSDataLoad2Raw: %d: %s',16,1,@Error,@Message,@LineNo); 

        ROLLBACK TRANSACTION 
    END catch; 
END;
