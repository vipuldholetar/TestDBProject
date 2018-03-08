
-- ============================================= 
-- Author:    Nagarjuna 
-- Create date: 04/20/2015 
-- Description:  RCS Auto Indexing for "NE" usecase
-- Query : exec [sp_RCSAutoIndexingNE]
-- ============================================= 

CREATE PROCEDURE [sp_RCSAutoIndexingNE] (@CreativeMasterStgId INT, 
                                                 @PatternMasterStgId  INT, 
                                                 @AutoIndexing            BIT,
												 @CustomMessage		VARCHAR(100) OUTPUT)
AS 
  BEGIN 
      DECLARE @Trans INT; 
      SET nocount ON; 

      BEGIN try          

          DECLARE @CreativeMasterId     INT, 
                  @PatterMasterId       INT, 
                  @Status               VARCHAR(max), 
                  @RCSCreativeId        VARCHAR(50), 
                  @AdvId         INT, 
                  @MediaStreamStage     VARCHAR(50), 
                  @MediaStream          INT, 
                  @OccrncId         INT, 
                  @RowCount             AS INT=0, 
                  @RCSAdvId      INT, 
                  @PrimaryOccrncId  INT, 
                  @TotalOccrncCount INT, 
                  @RCSAcctId         INT, 
                  @AdId                 INT, 
                  @NumberRecords        INT, 
                  @LastRunDate           DATETIME 
		  
		  SET @Trans = @@TRANCOUNT 

          IF @Trans = 0 
            BEGIN 
                BEGIN TRANSACTION 
            END 

          --Index the Ad to CreativeSignature       
          DECLARE @TempOccrncForCreativeSignature TABLE 
		    ( 
               RowId        INT IdENTITY(1, 1), 
               OccrncId INT, 
               AirStartTime DATETIME 
            ) 

          -- Get RCSCreativeId, RCSAdvId      
          SELECT @RCSCreativeId = [RCSCreativeID] 
          FROM   [PatternDetailRAStaging] 
          WHERE  [PatternStgID] = @PatternMasterStgId 

          SELECT @RCSAcctId = [RCSAcctID] 
          FROM   [RCSCreative] 
          WHERE  [RCSCreativeID] = @RCSCreativeId 

          SELECT @AdvId = [AdvID] 
          FROM   AcctMap 
          WHERE  [RCSAcctID] = @RCSAcctId 

          PRINT( 'RCSAcctId-  ' 
                 + Cast(@RCSAcctId AS VARCHAR) ) 

          PRINT( 'AdvId-  ' 
                 + Cast(@AdvId AS VARCHAR) ) 

          PRINT( 'RCSCreativeId-  ' + @RCSCreativeId ) 

          --Insert Occrnc details in @TempOccrncForCreativeSignature table    
          INSERT INTO @TempOccrncForCreativeSignature 
          SELECT [OccurrenceDetailRAID], 
                 [AirStartDT] 
          FROM   [OccurrenceDetailRA] 
                 INNER JOIN RCSAcIdToRCSCreativeIdMap 
                         ON RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID] = 
                            [OccurrenceDetailRA].[RCSAcIdID] 
                 INNER JOIN [RCSCreative] 
                         ON [RCSCreative].[RCSCreativeID] = 
                            RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID] 
                            AND [RCSCreative].[RCSCreativeID] = @RCSCreativeId 

          --select * from @TempOccrncForCreativeSignature      
          SELECT @NumberRecords = Count(*) 
          FROM   @TempOccrncForCreativeSignature 

          PRINT( 'Total Ocuurrences:- ' 
                 + Cast(@NumberRecords AS VARCHAR) ) 

          SELECT @LastRunDate = Max(AirStartTime) 
          FROM   @TempOccrncForCreativeSignature 

          SELECT @MediaStreamStage = MediaStream 
          FROM   [PatternStaging] 
          WHERE  [CreativeStgID] = @CreativeMasterStgId 

          SELECT @MediaStream = configId 
          FROM   ConfigMaster 
          WHERE  SystemName = 'All' 
                 AND ComponentName = 'MediaStream' 
                 AND Value = @MediaStreamStage 

          IF( @AdvId IS NOT NULL ) 
            BEGIN 
                --Insert new record into Ad table      
                INSERT INTO Ad 
                            ([OriginalAdID], 
                             [PrimaryOccurrenceID], 
                             [AdvertiserID], 
                             [LanguageID], 
                             Unclassified) 
                VALUES      ( NULL, 
                              NULL, 
                              @AdvId, 
                              (SELECT [LanguageID] 
                               FROM   [PatternStaging] 
                               WHERE  [PatternStagingID] = 
                                      @PatternMasterStgId 
                              ), 
                              1 ) 

                SELECT @AdId = Scope_Identity() 

                INSERT INTO [Pattern] 
                            ([CreativeID], 
                             [AdID], 
                             MediaStream, 
                             [Exception], 
                             [Priority], 
                             [Status]) 
                VALUES      ( NULL, 
                              @AdId, 
                              @MediaStream, 
                              NULL, 
                              (SELECT [Priority] 
                               FROM   [PatternStaging] 
                               WHERE  [PatternStagingID] = 
                                      @PatternMasterStgId 
                              ), 
                              'ValId' ) 

                SET @PatterMasterId =Scope_Identity() 

                INSERT INTO PatternDetailRa 
                            ([PatternID], 
                             [RCSCreativeID]) 
                VALUES      ( @PatterMasterId, 
                              @RCSCreativeId ) 

                --Insert new record into CreativeMaster table    
                INSERT INTO [Creative] 
                            ([AdId], 
                             [SourceOccurrenceId], 
                             EnvelopId, 
                             PrimaryIndicator) 
                VALUES      ( @AdId, 
                              NULL, 
                              NULL, 
                              0 ) 

                SET @CreativeMasterId =Scope_Identity() 

                --Update CreativeMasterId in PatternMaster table    
                UPDATE [Pattern] 
                SET    [CreativeID] = @CreativeMasterId 
                WHERE  [PatternID] = @PatterMasterId 

                --Insert new record into CreativeDetailRA table    
                INSERT INTO [CreativeDetailRA] 
                            ([CreativeID], 
                             AssetName, 
                             Rep, 
                             LegacyAssetName, 
                             FileType) 
                SELECT @CreativeMasterId, 
                       MediaFileName, 
                       MediaFilePath, 
                       '', 
                       MediaFormat 
                FROM   [CreativeDetailStagingRA] 
                WHERE  [CreativeStgID] = @CreativeMasterStgId 

                SET @RowCount = 1 

                WHILE @RowCount <= @NumberRecords 
                  BEGIN 
                      --- Get OccrncId's from Temporary table       
                      SELECT @OccrncId = [OccrncId] 
                      FROM   @TempOccrncForCreativeSignature 
                      WHERE  RowId = @RowCount 

                      PRINT( 'OccrncId-' 
                             + Cast(@OccrncId AS VARCHAR) ) 

                      --Update OccuranceDetailsRA with PatternId  
                      UPDATE [OccurrenceDetailRA] 
                      SET    [PatternID] = @PatterMasterId, 
                             [AdID] = @AdId 
                      WHERE  [OccurrenceDetailRAID] = @OccrncId 

                      SET @RowCount=@RowCount + 1 
                  END 

                --Remove record from PatternDetailsRAStg and CreativeDetailsRAStg which are moved to PatternMaster and CreativeMaster
                --PRINT ('CreativeMasterStgId -'+cast(@creativemasterStgId as varchar))    
                DELETE FROM [PatternDetailRAStaging] WHERE [PatternStgID] in   (select [PatternStagingID]   FROM   [PatternStaging] 
                WHERE  [CreativeStgID] = @creativemasterStgId )    
                DELETE FROM [PatternStaging] WHERE [CreativeStgID] = @CreativeMasterStgId        
                DELETE FROM [CreativeDetailStagingRA] WHERE [CreativeStgID] = @CreativeMasterStgId       
                DELETE FROM [CreativeStaging] WHERE [CreativeStagingID] = @CreativeMasterStgId   
                SELECT @PrimaryOccrncId = Min(OccrncId) 
                FROM   @TempOccrncForCreativeSignature 

                PRINT ( 'primaryOccrncId-' 
                        + Cast(@PrimaryOccrncId AS VARCHAR) ) 

                UPDATE [Creative] 
                SET    PrimaryIndicator = 1, 
                       [SourceOccurrenceId] = @PrimaryOccrncId 
                WHERE  [AdId] = @AdId 

                --Update AD table with primaryOccrnc    
                UPDATE Ad 
                SET    [PrimaryOccurrenceID] = @PrimaryOccrncId 
                WHERE  [AdID] = @AdId 
                       AND [PrimaryOccurrenceID] IS NULL 

                SET @CustomMessage = 'Success' 
            END 
          ELSE 
            BEGIN 
                SET @CustomMessage = 
      'There is no mapping between RCSAdvId and MCAPAdvId' 
            END 
		IF @Trans = 0
		BEGIN
          COMMIT TRANSACTION 
		  END
      END try 

      BEGIN catch 

          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 
		  IF Xact_state() <> 0 
             AND @Trans = 0 
            BEGIN 
                ROLLBACK TRANSACTION; 
            END; 

			
          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          SELECT @CustomMessage = @Message          
      END catch; 
  END;