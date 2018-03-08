﻿-- ===========================================================================================================================
-- Author				: KARUNAKAR
-- Create date			: 20th July 2015
-- Description			: This Procedure is Used to Save Cinema Ad Data
-- Execution Process	: sp_CinemaSaveAdDatails 'New Lead Direct Ad3','','','',1,'',1,'07/13/2014','',158,146,1,91,'','','',Null,'','07/13/2014','07/13/2014','','07/13/2014','07/13/2014','07/13/2014','07/13/2014',0,''
-- Updated By			: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--						  Arun Nair on 08/24/2015 - For OccurrenceId Change Datatype-Seeding
--						  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--						  Karunakar on 7th Sep 2015
--						: Karunakar on 17th Nov 2015,Returning Generated Ad ID Value
-- ===========================================================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaSaveAdDetails]
(
@LeadAudioHeadline      AS NVARCHAR(max)='', 
@LeadText               AS NVARCHAR(max)='', 
@Visual                 AS NVARCHAR(max)='',
@Description            AS NVARCHAR(max)='', 
@Advertiser             AS INT=0, 
@TagLineID              AS NVARCHAR(max)=null, 
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
					DECLARE @OccurrenceID AS BIGINT=0 
					DECLARE @CreativeMasterID AS INT=0 
					DECLARE @PatternMasterID AS INT=0 
					DECLARE @CreativeStagingID AS INT=0 
					DECLARE @MTOReason AS VARCHAR(100) 
					DECLARE @NumberRecords AS INT=0 
					DECLARE @RowCount AS INT=0 
					Declare @CreativeDetailID As Int=0

					If @TagLineID='' 
					set @TagLineID=null
          
					--- Inserting data from [Ad]  
					INSERT INTO [dbo].[Ad] 
					([OriginalAdID], [PrimaryOccurrenceID], [AdvertiserID], [BreakDT], [StartDT], [LanguageID], 
					[FamilyID], [CommonAdDT],  [FirstRunMarketID],  FirstRunDate, LastRunDate, AdName, 
					AdVisual, AdInfo, Coop1AdvId, Coop2AdvId, Coop3AdvId, Comp1AdvId, 
					Comp2AdvId,  TaglineId, LeadText, LeadAvHeadline, RecutDetail, 
					RecutAdId, EthnicFlag, AddlInfo, AdLength, InternalNotes, ProductId, 
					Description, NoTakeAdReason,  SessionDate, Unclassified,CreateDate,CreatedBy) 

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
					occurrenceid BIGINT 
					) 

					INSERT INTO #tempoccurencesforcreativesignature 
					SELECT  [OccurrenceDetailCINID] FROM    [dbo].[OccurrenceDetailCIN]
					WHERE [OccurrenceDetailCIN].[CreativeID]= @CreativeSignature 

					DECLARE @primaryOccurrenceID AS BIGINT

					SELECT @primaryOccurrenceID = Min(occurrenceid) 
					FROM   #tempoccurencesforcreativesignature 

					--PRINT ( 'primaryoccurrenceid-'+ Cast(@primaryOccurrenceID AS VARCHAR) ) 

					IF EXISTS(select 1 from [CreativeStaging] a inner join  [PatternStaging] b 
					on a.[CreativeStagingID]=b.[CreativeStgID] 
					Where [OccurrenceID] = @primaryOccurrenceID) 
					BEGIN 
					--- Get data from [CREATIVEMASTER]  
					INSERT INTO [Creative] 
							([AdId], 
								[SourceOccurrenceId], 
								CheckInOccrncs, 
								PrimaryQuality, 
								PrimaryIndicator) 
					SELECT @ADID, @primaryOccurrenceID,1,@CreativeAssetQuality, 1 

					--PRINT( 'creativemaster - inserted' ) 
					SELECT @CreativeMasterID = Scope_identity() 
					-- PRINT( 'creativemaster id-'+ Cast(@CreativeMasterID AS VARCHAR) ) 

					---Get data from [CREATIVEMASTERSTAGING]  
					SELECT @CreativeStagingID = [CreativeStgID] 
					FROM   [PatternStaging] 		    
					WHERE [CreativeSignature] = @CreativeSignature

					-- PRINT( 'creativemasterStagging id-' + Cast(@CreativeStagingID AS VARCHAR) ) 

					--- Inserting data from [CreativeDetailCIN]  
					INSERT INTO creativedetailCIN 
							([CreativeMasterID], 
								creativeassetname, 
								creativerepository, 
								legacycreativeassetname, 
								creativefiletype) 
					SELECT @CreativeMasterID, 
						[CreativeAssetName], 
						[CreativeRepository], 
						'', 
						[CreativeFileType] 
					FROM   [CreativeDetailStagingCIN]
					WHERE  [CreativeStagingID]= @CreativeStagingID 

					Set @CreativeDetailID=Scope_identity();

					--PRINT ( 'creativedetailCIN - inserted' ) 
					--Print('CreativeDetailCIN Id-'+ Cast(@CreativeDetailID AS VARCHAR))
					END 
					--- Inserting data from [PatternMaster]  
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
					exception, 
					query,  
					'Valid',
					@UserID,                         -- Status Value HardCoded
					Getdate(), 
					NULL,
					NULL,
					@CreativeSignature
					FROM  [dbo].[PatternStaging]
					WHERE  [CreativeSignature] = @CreativeSignature

					--PRINT( 'patternmaster - inserted' ) 
					SET @PatternMasterID=Scope_identity(); 
					--PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
					--PRINT( 'creative signature-' + @creativesignature ) 

         
					--SELECT @NumberRecords = Count(*) 
					--FROM   #tempoccurencesforcreativesignature 

					--SET @RowCount = 1 

					--WHILE @RowCount <= @NumberRecords 
					--BEGIN 
					--    --- Get OccurrenceID's from Temporary table  
					--    SELECT @OccurrenceID = [occurrenceid] 
					--    FROM   #tempoccurencesforcreativesignature 
					--    WHERE  rowid = @RowCount 

					--    -- PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 

					--    ----Update PatternMasterID and Ad into [dbo].[occurrencedetailsCIN]  Table    
					--    UPDATE [dbo].[OccurrenceDetailCIN] 
					--    SET    [PatternID] = @PatternMasterID, 
					--	    [AdID] = @AdID 
					--    WHERE  [OccurrenceDetailCINID] = @OccurrenceID
				
					--    SET @RowCount=@rowcount + 1 
					--END 

					UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
					FROM [dbo].[OccurrenceDetailCIN] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailCINID]=b.occurrenceid

				    --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 						
				    DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
				    DELETE FROM [dbo].[CreativeDetailStagingCIN] WHERE [CreativeStagingID] = @CreativeStagingID 
				    DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

					-- Update Occurrenceid in Ad Table  
					UPDATE Ad 
					SET    [PrimaryOccurrenceID] = @primaryOccurrenceID 
					WHERE  [AdID] = @AdID 
					AND [PrimaryOccurrenceID] IS NULL 

					-- Deleting Creative Signature from PatternMasterStgCIN
		
					Exec sp_CinemaDeleteCreativeSignaturefromQueue @CreativeSignature
					
			
					--Returning Generated Ad ID Value
					IF EXISTS(SELECT 1 FROM  ad where ad.[AdID]=@AdID) 
					BEGIN 
					SELECT @AdID AS AdId
					END
					DROP TABLE #tempoccurencesforcreativesignature 

          COMMIT TRANSACTION 
      END try 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('sp_CinemaSaveAdDatails: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END