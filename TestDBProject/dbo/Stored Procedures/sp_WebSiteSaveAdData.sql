-- ==========================================================================================

-- Author		: KARUNAKAR
-- Create date	: 11th Nov 2015
-- Description	: Adding new record into Ad table for Website
-- Updated By	: 
-- ===============================================================================================

CREATE PROCEDURE [dbo].[sp_WebSiteSaveAdData] 	
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
	@UserId					AS INT
)
AS
BEGIN

	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 

		  DECLARE @ADID AS INT
		  DECLARE @PatternMasterID AS INT

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
                        Null, 
                        @Advertiser, 
                        @BreakDate,
                        @StartDate,
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

			Set @AdID = SCOPE_IDENTITY();       
				
			SELECT @AdID as AdID -- Get AdId
			COMMIT TRANSACTION

     END TRY

			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_WebsiteSaveAdData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH

END