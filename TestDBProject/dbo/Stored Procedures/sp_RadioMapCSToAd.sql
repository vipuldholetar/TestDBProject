

-- ============================================================================================================
-- Author			:  Arun Nair
-- Create date		: <04/15/2015 3:32:00 PM> 
-- Description		:  sp_RadioMapCSToAd 4192,'M2010322-20555818',0 
-- Updated By		: Arun Nair on 04/1//2015 
--					: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--					: Arun Nair on 08/11/2015 - CleanUp for OneMT
--					: Arun Nair On 09/02/2015 -Added CreateBy,Update CreativeSugnature in PatternMaster
--					  Arun Nair on 10/12/2015 - Append Description with MODReason
--					  RP on 10/13/2016 - Append Description with Description and RecutDetail
-- ============================================================================================================


CREATE PROCEDURE [dbo].[sp_RadioMapCSToAd]
(
      @AdID INT, 
	 @CreativeSignature NVARCHAR(MAX), 
	 @Description NVARCHAR(MAX)= '', 
	 @MTOReasonID INT= 0, 
	 @RecutDetail NVARCHAR(MAX)= '', 
	 @UserId AS INT
)
AS
     IF 1 = 0
         BEGIN
             SET FMTONLY OFF;
         END;
     BEGIN
         SET NOCOUNT ON;
         BEGIN TRY
             BEGIN TRANSACTION;
             DECLARE @OccurrenceID AS INT= 0;
             DECLARE @CreativeMasterID AS INT= 0;
             DECLARE @PatternMasterID AS INT= 0;
             DECLARE @CreativeStagingID AS INT= 0;
             DECLARE @MTOReason AS VARCHAR(100);
             DECLARE @NumberRecords AS INT= 0;
             DECLARE @RowCount AS INT= 0;
             DECLARE @MediaStream AS INT= 0;
             DECLARE @primaryOccurrenceID AS INTEGER;
             SELECT @mediastream = configurationid
             FROM [Configuration]
             WHERE systemname = 'ALL'
                   AND
                   componentname = 'media stream'
                   AND
                   valuetitle = 'Radio'; 



             -- PRINT( 'Mediastream - '+ Cast(@mediastream AS VARCHAR) ) 
             --Index the creative signature to ad 


             CREATE TABLE #tempoccurencesforcreativesignature
                                                             (
                          rowid INT IDENTITY(1, 1
                                            ), occurrenceid INT
                                                             );
             INSERT INTO #tempoccurencesforcreativesignature
                    SELECT [OccurrenceDetailRAID]
                    FROM [dbo].[OccurrenceDetailRA] INNER JOIN RCSAcIdToRCSCreativeIdMap ON RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID] =
                    [OccurrenceDetailRA].[RCSAcIdID]
                                                    INNER JOIN [RCSCreative] ON [RCSCreative].[RCSCreativeID] = RCSAcIdToRCSCreativeIdMap.
                                                    [RCSCreativeID]
                                                                                AND
                                                                                [RCSCreative].[RCSCreativeID] = @CreativeSignature;
             SELECT @primaryOccurrenceID = MIN(occurrenceid)
             FROM #tempoccurencesforcreativesignature; 



             --  PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 



             IF EXISTS
                      (
                       SELECT *
                       FROM [CreativeStaging] INNER JOIN [CreativeDetailStagingRA] ON [CreativeStaging].[CreativeStagingID] =
                       [CreativeDetailStagingRA].[CreativeStgID]
                       WHERE [OccurrenceID] = @primaryOccurrenceID
                      )
                 BEGIN 

                     --- Get data from [CREATIVEMASTER]  

                     INSERT INTO [Creative]
                                           ([AdId], [SourceOccurrenceId], CheckInOccrncs, PrimaryIndicator
                                           )
                            SELECT @ADID, @primaryOccurrenceID, 1, 0; 



                     --PRINT( 'creativemaster - inserted' ) 



                     SELECT @CreativeMasterID = SCOPE_IDENTITY(); 



                     --PRINT( 'creativemaster id-' + Cast(@CreativeMasterID AS VARCHAR) ) 
                     ---Get data from [CREATIVEMASTERSTAGING]  

                     SELECT @CreativeStagingID = [CreativeStaging].[CreativeStagingID]
                     FROM [CreativeStaging]
                     WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID;
                     INSERT INTO [CreativeDetailRA]
                                                   ([CreativeID], AssetName, Rep, LegacyAssetName, FileType
                                                   )
                            SELECT @CreativeMasterID, MediaFileName, MediaFilePath, '', MediaFormat
                            FROM [CreativeDetailStagingRA]
                            WHERE [CreativeStgID] = @CreativeStagingID; 

                     --PRINT ( 'creativedetailsra - inserted' ) 



                 END;

			  SELECT @PatternMasterID = p.PatternID  FROM [PatternStaging] p
			 WHERE CreativeSignature = @CreativeSignature

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
			 BEGIN
				INSERT INTO [Pattern]
				    ([CreativeID], [AdID], Priority, MediaStream, [Exception], ExceptionText, [Query], QueryCategory, QueryText,
				    QueryAnswer, TakeReasonCode, NoTakeReasonCode, Status, CreateBy, CreateDate, ModifiedBy, ModifyDate,
				    CreativeSignature,LastMappedDate,LastMapperInits
				    )
				SELECT @CreativeMasterID, @adid, priority, @MediaStream, [Exception], exceptiontext, [Query], querycategory, querytext,
				    queryanswer, [TakeReasonCODE], [NoTakeReasonCODE], status, @UserId, GETDATE(), NULL, NULL, @CreativeSignature,GetDate(),@UserId
				    FROM [PatternStaging] 
				    WHERE CreativeSignature = @CreativeSignature

				SET @PatternMasterID = SCOPE_IDENTITY(); 
			 END
			 ELSE
			 BEGIN 
				UPDATE p set p.CreativeID=@CreativeMasterID,AdID = @adid, [Priority] = ps.[priority], p.MediaStream = @MediaStream
				    ,[Exception] = ps.[Exception], ExceptionText = ps.exceptiontext, [Query] = ps.[Query], QueryCategory = ps.querycategory
				    ,QueryText = ps.querytext, QueryAnswer = ps.queryanswer, TakeReasonCode = ps.[TakeReasonCODE], 
				    NoTakeReasonCode = ps.NoTakeReasonCODE, [Status] = ps.[Status],ModifiedBy=@userID,ModifyDate=Getdate()
				    ,CreativeSignature = @CreativeSignature,LastMappedDate=GetDate(),LastMapperInits=@UserId
				FROM Pattern p INNER JOIN [PatternStaging] ps on p.PatternID = ps.PatternID
				    WHERE ps.PatternId = @PatternMasterID
			 END


             --PRINT( 'patternmaster - inserted' ) 





             --PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
             --PRINT( 'creative signature-' + @creativesignature ) 



             --INSERT INTO PatternDetailRA
             --                           ([PatternID], [RCSCreativeID]
             --                           )
             --VALUES
             --       (@PatternMasterID, @creativesignature
             --       ); 

             --print ('executed')

             SELECT @NumberRecords = COUNT(*)
             FROM #tempoccurencesforcreativesignature;
             --SET @RowCount = 1;
             --WHILE @RowCount <= @NumberRecords
             --    BEGIN 

             --        --- Get OccurrenceID's from Temporary table  

             --        SELECT @OccurrenceID = [occurrenceid]
             --        FROM #tempoccurencesforcreativesignature
             --        WHERE rowid = @RowCount; 

             --        --PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 
             --        ----Update PatternMasterID and Ad into OCCURRENCEDETAILSRA Table    

             --        UPDATE [dbo].[OccurrenceDetailRA]
             --               SET [PatternID] = @PatternMasterID, [AdID] = @AdID
             --        WHERE [OccurrenceDetailRAID] = @OccurrenceID;
             --        SET @RowCount = @rowcount + 1;
             --    END; 
		   UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
			 FROM [dbo].[OccurrenceDetailRA] a INNER JOIN #tempoccurencesforcreativesignature b on a.OccurrenceDetailRAID = b.occurrenceid
			 WHERE  [OccurrenceDetailRAID] = @OccurrenceID    

             --Remove record from PatternDetailRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster  

    --         DELETE FROM PatternDetailRAStaging
			 --WHERE [PatternStgID] IN
    --                                (
    --                                 SELECT [PatternStgID]
    --                                 FROM [PatternStaging]
    --                                 WHERE [CreativeStgID] = @CreativeStagingID
    --                                );
             DELETE FROM [PatternStaging]
			 WHERE [CreativeStgID] = @CreativeStagingID;
             DELETE FROM [CreativeDetailStagingRA]
			 WHERE [CreativeStgID] = @CreativeStagingID;
             DELETE FROM [CreativeStaging]
			 WHERE [CreativeStagingID] = @CreativeStagingID; 



             -- Update Occurrence in Ad Table  

             UPDATE Ad
                    SET @primaryOccurrenceID = [PrimaryOccurrenceID]
             WHERE Ad.[AdID] = @AdID
                   AND
                   [PrimaryOccurrenceID] IS NULL; 



             --- Mark RCS Creative as Deleted          

             UPDATE [RCSCreative]
                    SET [Deleted] = 1
             WHERE [RCSCreativeID] = @CreativeSignature;
             PRINT(@mtoreason);
             IF @Description <> ''
                 BEGIN
                     UPDATE Ad
                            SET description = description+','+@Description
                     WHERE [AdID] = @AdID;
                 END;
             IF @RecutDetail <> ''
                 BEGIN
                     UPDATE Ad
                            SET RecutDetail = recutdetail+','+@RecutDetail
                     WHERE [AdID] = @AdID;
                 END;
             IF NOT EXISTS
                          (
                           SELECT 1
                           FROM [Creative]
                           WHERE [Creative].[AdId] = @adid
                                 AND
                                 PrimaryIndicator = 1
                          )
                 BEGIN

                     -- updated creativemaster primary indicator

                     UPDATE [Creative]
                            SET PrimaryIndicator = 1
                     WHERE [Creative].[AdId] = @adid
                           AND
                           [Creative].[SourceOccurrenceId] = @primaryOccurrenceID;
                 END;
             DROP TABLE #tempoccurencesforcreativesignature;
             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             DECLARE @error INT, @message VARCHAR(4000), @lineNo INT;
             SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @lineNo = ERROR_LINE();
             RAISERROR
                      ('[sp_RadioMapCSToAd]: %d: %s', 16, 1, @error, @message, @lineNo
                      );
             ROLLBACK TRANSACTION;
         END CATCH;
     END;