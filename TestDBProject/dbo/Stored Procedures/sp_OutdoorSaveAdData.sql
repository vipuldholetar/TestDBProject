
-- =====================================================================================================================================================================================================================================================
-- Author				: KARUNAKAR
-- Create date			: 10th July 2015
-- Description			: This Procedure is Used to Save Outdoor Ad Data
-- Execution Process	: sp_OutdoorSaveAdData 'New Lead Direct Ad3','','','',1,'',1,'07/13/2014','',158,149,1,91,'','','',Null,'','07/13/2014','07/13/2014','','07/13/2014','07/13/2014','07/13/2014','07/13/2014',0,'AT&T 4G NetWork,ATL,07-06-15.jpg'
-- Updated By			: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--						  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--						: Karunakar on 17th Nov 2015,Returning Generated Ad ID Value
--						:L.E. on 1/31/2017 - Added check to update Pattern table if record exists MI-953
-- ======================================================================================================================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorSaveAdData]	
(
@LeadAudioHeadline      AS NVARCHAR(max)='', 
@LeadText               AS NVARCHAR(max)='', 
@Visual                 AS NVARCHAR(max)='', 
@Description            AS NVARCHAR(max)='', 
@Advertiser             AS INT=0, 
@TagLineID              AS NVARCHAR(max)=Null, 
@LanguageID             AS INT=0, 
@CommondAdDate          AS DATETIME, 
@InternalNotes          AS NVARCHAR(max)='', 
@NotakeReason           AS INTEGER=0, 
@MediaStream            AS INT, 
@Length                 AS INT=0, 
@CreativeAssetQuality   AS INT, 
@TradeClass             AS NVARCHAR(max)='', 
@CoreSupplementalStatus AS NVARCHAR(max)='', 
@DistributionType       AS NVARCHAR(max)='', 
@OriginalADID           AS INT=0, 
@RevisionDetail         AS NVARCHAR(max)='',
@FirstRunDate           AS DATETIME, 
@LastRunDate            AS DATETIME, 
@FirstRunDMA            AS NVARCHAR(max)='', 
@BreakDate              AS DATETIME, 
@StartDate              AS DATETIME, 
@EndDate                AS DATETIME,                                              
@SessionDate            AS DATETIME = '', 
@isUnclassified         AS BIT,
@CreativeSignature     AS NVARCHAR(max)='',
@UserID as int,
@originalAdDescription as nvarchar(max),
@originalAdRecutDetail as nvarchar(max)
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
		  Declare @CreativeDetailID As Int=0
		  DECLARE @RunDMAID AS INT = NULL

		  If @TagLineID='' 
		  set @TagLineID=null
		
		  IF @FirstRunDMA <> '' AND @FirstRunDMA IS NOT NULL
		  BEGIN
			 SELECT @RunDMAID = MarketID FROM Market 
				WHERE Descrip = @FirstRunDMA
		  END

		  IF @SessionDate IS NULL OR @SessionDate = ''
			 SET @SessionDate = GETDATE()

		  INSERT INTO [dbo].[Ad] 
                      ([OriginalAdID], [PrimaryOccurrenceID], [AdvertiserID], [BreakDT], [StartDT],  [LanguageID], 
                       [FamilyID], [CommonAdDT],  [FirstRunMarketID],  FirstRunDate, LastRunDate, AdName, 
                       AdVisual, AdInfo, Coop1AdvId, Coop2AdvId, Coop3AdvId, Comp1AdvId, 
                       Comp2AdvId,  TaglineId, LeadText, LeadAvHeadline, RecutDetail, 
                       RecutAdId, EthnicFlag, AddlInfo, AdLength, InternalNotes, ProductId, 
                       Description, NoTakeAdReason,  SessionDate, Unclassified,CreateDate,CreatedBy) 
		  VALUES	( @OriginalADID, NULL, @Advertiser,  @BreakDate, @StartDate, @LanguageID, 
				    NULL,  @CommondAdDate,@RunDMAID,  @FirstRunDate, @LastRunDate,  NULL, 
				    @Visual, NULL, NULL, NULL, NULL, NULL,
				    NULL, @TagLineID,  @LeadText, @LeadAudioHeadline, @RevisionDetail, 
				    NULL,  0,  NULL, @Length, @InternalNotes,NULL,  						
				    @Description, @NotakeReason,@SessionDate, @isUnclassified,getdate(),@UserID)  

          SELECT @adid = Scope_identity(); 

          --Index the Ad to CreativeSignature  
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT 
            ) 

          INSERT INTO #tempoccurencesforcreativesignature 
           SELECT  [OccurrenceDetailODRID]
          FROM    [dbo].[OccurrenceDetailODR]
                 Where [OccurrenceDetailODR].ImageFileName= @CreativeSignature 

          DECLARE @primaryOccurrenceID AS INTEGER 

          SELECT @primaryOccurrenceID = Min(occurrenceid) 
          FROM   #tempoccurencesforcreativesignature 

          PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 

          IF EXISTS(SELECT * FROM   [CreativeStaging] inner join [CreativeDetailStagingODR] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingODR].CreativeStagingID WHERE  [OccurrenceID]= @primaryOccurrenceID) 
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

                PRINT( 'creativemaster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING] 
				SELECT @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  FROM   [CreativeStaging] 
				inner join [CreativeDetailStagingODR] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingODR].CreativeStagingID 
				WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID 

				 PRINT( 'creativemasterStagging id-' + Cast(@CreativeStagingID AS VARCHAR) ) 

                INSERT INTO creativedetailODR 
                            (creativemasterid, 
                             creativeassetname, 
                             creativerepository, 
                             legacycreativeassetname, 
                             creativefiletype,
							 AdFormatId) 
                SELECT @CreativeMasterID, 
                       [CreativeAssetName], 
                       [CreativeRepository], 
                       null, 
                       [CreativeFileType],
					   AdFormatID 
                FROM   [CreativeDetailStagingODR]
                WHERE  [CreativeStagingID]= @CreativeStagingID 

				SET @CreativeDetailID=Scope_identity();

                PRINT ( 'creativedetailODR - inserted' ) 
				PRINT('CreativeDetailODR Id-'+ Cast(@CreativeDetailID AS VARCHAR))
		
            END 

		---Get Pattern ID into @PatternMasterID from [PATTERNSTAGING] used for OccuranceDetailODR update as well 
			
			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  [CreativeSignature] = @CreativeSignature
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', ModifiedBy=@UserID, ModifyDate=Getdate(), LastMapperInits=@UserId, LastMappedDate=getdate(),
					CreativeSignature=@CreativeSignature
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID and [Pattern].[CreativeSignature] = @CreativeSignature 
			END  
			ELSE 
			BEGIN 
				INSERT INTO [Pattern] 
						  ([CreativeID], 
						   [AdID], 
						   MediaStream, 
						   [Exception],  
						   [Query], 
						   Status,
						   CreateBy, 
						   CreateDate,
						   ModifiedBy,
						   ModifyDate,
						   CreativeSignature) 
			  SELECT @CreativeMasterID, 
					 @adid, 
					 @MediaStream, 
					 [Exception], 
					 [Query],  
					 'Valid',
					 @UserID,                          -- Status Value HardCoded
					 Getdate(),
					 NULL,
					 NULL,
					 @CreativeSignature
			  FROM   [dbo].[PatternStaging] 
			  WHERE  [CreativeSignature] = @CreativeSignature
		   

			  PRINT( 'patternmaster - inserted' ) 
			  SET @PatternMasterID=Scope_identity(); 
		  END


          PRINT( 'patternmasterid-'  + Cast(@PatternMasterID AS VARCHAR) ) 
          PRINT( 'creative signature-' + @creativesignature ) 

          
          SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 

          --SET @RowCount = 1 

          --WHILE @RowCount <= @NumberRecords 
          --  BEGIN 
          --      --- Get OccurrenceID's from Temporary table  
          --      SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount 

          --      PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 

          --      ----Update PatternMasterID and Ad into [dbo].[OccurrenceDetailsODR]  Table    
          --      UPDATE [dbo].[OccurrenceDetailODR] 
          --      SET    [PatternID] = @PatternMasterID, 
          --             [AdID] = @AdID 
          --      WHERE  [OccurrenceDetailODR].[OccurrenceDetailODRID] = @OccurrenceID

          --      SET @RowCount=@rowcount + 1 
          --  END 

		  UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
			 FROM [dbo].[OccurrenceDetailODR] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailODRID]=b.[occurrenceid]

		  -- update QueryDetail
		  update [QueryDetail]
		  set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
		  where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)

		  --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 						
		  DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeDetailStagingODR] WHERE CreativeStagingID = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

		  
		  IF @RunDMAID IS NULL OR @RunDMAID <=0
		  BEGIN
			  SELECT @RunDMAID = MTMarketID FROM OccurrenceDetailODR
				WHERE OccurrenceDetailODRID = @primaryOccurrenceID
		  END

          -- Update Occurrence in Ad Table  
          UPDATE Ad 
          SET    [PrimaryOccurrenceID] = @primaryOccurrenceID, [FirstRunMarketID] = @RunDMAID
          WHERE  Ad.[AdID] = @AdID 
                 AND [PrimaryOccurrenceID] IS NULL 

		  
          --Returning Generated Ad ID Value
           IF EXISTS(SELECT 1 FROM  ad where ad.[AdID]=@AdID) 
			BEGIN 
			SELECT @AdID AS AdId
			END


		  -- Deleting Creative Signature from PatternMasterStagingODR

			Exec sp_OutdoorDeleteCreativeSignaturefromQueue @CreativeSignature


          DROP TABLE #tempoccurencesforcreativesignature 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT,  @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('sp_OutdoorSaveAdData: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END catch 
  END