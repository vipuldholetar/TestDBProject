
-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*

exec [sp_TMSDataLoad2Translation] 'D:\POCDemo\TMSData\sunday1.txt'
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_TMSDataLoad2Translation] (@FilePath AS NVARCHAR(250)) 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

		

	--Insert into Raw table before applying busssiness rules on TMS_TRANSLATION table
	INSERT INTO TMSTranslation([ProgAirDT],
	[ProgStartTime],
	[ProgTMSChannel],
	[ProgName],
	[ProgDuration],
	[ProgSrcType],
	[ProgSyndicatorID],
	[ProgEpisodeID],
	[ProgEpisodeName]) 
	SELECT  [ProgAirDT],
                       [ProgStartTime],
                       [ProgTMSChannel],
                       [ProgName],
                       [ProgDuration],
                       [ProgSrcType],
                       [ProgSyndicatorID], 
                       [ProgEpisodeID],
                       [ProgEpisodeName] 
	FROM  [TMSRawData]

   
	
	--Updating the Ethnic group id channel type and converting the program name to upper case   
   	UPDATE TMSTranslation
	SET [EthnicGrpID] =MTS.[EthnicGroupID],
	[ProgName] = UPPER([ProgName]) 
	FROM TMSTranslation TT
	LEFT JOIN [TMSTvStation] TS ON TS.TvStationName=TT.ProgTMSChannel
	LEFT JOIN [StationMapMaster] SM ON SM.[TMSStationID]=TS.[TMSTvStationID]
	LEFT JOIN [TVStation] MTS ON MTS.[TVStationID]=SM.[TVStationID]

    DECLARE @ImportedRecCount INT 
	-- getting the filename and recourd count to make a entry to transalation log table
	DECLARE @FileName VARCHAR(100)=SUBSTRING(@FilePath,LEN(@FilePath) - CHARINDEX('\', REVERSE(@FilePath)) + 2,LEN(@FilePath))
	DECLARE @RecCount INT
	DECLARE @Airdate datetime 
	SELECT @RecCount= COUNT(1) ,@Airdate= (select top 1 [ProgAirDT])
	FROM TMSTranslation  group by [ProgAirDT]

	set @ImportedRecCount=@RecCount
	
	
	--Creating log entry in TMS log file
		UPDATE [TMSFileLogs] SET TranslationImportCount=@ImportedRecCount WHERE [FileName]=@FileName and [AirDT]=@Airdate
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

        RAISERROR ('sp_TMSDataLoad2Translation: %d: %s',16,1,@Error,@Message,@LineNo); 

        ROLLBACK TRANSACTION 
    END catch; 
END;