

-- ======================================================================================================
-- Author		: Karunakar
-- Create date	: 17 June 2015 
-- Description	: This Procedure is Used to Strore Publication ReMap Occurrence Save Ad Data
--UpdatedBy		: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--				  Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ======================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFRemapSaveAdDetails] 	

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
 @OccurrenceId			As Bigint
)
AS
 IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	SET NOCOUNT ON;

	 BEGIN TRY 
	      DECLARE @patternmasterid as Int

		  If @TagLineID=''
		  Set @TagLineID=Null

          BEGIN TRANSACTION 

		  DECLARE @ADID as INT
		   INSERT INTO [dbo].[Ad] 

                      ([OriginalAdID], [PrimaryOccurrenceID], [AdvertiserID], [BreakDT], [StartDT], [LanguageID], 
                       [FamilyID], [CommonAdDT],  [FirstRunMarketID],  FirstRunDate, LastRunDate, AdName, 
                       AdVisual, AdInfo, Coop1AdvId, Coop2AdvId, Coop3AdvId, Comp1AdvId, 
                       Comp2AdvId,  TaglineId, LeadText, LeadAvHeadline, RecutDetail, 
                       RecutAdId, EthnicFlag, AddlInfo, AdLength, InternalNotes, ProductId, 
                       [Description], [notakeadreason],  SessionDate, Unclassified) 

          VALUES      ( @OriginalADID, @OccurrenceId, @Advertiser,  @BreakDate, @StartDate, @LanguageID, 

                        NULL,  @CommondAdDate,@FirstRunDMA,  @FirstRunDate, @LastRunDate,  NULL, 

                        @Visual, NULL, NULL, NULL, NULL, NULL,
						NULL, @TagLineID,  @LeadText, @LeadAudioHeadline, @RevisionDetail, 

						NULL,  0,  NULL, @Length, @InternalNotes,NULL,  
						
						 @Description, @NotakeReason,@SessionDate, @isUnclassified) 

			SELECT @AdID = Scope_identity(); 

			--map adid to occurrenceid 
			if(@OccurrenceId<>'')
			BEGIN
			update [OccurrenceDetailPUB] set [AdID]=@AdID where [OccurrenceDetailPUBID]=@OccurrenceId
			
			-- update patternmaster with adid

			select @patternmasterid=[PatternID] from [OccurrenceDetailPUB] where [OccurrenceDetailPUBID]=@OccurrenceId
			update [Pattern] set [AdID]=@adid where [PatternID]=@patternmasterid
			END
			Select @ADID As AdId
		   Commit TRANSACTION

           End TRY
	       BEGIN CATCH
					 DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_PublicationDPFRemapSaveAdDetails: %d: %s',16,1,@error,@message,@lineNo)   ; 
					ROLLBACK TRANSACTION 

		END CATCH
END