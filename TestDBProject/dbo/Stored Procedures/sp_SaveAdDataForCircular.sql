-- ==========================================================================================

-- Author		: Karunakar
-- Create date	: 20/05/2015
-- Description	: Adding new record into Ad table for Circular
-- Updated By	: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ===============================================================================================

CREATE PROCEDURE [dbo].[sp_SaveAdDataForCircular] 	

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
 @NotakeReason           AS INTEGER,
 @MediaStream            AS INT,
 @Length                 AS INT=0, 
 @CreativeAssetQuality   AS INT, 
 @TradeClass             AS NVARCHAR(max)='',
 @CoreSupplementalStatus AS NVARCHAR(max)='',
 @DistributionType       AS NVARCHAR(max)='',
 @OriginalADID           AS INT, 
 @RevisionDetail         AS NVARCHAR(max)='', 
 @FirstRunDate           AS DATETIME,
 @LastRunDate            AS DATETIME,
 @FirstRunDMA            AS NVARCHAR(max)='', 
 @BreakDate              AS DATETIME, 
 @StartDate              AS DATETIME,
 @EndDate                AS DATETIME, 
 @SessionDate            AS DATETIME,
 @isUnclassified         AS BIT,
 @OccurrenceId           AS BIGINT,
 @UserId				 AS INT
 )

AS

BEGIN

	

	SET NOCOUNT ON;

	 BEGIN Try 

          BEGIN TRANSACTION 

		  DECLARE @ADID as INT
		  Declare @PatternMasterID as int

		  If @TagLineID='' 
		  set @TagLineID=null

		   INSERT INTO [dbo].[ad] 

                      ([OriginalAdID], 

                       [PrimaryOccurrenceID], 

                       [AdvertiserID], 

                       [BreakDT], 

                       [StartDT], 

                       [EndDT], 

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

                       [TaglineId], 

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

                       [unclassified],
					   [CreateDate],
					   [CreatedBy]
					   ) 

          VALUES      ( @OriginalADID, 

                        @OccurrenceId, 

                        @Advertiser, 

                        @BreakDate, 

                        @StartDate, 

                        @EndDate, 

                        @LanguageID, 

                        NULL, 

                        @CommondAdDate,
				  
                        @FirstRunDMA, 

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
						Null,
                        @SessionDate, 

                        @isUnclassified,
						getdate(),
						@UserId
						)



			SELECT @AdID = Scope_identity();       
			
			--map adid to occurrenceid 

			update [OccurrenceDetailCIR] set [AdID]=@AdID where [OccurrenceDetailCIRID]=@OccurrenceId
			
			-- update patternmaster with adid

			select @patternmasterid=[PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@OccurrenceId
			update [Pattern] set [AdID]=@adid where [Pattern].[PatternID]=@patternmasterid
			

			-- update stage status for occurrence

			exec sp_updateoccurrencestagestatus @OccurrenceId, 2
			
			select @AdID as AdID

		  Commit TRANSACTION

     End Try

	 BEGIN CATCH

					 DECLARE @error   INT,

					 @message VARCHAR(4000), 

					 @lineNo  INT 



				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			      RAISERROR ('SP_SaveAdDataForCircular: %d: %s',16,1,@error,@message,@lineNo)   ; 

				ROLLBACK TRANSACTION 

			END CATCH

END