-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 04/20/2015   
-- Description:  RCS Auto Indexing for "NN" usecase  
-- Query : exec usp_RCSAUI_CASE_NN  
-- =============================================   
CREATE PROCEDURE [dbo].[usp_RCSAUI_CASE_NN] (@CreativeStagingID INT, 
                                            @PatternStagingID  INT, 
                                            @AutoIndexing            BIT, 
                                            @CustomMessage           VARCHAR(100) output) 
AS 
  BEGIN 
      DECLARE @trans INT; 
      SET nocount ON; 

      BEGIN try          

          DECLARE @CreativeMasterID     INT, 
                  @PatterMasterID       INT, 
                  @Status               VARCHAR(max), 
                  @RCSCreativeID        VARCHAR(50), 
                  @AdvertiserID         INT, 
                  @MediaStreamStage     VARCHAR(50), 
                  @MediaStream          INT, 
                  @OccurrenceID         INT, 
                  @RowCount             AS INT=0, 
                  @RCSAdvertiserID      INT, 
                  @primaryOccurrenceID  INT, 
                  @TotalOccurrenceCount INT, 
                  @RCSAccountID         INT, 
                  @AdID                 INT, 
                  @NumberRecords        INT, 
                  @LastRunDTM           DATETIME 
		  
		  SET @trans = @@TRANCOUNT 

          IF @trans = 0 
            BEGIN 
                BEGIN TRANSACTION 
            END 

          --Index the Ad to CreativeSignature       
          DECLARE @tempoccurencesforcreativesignature TABLE 
		    ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT, 
               airstarttime DATETIME 
            ) 

          -- Get RCSCreativeID, RCSAdvertiserID      
          SELECT @RCSCreativeID = rcscreativeid 
          FROM   patterndetailrastaging 
          WHERE  [PatternStgID] = @PatternStagingID 

          SELECT @RCSAccountID = RCSAcctID 
          FROM   [RCSCreative] 
          WHERE  rcscreativeid = @RCSCreativeID 

          SELECT @AdvertiserID = advertiserid 
          FROM   accountmap 
          WHERE  rcsaccountid = @RCSAccountID 

          PRINT( 'RCSAccountID-  ' 
                 + Cast(@RCSAccountID AS VARCHAR) ) 

          PRINT( 'AdvertiserID-  ' 
                 + Cast(@AdvertiserID AS VARCHAR) ) 

          PRINT( 'RCSCreativeID-  ' + @RCSCreativeID ) 

          --Insert Occurrence details in @tempoccurencesforcreativesignature table    
          INSERT INTO @tempoccurencesforcreativesignature 
          SELECT [OccurrenceDetailRAID], 
                 [AirStartDT] 
          FROM   [dbo].[OccurrenceDetailRA] 
                 INNER JOIN rcsacidtorcscreativeidmap 
                         ON rcsacidtorcscreativeidmap.RCSAcIdToRCSCreativeIdMapID = 
                            [OccurrenceDetailRA].[RCSAcIdID] 
                 INNER JOIN [RCSCreative] 
                         ON rcscreative.rcscreativeid = 
                            rcsacidtorcscreativeidmap.[RCSCreativeID] 
                            AND rcscreative.rcscreativeid = @RCSCreativeID 

          --select * from @tempoccurencesforcreativesignature      
          SELECT @NumberRecords = Count(*) 
          FROM   @tempoccurencesforcreativesignature 

          PRINT( 'Total Ocuurrences:- ' 
                 + Cast(@NumberRecords AS VARCHAR) ) 

          SELECT @LastRunDTM = Max(airstarttime) 
          FROM   @tempoccurencesforcreativesignature 

          SELECT @MediaStreamStage = mediastream 
          FROM   PatternStaging 
          WHERE  CreativeStgID = @CreativeStagingID 

          SELECT @MediaStream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'All' 
                 AND componentname = 'MediaStream' 
                 AND value = @MediaStreamStage 

          IF( @AdvertiserID IS NOT NULL ) 
            BEGIN 
                --Insert new record into Ad table      
                INSERT INTO ad 
                            ([OriginalAdID], 
                             [primaryoccurrenceid], 
                             [advertiserid], 
                             [LanguageID], 
                             [unclassified]) 
                VALUES      ( NULL, 
                              NULL, 
                              @AdvertiserID, 
                              (SELECT [LanguageID] 
                               FROM   PatternStaging 
                               WHERE  PatternStagingid = 
                                      @PatternStagingID 
                              ), 
                              1 ) 

                SELECT @AdID = Scope_identity() 

                INSERT INTO [Pattern] 
                            (CreativeID, 
                             [AdID], 
                             [mediastream], 
                             [Exception], 
                             [priority], 
                             [status]) 
                VALUES      ( NULL, 
                              @AdID, 
                              @MediaStream, 
                              NULL, 
                              (SELECT [priority] 
                               FROM   PatternStaging 
                               WHERE  PatternStagingid = 
                                      @PatternStagingID 
                              ), 
                              'Valid' ) 

                SET @PatterMasterID =Scope_identity() 

                INSERT INTO [patterndetailra] 
                            ([PatternID], 
                             [rcscreativeid]) 
                VALUES      ( @PatterMasterID, 
                              @RCSCreativeID ) 

                --Insert new record into CreativeMaster table    
                INSERT INTO [Creative] 
                            ([adid], 
                             [sourceoccurrenceid], 
                             [envelopid], 
                             [PrimaryIndicator]) 
                VALUES      ( @AdID, 
                              NULL, 
                              NULL, 
                              0 ) 

                SET @CreativeMasterID =Scope_identity() 

                --Update CreativeMasterID in PatternMaster table    
                UPDATE [Pattern] 
                SET    CreativeID = @CreativeMasterID 
                WHERE  PatternID = @PatterMasterID 

                --Insert new record into CreativeDetailRA table    
                INSERT INTO [creativedetailra] 
                            ([creativemasterid], 
                             [creativeassetname], 
                             [creativerepository], 
                             [legacycreativeassetname], 
                             [creativefiletype]) 
                SELECT @CreativeMasterID, 
                       [mediafilename], 
                       [mediafilepath], 
                       '', 
                       [mediaformat] 
                FROM   creativedetailsrastaging 
                WHERE  CreativeStagingID = @CreativeStagingID 

                SET @RowCount = 1 

                WHILE @RowCount <= @NumberRecords 
                  BEGIN 
                      --- Get OccurrenceID's from Temporary table       
                      SELECT @OccurrenceID = [occurrenceid] 
                      FROM   @tempoccurencesforcreativesignature 
                      WHERE  rowid = @RowCount 

                      PRINT( 'occurrenceid-' 
                             + Cast(@OccurrenceID AS VARCHAR) ) 

                      --Update OccuranceDetailsRA with PatternID  
                      UPDATE [OccurrenceDetailRA] 
                      SET    [PatternID] = @PatterMasterID, 
                             [AdID] = @AdID 
                      WHERE  [OccurrenceDetailRAID] = @OccurrenceID 

                      SET @RowCount=@rowcount + 1 
                  END 

                --Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster
                --PRINT ('CreativeStagingID -'+cast(@CreativeStagingID as varchar))    
                DELETE FROM PATTERNDETAILRASTAGING WHERE [PatternStgID] in   (select PatternStagingid   FROM   PatternStaging 
                WHERE  [CreativeStgID] = @CreativeStagingID )    
                DELETE FROM PatternStaging WHERE CreativeStgID = @CreativeStagingID        
                DELETE FROM CREATIVEDETAILSRASTAGING WHERE CreativeStagingID = @CreativeStagingID       
                DELETE FROM CREATIVESTAGING WHERE CreativeStagingID = @CreativeStagingID   
                SELECT @primaryOccurrenceID = Min(occurrenceid) 
                FROM   @tempoccurencesforcreativesignature 

                PRINT ( 'primaryoccurrenceid-' 
                        + Cast(@primaryOccurrenceID AS VARCHAR) ) 

                UPDATE [Creative] 
                SET    primaryindicator = 1, 
                       sourceoccurrenceid = @primaryOccurrenceID 
                WHERE  adid = @AdID 

                --Update AD table with primaryOccurrence    
                UPDATE ad 
                SET    primaryoccurrenceid = @primaryOccurrenceID 
                WHERE  adid = @AdID 
                       AND primaryoccurrenceid IS NULL 

                SET @CustomMessage = 'Success' 
            END 
          ELSE 
            BEGIN 
                SET @CustomMessage = 
      'There is no mapping between RCSAdvertiserID and MCAPAdvertiserID' 
            END 
		IF @trans = 0
		begin
          COMMIT TRANSACTION 
		  end
      END try 

      BEGIN catch 

          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
		  IF Xact_state() <> 0 
             AND @trans = 0 
            BEGIN 
                ROLLBACK TRANSACTION; 
            END; 

			
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          SELECT @CustomMessage = @message          
      END catch; 
  END;