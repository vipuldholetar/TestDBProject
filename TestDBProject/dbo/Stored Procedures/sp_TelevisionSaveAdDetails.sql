
-- ====================================================================================================================
-- Author				: Ramesh
-- Create date			: 23rd July 2015
-- Description			: This Procedure is Used to Save Television Ad Data
-- Execution Process	: sp_TelevisionSaveAdDatails 'New Lead Direct Ad3','','','',1,'',1,'07/13/2014','',158,146,1,91,'','','',Null,'','07/13/2014','07/13/2014','','07/13/2014','07/13/2014','07/13/2014','07/13/2014',0,''
-- Updated By			: Arun Nair on 08/13/2015 -Cleanup OnemT 
--						: Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--						  Karunakar on 8th Sep 2015,Adding MediaFormat Check
--						: Karunakar on 17th Nov 2015,Returning Generated Ad ID Value
-- ======================================================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionSaveAdDetails]
	
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
 @SessionDate            AS DATETIME, 
 @isUnclassified         AS BIT,
 @CreativeSignature     AS NVARCHAR(max)='',
 @UserID as int,
@originalAdDescription as nvarchar(max)='',
@originalAdRecutDetail as nvarchar(max)=''
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

		  If @TagLineID='' 
		  set @TagLineID=null
          

          INSERT INTO [dbo].[Ad]  

                      (
					  [OriginalAdID],
					   [PrimaryOccurrenceID], 
					   [AdvertiserID],
					   [BreakDT],
						[StartDT], 
						 [LanguageID], 
                       [FamilyID],
					    [CommonAdDT], 
						 [FirstRunMarketID],
						  FirstRunDate,
						   LastRunDate, AdName, 
                       AdVisual,
					    AdInfo,
						 Coop1AdvId,
						  Coop2AdvId,
						   Coop3AdvId,
						    Comp1AdvId, 
                       Comp2AdvId,  
					   TaglineId,
					    LeadText, 
						LeadAvHeadline, 
						RecutDetail, 
                       RecutAdId, EthnicFlag, AddlInfo, AdLength, InternalNotes, ProductId, 
                       [description], [notakeadreason],  SessionDate, Unclassified,CreateDate,CreatedBy) 
          VALUES      ( @OriginalADID, NULL, @Advertiser,  @BreakDate, @StartDate, @LanguageID, 
                        NULL,  @CommondAdDate,@FirstRunDMA,  @FirstRunDate, @LastRunDate,  NULL, 
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
           SELECT  [OccurrenceDetailTVID]
          FROM    [dbo].[OccurrenceDetailTV] inner join  [Pattern] on [Pattern].[CreativeSignature]=[OccurrenceDetailTV].[PRCODE]
                 Where [OccurrenceDetailTV].[PRCODE]= @CreativeSignature 
                 
          DECLARE @primaryOccurrenceID AS INTEGER 

          SELECT @primaryOccurrenceID = Min(occurrenceid) 
          FROM   #tempoccurencesforcreativesignature 

          --PRINT ( 'primaryoccurrenceid-'  + Cast(@primaryOccurrenceID AS VARCHAR) ) 

          IF EXISTS(select 1 from [CreativeStaging] a inner join  [PatternStaging] b 
		            on a.[CreativeStagingID]=b.[CreativeStgID] 
		            Where b.[CreativeSignature] = @CreativeSignature) 
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
					   s
                --PRINT( 'creativemaster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                --PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]  
                SELECT @CreativeStagingID = [CreativeStgID] 
                 from   [PatternStaging] 		    
		         Where [CreativeSignature] = @CreativeSignature
				 
				 --PRINT( 'creativemasterStagging id-' + Cast(@CreativeStagingID AS VARCHAR) ) 
				
                INSERT INTO creativedetailTV -- select * from CreativeDetailTVStg
                            (creativemasterid, 
                             creativeassetname, 
                             creativerepository, 
                             legacycreativeassetname, 
                             creativefiletype) 
                SELECT @CreativeMasterID, 
                       MediaFileName, 
                       MediaFilepath, 
                       null, 
                       MediaFormat 
                FROM   [CreativeDetailStagingTV] 
                WHERE  [CreativeStgMasterID]= @CreativeStagingID and [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed

				Set @CreativeDetailID=Scope_identity();

                --PRINT ( 'creativedetailTV - inserted' ) 
				--Print('CreativeDetailTV Id-'+ Cast(@CreativeDetailID AS VARCHAR))
            END 
           /* 
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
					   CreativeSignature
					 ) 
          SELECT @CreativeMasterID, 
                 @adid, 
                 @MediaStream, 
                 [Exception], 
                 [Query],  
                 'Valid',  
				 @UserID,                    -- Status Value HardCoded
                 Getdate(),
				 NULL,
				 NULL,
				 @CreativeSignature  
          FROM  [dbo].[PatternTVStaging]
          WHERE  [CreativeSignature] = @CreativeSignature
		  */
		  update p
			set [AdId] = @adid, [Exception] = ps.[Exception], [Query] = ps.[Query], [ModifiedBy] = @UserID, [ModifyDate] = getdate()
			from [PatternStaging] ps join [Pattern] p on p.[PatternID] = ps.[PatternID]
			and ps.[CreativeSignature] = @CreativeSignature
		
          --PRINT( 'patternmaster - inserted' ) 
		
          SET @PatternMasterID=Scope_identity(); 

          --PRINT( 'patternmasterid-'       + Cast(@PatternMasterID AS VARCHAR) ) 

          --PRINT( 'creative signature-' + @creativesignature ) 

         
    --      SELECT @NumberRecords = Count(*) 
    --      FROM   #tempoccurencesforcreativesignature 

    --      SET @RowCount = 1 

    --      WHILE @RowCount <= @NumberRecords 
    --        BEGIN 
    --            --- Get OccurrenceID's from Temporary table  
    --            SELECT @OccurrenceID = [occurrenceid] 
    --            FROM   #tempoccurencesforcreativesignature 
    --            WHERE  rowid = @RowCount 

    --            --PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 
    --           ----Update PatternMasterID and Ad into [dbo].[occurrencedetailsTV]  Table    
			 ----print '[OccurrenceDetailTV]'
			 ----print @PatternMasterID
			 ----print 'patternid'
    --            UPDATE [dbo].[OccurrenceDetailTV] 
    --            SET    [PatternID] = @PatternMasterID, 
    --                   [AdID] = @AdID 
    --            WHERE  [OccurrenceDetailTVID] = @OccurrenceID
  		--				print ' after [OccurrenceDetailTV]'					
    --            SET @RowCount=@rowcount + 1 
    --        END 

		  UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
		  FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]

		  --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 
		  DELETE FROM [dbo].[PatternStaging] WHERE [PatternStagingID] in   (select [PatternStagingID]   FROM   [dbo].[PatternStaging]  WHERE  [CreativeStgID] = @CreativeStagingID ) 						
		  DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeDetailStagingTV] WHERE [CreativeStgMasterID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

          -- Update Occurrence in Ad Table  
          UPDATE Ad 
          SET    [PrimaryOccurrenceID] = @primaryOccurrenceID 
          WHERE  Ad.[AdID] = @AdID 
                 AND [PrimaryOccurrenceID] IS NULL 

		 			
			--Returning Generated Ad ID Value
			IF EXISTS(SELECT 1 FROM  ad where ad.[AdID]=@AdID) 
            BEGIN 
			 SELECT @AdID AS AdId
			END
			
          DROP TABLE #tempoccurencesforcreativesignature
          COMMIT TRANSACTION 
      END TRY 

      BEGIN catch 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('sp_TelevisionSaveAdDatails: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END