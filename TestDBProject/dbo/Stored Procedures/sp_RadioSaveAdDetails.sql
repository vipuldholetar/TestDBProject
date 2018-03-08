-- ========================================================================================================================================================================================================
-- Author			: Arun Nair
-- Create date		: 
-- Description		: 
---EXEC				: [sp_RadioSaveAdDetails] '','','','',2074874,'',1,'01/01/2014','','','',12,'','','','',0,'sdfsd','01/01/2014','01/01/2014','','01/01/2014','01/01/2014','01/01/2014','M2251621-20713649','01/01/2014',0   
-- Updated By		: Ramesh on '08/11/2015'
--					: Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster,Delete Records From Staging 
--					: Karunakar on 17th Nov 2015,Returning Generated Ad ID Value
-- ======================================================================================================================================================================================================== 

CREATE PROCEDURE [dbo].[sp_RadioSaveAdDetails] 
(
@LeadAudioHeadline      AS NVARCHAR (max)='', 
@LeadText               AS NVARCHAR (max)='', 
@Visual                 AS NVARCHAR (max)='', 
@Description            AS NVARCHAR (max)='', 
@Advertiser             AS INT=0, 
@TagLineID              AS NVARCHAR (max)=Null, 
@LanguageID             AS INT=0, 
@CommondAdDate          AS DATETIME , 
@InternalNotes          AS NVARCHAR(max)='', 
@NotakeReason           AS INTEGER, 
@MediaStream            AS INT, 
@Length                 AS INT=0, 
@CreativeAssetQuality   AS INT, 
@TradeClass             AS NVARCHAR (max)='', 
@CoreSupplementalStatus AS NVARCHAR (max)='', 
@DistributionType       AS NVARCHAR (max)='', 
@OriginalADID           AS INT, 
@RevisionDetail         AS NVARCHAR (max)='', 
@FirstRunDate           AS DATETIME , 
@LastRunDate            AS DATETIME, 
@FirstRunDMA            AS NVARCHAR (max)='', 
@BreakDate              AS DATETIME , 
@StartDate              AS DATETIME, 
@EndDate                AS DATETIME , 
@CreativeSignature      AS NVARCHAR(max), 
@SessionDate            AS DATETIME , 
@isUnclassified         AS BIT,
@Userid					AS INT,
@originalAdDescription as nvarchar(max)= '',
@originalAdRecutDetail as nvarchar(max)= ''
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @ADID INT 
          DECLARE @OccurrenceID AS INT=0 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0 
          DECLARE @MTOReason AS VARCHAR(100) 
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
		   DECLARE @RunDMAID AS INT = NULL
		    

            If @TagLineID='' 
			set @TagLineID=null

					  IF @FirstRunDMA <> '' AND @FirstRunDMA IS NOT NULL
		  BEGIN
			 SELECT @RunDMAID = MarketID FROM Market 
				WHERE Descrip = @FirstRunDMA
		  END
		  --ELSE IF @ParentOccurrenceId > 0
		  --BEGIN
			 --SELECT @RunDMAID = market FROM  [dbo].[OccurrenceDetailRA] 
				--WHERE OccurrenceDetailRAID = @ParentOccurrenceId
		  --END 


          --Insert a New Ad  
          INSERT INTO [dbo].[Ad] 
                      ([OriginalAdID], 
                       [PrimaryOccurrenceID], 
                       [AdvertiserID], 
                       [BreakDT], 
                       [StartDT], 
                       [LanguageID], 
                       [FamilyID], 
                       [CommonAdDT], 
                       [FirstRunMarketID], 
                       [FirstRunDate], 
                       [LastRunDate], 
                       [AdName], 
                       [AdVisual], 
                       [AdInfo], 
                       [Coop1AdvId], 
                       [Coop2AdvId], 
                       [Coop3AdvId], 
                       [Comp1AdvId], 
                       [Comp2AdvId], 
                       [taglineid], 
                       [LeadText], 
                       [LeadAvHeadline], 
                       [RecutDetail], 
                       [RecutAdId], 
                       [EthnicFlag], 
                       [AddlInfo], 
                       [AdLength], 
                       [InternalNotes], 
                       [ProductId], 
                       [description], 
                       [notakeadreason], 
                       [SessionDate], 
                       [unclassified],CreateDate,CreatedBy) 
          VALUES      ( @OriginalADID, 
                        NULL, 
                        @Advertiser, 
                        @BreakDate, 
                        @StartDate, 
                        @LanguageID, 
                        NULL, 
                        @CommondAdDate, 
                        @RunDMAID, 
                        @FirstRunDate, 
                        @LastRunDate, 
                        NULL, 
                        @Visual, 
                        NULL, 
                        NULL, 
                        NULL, 
                        NULL, 
                        NULL, 
                        NULL, 
                        @TagLineID, 
                        @LeadText, 
                        @LeadAudioHeadline, 
                        @RevisionDetail, 
                        NULL, 
                        0, 
                        NULL, 
                        @Length, 
                        @InternalNotes, 
                        NULL, 
                        @Description, 
                        NULL, 
                        @SessionDate, 
                        @isUnclassified,getdate(),@Userid) 

          SELECT @adid = Scope_identity(); 

          --Index the Ad to CreativeSignature  
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT 
            ) 

          INSERT INTO #tempoccurencesforcreativesignature 

          SELECT [OccurrenceDetailRAID] FROM   [dbo].[OccurrenceDetailRA] 
          INNER JOIN RCSAcIdToRCSCreativeIdMap ON RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID] = [OccurrenceDetailRA].[RCSAcIdID] 
          INNER JOIN [RCSCreative] ON [RCSCreative].[RCSCreativeID] = RCSAcIdToRCSCreativeIdMap.[RCSCreativeID] 
          AND [RCSCreative].[RCSCreativeID] = @CreativeSignature 

          DECLARE @primaryOccurrenceID AS INTEGER 

          --SELECT @primaryOccurrenceID = Min(occurrenceid) 
          --FROM   #tempoccurencesforcreativesignature 
		  set @primaryOccurrenceID =(select dbo.fn_GetPrimaryOccurrenceId(@CreativeSignature))

		  
          --PRINT ( 'primaryoccurrenceid-'    + Cast(@primaryOccurrenceID AS VARCHAR) ) 

          IF EXISTS(SELECT * FROM   [CreativeStaging] inner join [CreativeDetailStagingRA] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID] WHERE  [OccurrenceID] = @primaryOccurrenceID) 
            BEGIN 
                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            ([AdId], 
                             [SourceOccurrenceId], 
                             CheckInOccrncs, 
                             PrimaryQuality, 
                             PrimaryIndicator) 
                SELECT @ADID, 
                       @primaryOccurrenceID, 
                       1, 
                       @CreativeAssetQuality, 
                       1 

                --PRINT( 'creativemaster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                --PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]  
                SELECT @CreativeStagingID = [CreativeStagingID] 
                FROM   [CreativeStaging] 
                WHERE  [CreativeStaging].[OccurrenceID] = 
                       @primaryOccurrenceID 
					   order by [CreativeStaging].[CreatedDT] asc

                INSERT INTO [CreativeDetailRA] 
                            ([CreativeID], 
                             AssetName, 
                             Rep, 
                             LegacyAssetName, 
                             FileType) 
                SELECT @CreativeMasterID, MediaFileName,  MediaFilePath, '', MediaFormat FROM   [CreativeDetailStagingRA] 
                WHERE  [CreativeStgID] = @CreativeStagingID 

                --PRINT ( 'creativedetailsra - inserted' ) 
            END 

		  SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
		  --INNER JOIN PatternDetailRAStaging pds ON ps.[PatternStagingID] =  pds.[PatternStgID] 
		    WHERE  ps.CreativeSignature = @CreativeSignature 

		  IF @PatternMasterID IS NULL OR @PatternMasterID = 0
		  BEGIN
			 INSERT INTO [Pattern] 
                      ([CreativeID], 
                       [AdID], 
                       Priority, 
                       MediaStream, 
                       [Exception], 
                       ExceptionText, 
                       [Query], 
                       QueryCategory, 
                       QueryText, 
                       QueryAnswer, 
                       TakeReasonCode, 
                       NoTakeReasonCode, 
                       Status, 
					   CreateBy,
                       CreateDate,
					   ModifiedBy,
                       ModifyDate,
					   CreativeSignature) 

			 SELECT @CreativeMasterID, 
				 @adid, 
				 priority, 
				 @MediaStream, 
				 [Exception], 
				 exceptiontext, 
				 [Query], 
				 querycategory, 
				 querytext, 
				 queryanswer, 
				 [TakeReasonCODE], 
				 [NoTakeReasonCODE], 
				 status, 
					@Userid,
				 Getdate(), 
					NULL,
				 NULL,
					@CreativeSignature
			   FROM   [PatternStaging]-- INNER JOIN PatternDetailRAStaging pds
				--ON [PatternStaging].[PatternStagingID] =  pds.[PatternStgID] 
			   WHERE  CreativeSignature = @CreativeSignature 

			 PRINT( 'patternmaster - inserted' ) 
			 SET @PatternMasterID=Scope_identity(); 
		  END
		  ELSE
		  BEGIN
			 UPDATE p set p.CreativeID=@CreativeMasterID,AdID = @adid, [Priority] = ps.[priority], p.MediaStream = @MediaStream
				,[Exception] = ps.[Exception], ExceptionText = ps.exceptiontext, [Query] = ps.[Query], QueryCategory = ps.querycategory
				,QueryText = ps.querytext, QueryAnswer = ps.queryanswer, TakeReasonCode = ps.[TakeReasonCODE], 
				NoTakeReasonCode = @NoTakeReason, [Status] = ps.[Status], CreateBy = @UserId, CreateDate = GETDATE()
				,CreativeSignature = @CreativeSignature
			 FROM Pattern p INNER JOIN [PatternStaging] ps on p.PatternID = ps.PatternID
			 WHERE ps.PatternId = @PatternMasterID
		  END


          --PRINT( 'patternmasterid-'  + Cast(@PatternMasterID AS VARCHAR) ) 
          --PRINT( 'creative signature-' + @creativesignature ) 
		  If NOT EXISTS (Select top 1 * from PatternDetailRA where RCSCreativeID=@CreativeSignature and PatternID=@PatternMasterID)  --MI-984 L.E. 2.16.17
		  BEGIN 
          INSERT INTO PatternDetailRA 
                      ([PatternID], 
                       [RCSCreativeID]) 
          VALUES      (@PatternMasterID, 
                       @CreativeSignature) 
	      End

          SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 

          SET @RowCount = 1 
		print @NumberRecords
          --WHILE @RowCount <= @NumberRecords 
          --  BEGIN 
          --      --- Get OccurrenceID's from Temporary table  
          --      SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature  WHERE  rowid = @RowCount
          --      PRINT( 'occurrenceid-'  + Cast(@OccurrenceID AS VARCHAR) ) 
          --      ----Update PatternMasterID and Ad into OCCURRENCEDETAILSRA Table    
          --      UPDATE [dbo].[OccurrenceDetailRA] SET   [PatternID] = @PatternMasterID, [AdID] = @AdID WHERE  [OccurrenceDetailRAID] = @OccurrenceID               
          --      SET @RowCount=@rowcount + 1 
			
          --  END 

	   UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
	   FROM [dbo].[OccurrenceDetailRA] a INNER JOIN #tempoccurencesforcreativesignature b on a.OccurrenceDetailRAID = b.occurrenceid    

		--Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster
        --DELETE FROM PatternDetailRAStaging WHERE [PatternStgID] in   (select [PatternStgID]   FROM   [PatternStaging] WHERE  [CreativeStgID] = @CreativeStagingID ) 
        DELETE FROM [PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
        DELETE FROM [CreativeDetailStagingRA] WHERE [CreativeStgID] = @CreativeStagingID        
        DELETE FROM [CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID  

          -- Update Occurrence in Ad Table  
          UPDATE Ad SET    [PrimaryOccurrenceID] = @primaryOccurrenceID WHERE  [AdID] = @AdID  AND [PrimaryOccurrenceID] IS NULL 

          --- Mark RCS Creative as Deleted          
          UPDATE [RCSCreative] SET  [Deleted] = 1 WHERE  [RCSCreativeID] = @CreativeSignature 

			

		   IF EXISTS(SELECT 1 FROM  ad where ad.[AdID]=@AdID) 
            BEGIN 
			 SELECT @AdID AS AdId
			END



          DROP TABLE #tempoccurencesforcreativesignature 

		  
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(),  @lineNo = Error_line() 
          RAISERROR ('[sp_RadioSaveAdDetails]: %d: %s',16,1,@error,@message,@lineNo) ; 
          ROLLBACK TRANSACTION 
      END CATCH 
  END