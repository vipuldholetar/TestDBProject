-- =============================================       
-- Author:    Govardhan.R       
-- Create date: 04/07/2015       
-- Description:  Process RCS Ingestion Process       
-- Query : exec usp_RCSRadio_Ingestion_EN_OccurancePatternData       
-- =============================================       
CREATE PROCEDURE [dbo].[Usp_rcsradio_ingestion_en_occurancepatterndata] ( 
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

          DECLARE @AccountID               AS INT, 
                  @AdvMap                  AS BIT, 
                  @AccountMap              AS BIT, 
                  @ClassMap                AS BIT, 
                  @OldRcsAccountId         AS INT, 
                  @OldRcsAdvertiserId      AS INT, 
                  @OldRcsClassId           AS INT, 
                  @OldCreativeId           AS VARCHAR(255), 
                  @OldPriority             AS BIT, 
                  @PatterMasterStagingID   AS INT, 
                  @AutoIndexing            AS BIT, 
                  @RadioLanguageID         AS INT, 
                  @AdvMapAutoIndexFlag     AS BIT, 
                  @AccountMapAutoIndexFlag AS BIT, 
                  @AutoIndexFlag           AS BIT, 
                  @WWTRulePassed           AS BIT 

          SELECT @RadioLanguageID = [LanguageID] 
          FROM   radiostation 
          WHERE  rcsstationid = @STATION_ID; 

          SELECT @AccountID = [RCSAcctID] 
          FROM   [RCSAcct] 
          WHERE  Name = @AccountName 

          SELECT @OldCreativeId = [RCSCreativeID] 
          FROM   rcsacidtorcscreativeidmap 
          WHERE  RCSAcIdToRCSCreativeIdMapID = @AIRCHECK_ID 
                 AND [Deleted] = 0 

          SELECT @OldRcsAccountId = RCSAcctID 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @OldCreativeId 

          SELECT @OldRcsAdvertiserId = RCSAdvID 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @OldCreativeId 

          SELECT @OldRcsClassId = rcsclassid 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @OldCreativeId 

          SELECT @OldPriority = priority 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @OldCreativeId 

          --Insert the data to RCSCreatives table.     
          INSERT INTO [RCSCreative] 
                      (rcscreativeid, 
                       RCSAcctID, 
                       RCSAdvID, 
                       rcsclassid, 
                       [Deleted], 
                       RCSSeqForCreation, 
                       CreatedDT, 
                       [CreatedByID]) 
          VALUES      (@CREATIVEID, 
                       @AccountID, 
                       @PAID, 
                       @CLASSID, 
                       0, 
                       @SEQUENCE_ID, 
                       Getdate(), 
                       1) 

          --Update the data to RCSACIDTORCSCREATIVEIDMAP table.     
          UPDATE rcsacidtorcscreativeidmap 
          SET    [RCSCreativeID] = @CREATIVEID, 
                 rcsupdateSeq = @SEQUENCE_ID, 
                 modifiedDT = Getdate(), 
                 [ModifiedByID] = 1 
          WHERE  RCSAcIdToRCSCreativeIdMapID = @AIRCHECK_ID 
                 AND [Deleted] = 0 

          --Insert the data to RCSIDReMapLog table.     
          INSERT INTO rcsidremaplog 
                      ([RCSOldCreativeID], 
                       [RCSNewCreativeID], 
                       [RCSOldAircheckID], 
                       [RCSNewAircheckID], 
                       [RCSOldClassID], 
                       [RCSNewClassID], 
                       [RCSOldAccountID], 
                       [RCSNewAccountID], 
                       RCSOldAdvID, 
                       RCSNewAdvID, 
                       [RCSOldStationID], 
                       [RCSNewStationID], 
                       oldpriority, 
                       newpriority, 
                       rcsseq, 
                       createdDT) 
          VALUES      (@OldCreativeId, 
                       @CREATIVEID, 
                       @AIRCHECK_ID, 
                       @AIRCHECK_ID, 
                       @OldRcsClassId, 
                       @CLASSID, 
                       @OldRcsAccountId, 
                       @AccountID, 
                       @OldRcsAdvertiserId, 
                       @PAID, 
                       NULL, 
                       NULL, 
                       Isnull(@OldPriority, 0), 
                       0, 
                       @SEQUENCE_ID, 
                       Getdate()) 

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
                             createdDt, 
                             createdbyID) 
                VALUES      (@PatterMasterStagingID, 
                             @CREATIVEID, 
                             Getdate(), 
                             1) 
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

          RAISERROR ('usp_RCSRadio_Ingestion_EN_OccurancePatternData: %d: %s',16 
                     ,1 
                     , 
                     @error,@message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;