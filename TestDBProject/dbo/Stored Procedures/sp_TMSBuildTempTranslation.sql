

-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 11/14/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*

exec sp_TMSBuildTempTranslation
 
*/
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_TMSBuildTempTranslation] 
AS 
BEGIN 
SET NOCOUNT ON; 
	BEGIN TRY 
		BEGIN TRANSACTION 
			TRUNCATE TABLE [TempTranslation]
			INSERT INTO [TempTranslation]
			SELECT  [EthnicGrpID],
					[ProgAirDT],
					[ProgStartTime],
					[ProgTMSChannel], 
					[ProgName],
					[ProgDuration],
					[ProgSrcType],
					[ProgSyndicatorID],
					[ProgEpisodeID],
					[ProgEpisodeName],			
					DATEADD(SECOND, -1, DATEADD(MINUTE, [ProgDuration], 
                                     CONVERT(TIME, 
                                     SUBSTRING([ProgStartTime], 0, 3) + 
                                     ':' 
                                     + SUBSTRING([ProgStartTime], 3, 3) 
                                                         + 'M')))        AS 
                 Prog_EndTime,
				 NULL,
				 NULL,
				 NULL 
				 FROM [TMSTranslation]

				 
				  --selecting the records which are before and after the brodcasting day  
          SELECT RecId=IDENTITY(bigint, 1, 1), 
                 [ProgAirDT], 
                 [ProgStartTime], 
                 [ProgEpisodeID], 
                 [ProgDuration], 
                 CONVERT(TIME, Substring([ProgStartTime], 0, 3) + ':' 
                               + Substring([ProgStartTime], 3, 3) + 'M') AS 
                 BrodcastTime, 
				 [ProgEndDT] 
          INTO   #TempTMSTranslation 
          FROM   [TempTranslation] 
          WHERE  CONVERT(TIME, Substring([ProgStartTime], 0, 3) + ':' 
                               + Substring([ProgStartTime], 3, 3) + 'M') <= 
                        CONVERT(TIME, '05:59:59') 
                 AND Dateadd(second, -1, Dateadd(minute, [ProgDuration], CONVERT( 
                                         TIME, 
                                         Substring([ProgStartTime] 
                                         , 0, 3) 
                                         + 
                                         ':' 
                                                              + Substring 
                                         ( 
                                         [ProgStartTime], 3, 3 
                                         ) + 
                                         'M'))) >= 
                     CONVERT(TIME, '06:00:00') 

          DECLARE @Count INT=1 
		  
          WHILE @Count <= (SELECT Count(RecId) 
                           FROM   #TempTMSTranslation) 
            BEGIN 
                DECLARE @ProgAirDate DATETIME 
                DECLARE @ProgramStartTime VARCHAR(5) 
                DECLARE @EpisodeId VARCHAR(20) 
                DECLARE @BrodcastTime TIME 
                DECLARE @ProgramEndTime TIME 

                SELECT @ProgAirDate = [ProgAirDT], 
                       @ProgramStartTime = [ProgStartTime], 
                       @EpisodeId = [ProgEpisodeID], 
                       @BrodcastTime = brodcasttime, 
                       @ProgramEndTime = [ProgEndDT] 
                FROM   #TempTMSTranslation 
                WHERE  RecId = @Count 

                DECLARE @Duration INT 
                DECLARE @NewDuration INT 

                SET @Duration = Datediff(minute, @BrodcastTime, CONVERT(TIME, 
                                '5:59:59')) 
                                + 1 
                SET @NewDuration=Datediff(minute, CONVERT(TIME, '6:00:00'), 
                                 @ProgramEndTime) 
                                 + 1 

                --Updating the duration for the existing record  
                UPDATE [TempTranslation] 
                SET    [ProgDuration] = @Duration 
                WHERE  [ProgAirDT] = @ProgAirDate 
                       AND [ProgStartTime] = @ProgramStartTime 
                       AND [ProgEpisodeID] = @EpisodeId 

                SET @Count=@Count + 1 
            END    
			drop table #TempTMSTranslation
		COMMIT TRANSACTION 
		
	END try 

	BEGIN CATCH 
		DECLARE @Error   INT, 
				@Message VARCHAR(4000), 
				@LineNo  INT 

		SELECT @Error = Error_number(), 
				@Message = Error_message(), 
				@LineNo = Error_line() 

		RAISERROR ('sp_TMSBuildTempTranslation: %d: %s',16,1,@Error,@Message,@LineNo); 

		ROLLBACK TRANSACTION 
	END CATCH; 
END;
