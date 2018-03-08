
-- ==========================================================================================

-- Author		: Arun Nair
-- Create date	: 10/26/2015
-- Description	: Adding new record into Ad table for Email
-- Updated By	: 
-- ===============================================================================================

CREATE PROCEDURE [dbo].[sp_EmailSaveAdData] 	

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
	@FirstRunDate           AS NVARCHAR(max)='',
	@LastRunDate            AS NVARCHAR(max)='',
	@FirstRunDMA            AS NVARCHAR(max)='', 
	@BreakDate              AS DATETIME, 
	@StartDate              AS DATETIME,
	@EndDate                AS DATETIME, 
	@SessionDate            AS DATETIME,
	@isUnclassified         AS BIT,
	@ParentOccurrenceId    AS BIGINT,
	@UserId					AS INT
)
AS
BEGIN

	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 

		  DECLARE @ADID AS INT
		  DECLARE @PatternMasterID AS INT
		  DECLARE @RunDMAID AS INT = NULL

		  If @TagLineID='' 
		  set @TagLineID=null

		  IF @FirstRunDMA <> '' AND @FirstRunDMA IS NOT NULL
		  BEGIN
			 SELECT @RunDMAID = MarketID FROM Market 
				WHERE Descrip = @FirstRunDMA
		  END
		  ELSE IF @ParentOccurrenceId > 0
		  BEGIN
			 SELECT @RunDMAID = MarketId FROM OccurrenceDetailEM
				WHERE OccurrenceDetailEMID = @ParentOccurrenceId
		  END 

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

          VALUES      ( 
						@OriginalADID, 
                        @ParentOccurrenceId, 
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
						Null,
                        @SessionDate,
                        @isUnclassified,
						getdate(),
						@UserId
						)

			SELECT @AdID = SCOPE_IDENTITY();     
						

			exec [dbo].[sp_EmailMapCreativeOccurrenceToAd]  @Description='', @RecutDetail='' , @Adid=@ADID , @OccurrenceID=  @ParentOccurrenceId ,@UserID =@UserId
			
			---L.E.9.28.2017 MI-1183 set default primary thumb to image 1
			UPDATE [CREATIVE] 
			SET [CREATIVE].AssetThmbnlName =[CreativeDetailEM].CreativeAssetName,[CREATIVE].ThmbnlRep=replace(CreativeRepository, 'Original', 'Thumb'),
			[CREATIVE].ThmbnlFileType=UPPER(creativefiletype)
			FROM [CREATIVE] join [CreativeDetailEM]  on [CREATIVE].PK_Id=[CreativeDetailEM].CreativeMasterID
			WHERE [CREATIVE].AdId= @AdID and [CREATIVE].SourceOccurrenceId=@ParentOccurrenceId and [CreativeDetailEM].PageNumber=1
						
			-- Update Stage Status for occurrence
			EXEC [sp_EmailUpdateOccurrenceStageStatus] @ParentOccurrenceId, 2
			
			SELECT @AdID as AdID -- Get AdId mapped to ParentOccurrenceId
			COMMIT TRANSACTION

     END TRY

			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailSaveAdData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH

END