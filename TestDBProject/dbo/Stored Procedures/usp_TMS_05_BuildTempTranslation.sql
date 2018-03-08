-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*

exec usp_TMS_05_BuildTempTranslation
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[usp_TMS_05_BuildTempTranslation] 
AS 
BEGIN 
SET NOCOUNT ON; 
	BEGIN TRY 
		BEGIN TRANSACTION 
			TRUNCATE TABLE TEMPTRANSLATION
			INSERT INTO TEMPTRANSLATION
			SELECT  ETHNIC_GROUP_ID,
					PROG_AIR_DT,
					ProgStartTime,
					PROG_TMS_CHANNEL,
					PROG_NAME,
					ProgDuration,
					PROG_SOURCE_TYPE,
					PROG_SYNDICATOR_ID,
					PROG_EPISODE_ID,
					PROG_EPISODE_NAME,
					DATEADD(SECOND, -1, DATEADD(MINUTE, ProgDuration, 
                                     CONVERT(TIME, 
                                     SUBSTRING(ProgStartTime, 0, 3) + 
                                     ':' 
                                     + SUBSTRING(ProgStartTime, 3, 3) 
                                                         + 'M')))        AS 
                 PROG_ENDTIME,
				 NULL,
				 NULL,
				 NULL 
				 FROM TMS_TRANSLATION

				 
				  --selecting the records which are before and after the brodcasting day  
          SELECT Recid=IDENTITY(bigint, 1, 1), 
                 ProgAirDT, 
                 ProgStartTime, 
                 ProgEpisodeID, 
                 ProgDuration, 
                 CONVERT(TIME, Substring(ProgStartTime, 0, 3) + ':' 
                               + Substring(ProgStartTime, 3, 3) + 'M') AS 
                 BrodcastTime, 
				 ProgEndDT 
          INTO   #temptmstranslation 
          FROM   TEMPTRANSLATION 
          WHERE  CONVERT(TIME, Substring(ProgStartTime, 0, 3) + ':' 
                               + Substring(ProgStartTime, 3, 3) + 'M') <= 
                        CONVERT(TIME, '05:59:59') 
                 AND Dateadd(second, -1, Dateadd(minute, ProgDuration, CONVERT( 
                                         TIME, 
                                         Substring(ProgStartTime 
                                         , 0, 3) 
                                         + 
                                         ':' 
                                                              + Substring 
                                         ( 
                                         ProgStartTime, 3, 3 
                                         ) + 
                                         'M'))) >= 
                     CONVERT(TIME, '06:00:00') 

          DECLARE @Count INT=1 
		  
          WHILE @Count <= (SELECT Count(recid) 
                           FROM   #temptmstranslation) 
            BEGIN 
                DECLARE @ProgAirDate DATETIME 
                DECLARE @ProgramStartTime VARCHAR(5) 
                DECLARE @EpisodeId VARCHAR(20) 
                DECLARE @BrodcastTime TIME 
                DECLARE @ProgramEndTime TIME 

                SELECT @ProgAirDate = prog_air_dt, 
                       @ProgramStartTime = ProgStartTime, 
                       @EpisodeId = prog_episode_id, 
                       @BrodcastTime = brodcasttime, 
                       @ProgramEndTime = PROG_ENDTIME 
                FROM   #temptmstranslation 
                WHERE  recid = @Count 

                DECLARE @Duration INT 
                DECLARE @NewDuration INT 

                SET @Duration = Datediff(minute, @BrodcastTime, CONVERT(TIME, 
                                '5:59:59')) 
                                + 1 
                SET @NewDuration=Datediff(minute, CONVERT(TIME, '6:00:00'), 
                                 @ProgramEndTime) 
                                 + 1 

                --Updating the duration for the existing record  
                UPDATE TEMPTRANSLATION 
                SET    ProgDuration = @Duration 
                WHERE  ProgAirDT = @ProgAirDate 
                       AND ProgStartTime = @ProgramStartTime 
                       AND ProgEpisodeID = @EpisodeId 

                SET @Count=@Count + 1 
            END    
			drop table #temptmstranslation
		COMMIT TRANSACTION 
		
	END try 

	BEGIN CATCH 
		DECLARE @error   INT, 
				@message VARCHAR(4000), 
				@lineNo  INT 

		SELECT @error = Error_number(), 
				@message = Error_message(), 
				@lineNo = Error_line() 

		RAISERROR ('usp_TMS_05_BuildTempTranslation: %d: %s',16,1,@error,@message,@lineNo); 

		ROLLBACK TRANSACTION 
	END CATCH; 
END;
