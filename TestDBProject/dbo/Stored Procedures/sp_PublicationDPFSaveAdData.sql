

-- =============================================

-- Author		: Karunakar

-- Create date	: 06/11/2015

-- Description	: This Adding new record into Ad table for Publication
--UpdatedBy		: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
-- =============================================

CREATE PROCEDURE [dbo].[sp_PublicationDPFSaveAdData] 	

(@LeadAudioHeadline      AS NVARCHAR(max)='', 

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

 @isUnclassified         AS BIT
)

AS

 IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	SET NOCOUNT ON;

	 BEGIN Try 

          BEGIN TRANSACTION 

		  
		  If @TagLineID='' 
		  set @TagLineID=null


		  DECLARE @ADID as INT
		   INSERT INTO [dbo].[ad] 

                       ([OriginalAdID], [PrimaryOccurrenceID], [AdvertiserID], [BreakDT], [StartDT], [LanguageID], 
                       [FamilyID], [CommonAdDT],  [FirstRunMarketID],  FirstRunDate, LastRunDate, AdName, 
                       AdVisual, AdInfo, Coop1AdvId, Coop2AdvId, Coop3AdvId, Comp1AdvId, 
                       Comp2AdvId,  TaglineId, LeadText, LeadAvHeadline, RecutDetail, 
                       RecutAdId, EthnicFlag, AddlInfo, AdLength, InternalNotes, ProductId, 
                       [Description], [notakeadreason],  SessionDate, Unclassified) 

          VALUES      ( @OriginalADID, NULL, @Advertiser,  @BreakDate, @StartDate, @LanguageID, 

                        NULL,  @CommondAdDate,@FirstRunDMA,  @FirstRunDate, @LastRunDate,  NULL, 

                        @Visual, NULL, NULL, NULL, NULL, NULL,
						NULL, @TagLineID,  @LeadText, @LeadAudioHeadline, @RevisionDetail, 

						NULL,  0,  NULL, @Length, @InternalNotes,NULL,  
						
						 @Description, @NotakeReason,@SessionDate, @isUnclassified) 

                       
						
						

                       

			SELECT @AdID = Scope_identity(); 
			Select @ADID As AdId
		   Commit TRANSACTION
           End Try
	                 BEGIN CATCH

					 DECLARE @error   INT,

					 @message VARCHAR(4000), 

					 @lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			      RAISERROR ('sp_PublicationDPFSaveAdData: %d: %s',16,1,@error,@message,@lineNo)   ; 

				ROLLBACK TRANSACTION 

			END CATCH
			END