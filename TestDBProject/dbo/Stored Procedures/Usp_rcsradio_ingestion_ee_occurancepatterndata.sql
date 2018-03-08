-- =============================================      
-- Author:    Govardhan.R      
-- Create date: 04/07/2015      
-- Description:  Process RCS Ingestion Process      
-- Query : exec Usp_rcsradio_ingestion_ee_occurancepatterndata '2485','3/13/2015 8:25:41 PM','3/13/2015 8:25:55 PM','340868146','M2209601-20223710','2161525','308','15616141427','Compare Foods','EE'      
-- =============================================      
CREATE PROCEDURE [dbo].[Usp_rcsradio_ingestion_ee_occurancepatterndata] ( 
@STATION_ID            AS INT, 
@START_TIME            AS DATETIME, 
@END_TIME              AS DATETIME, 
@AIRCHECK_ID           AS BIGINT, 
@CREATIVEID            AS VARCHAR(255), 
@PAID                  AS INT, 
@CLASSID               AS INT, 
@SEQUENCE_ID           AS BIGINT, 
@AccountName           AS VARCHAR(255), 
@ACIDCreativeIDUseCase AS CHAR(2)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @AccountID             AS INT, 
                  @AdvMap                AS BIT, 
                  @AccountMap            AS BIT, 
                  @ClassMap              AS BIT, 
                  @OldRcsAccountId       AS INT, 
                  @OldRcsAdvertiserId    AS INT, 
                  @OldRcsClassId         AS INT, 
                  @PatterMasterStagingID AS INT, 
                  @AutoIndexing          AS BIT,
                  @RadioLanguageID       AS INT, 
                  @AdvMapAutoIndexFlag     AS BIT, 
                  @AccountMapAutoIndexFlag AS BIT, 
                  @AutoIndexFlag           AS BIT, 
                  @WWTRulePassed           AS BIT  

          SELECT @RadioLanguageID = [LanguageID] 
          FROM   radiostation 
          WHERE  rcsstationid = @STATION_ID; 

          SELECT @AccountID = [RCSAcctID] 
          FROM   [RCSAcct] 
          WHERE  RCSAcct.Name = @AccountName 

          SELECT @OldRcsAccountId = RCSAcctID 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @CREATIVEID 

          SELECT @OldRcsAdvertiserId = @OldRcsAdvertiserId 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @CREATIVEID 

          SELECT @OldRcsClassId = rcsclassid 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @CREATIVEID 

          --Insert the data to OCCURRENCEDETAILSRA table.    
          INSERT INTO [OccurrenceDetailRA] 
                      ([RCSAcIdID], 
                       [AirDT], 
                       [RCSStationID], 
                       liveread, 
                       [RCSSequenceID], 
                       [AirStartDT], 
                       [AirEndDT],
					   [Deleted], 
                       [CreatedDT], 
                       [CreatedByID]) 
          VALUES      (@AIRCHECK_ID, 
                       @START_TIME, 
                       @STATION_ID, 
                       0, 
                       @SEQUENCE_ID, 
                       @START_TIME, 
                       @END_TIME,
					   0, 
                       Getdate(), 
                       1) 

          --Get Autoindex values from Map tables.    
          SELECT @AdvMap = Isnull(priority, 0) 
          FROM   [dbo].[advertisermap] 
          WHERE  rcsadvertiserid = @PAID 
                 AND [Deleted] = 0 

          SELECT @AdvMapAutoIndexFlag = Isnull(autoindexing, 0) 
          FROM   [dbo].[advertisermap] 
          WHERE  rcsadvertiserid = @PAID 
                 AND [Deleted] = 0 

          SELECT @AccountMap = Isnull(priority, 0) 
          FROM   [dbo].accountmap 
          WHERE  rcsaccountid = @AccountID 
                 AND isdeleted = 0 

          SELECT @AccountMapAutoIndexFlag = Isnull(autoindexing, 0) 
          FROM   [dbo].accountmap 
          WHERE  rcsaccountid = @AccountID 
                 AND isdeleted = 0 

          SELECT @ClassMap = Isnull(priority, 0) 
          FROM   [dbo].[classmap] 
          WHERE  ClassMapID = @CLASSID 
                 AND isdeleted = 0 

           IF( ( @OldRcsAccountId != @AccountID ) 
               OR ( @OldRcsAdvertiserId != @PAID ) 
               OR ( @OldRcsClassId != @CLASSID ) ) 
            BEGIN 

			 SET @AutoIndexFlag=0; 
             SET @WWTRulePassed=0; 

                --Verify WWT Rules .       
          IF( ( @ClassMap = 1 ) 
               OR ( @AdvMap = 1 ) 
               OR ( @AccountMap = 1 ) ) 
            BEGIN 
                SET @AutoIndexFlag=0; 
                SET @WWTRulePassed=1; 
            END 
          ELSE IF ( ( @AdvMapAutoIndexFlag = 1 ) 
                OR ( @AccountMapAutoIndexFlag = 1 ) ) 
            BEGIN 
                SET @AutoIndexFlag=1; 
                SET @WWTRulePassed=1; 
            END 

          IF( @WWTRulePassed = 1 ) 
            BEGIN 
                --Insert data to Pattern Staging RA table.      
                INSERT INTO patternmasterstaging 
                            (priority, 
                             mediastream, 
                             status, 
                             autoindexing, 
                             creativeidacidusecase, 
                             createdtm, 
                             createby, 
                             languageid) 
                VALUES      (@AdvMap, 
                             'RA', 
                             'Valid', 
                             @AutoIndexFlag, 
                             @ACIDCreativeIDUseCase, 
                             Getdate(), 
                             1, 
                             @RadioLanguageID) 

                SELECT @PatterMasterStagingID = @@IDENTITY 

                --Insert data to PatternDetailRaStaging table.    
                INSERT INTO patterndetailrastaging 
                            (PatternStgID, 
                             rcscreativeid, 
                             createdDT, 
                             createdbyID) 
                VALUES      (@PatterMasterStagingID, 
                             @CREATIVEID, 
                             Getdate(), 
                             1) 
            END 

			   --This functionality is removed based on discussion by sherebyah on 04/22/2015 evening demo call.
                --IF( @IsWWTRulePassed = 0 ) 
                --  BEGIN 
                --      --UPDATE PATTERMASTER STATUS TO INVALID IF WWT RULES ARE FAILED. 
                --      UPDATE patternmaster 
                --      SET    status = 'INVALID' 
                --      FROM   patternmaster PM 
                --             INNER JOIN patterndetailra PD 
                --                     ON PD.patternmasterid = PM.patternmasterid 
                --      WHERE  PD.rcscreativeid = @CREATIVEID 
                --  END 
            END 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('Usp_rcsradio_ingestion_ee_occurancepatterndata: %d: %s',16 
                     ,1 
                     , 
                     @error,@message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;