

-- ===========================================================================
-- Author		: Karunakar
-- Create date	: 3rd Nov 2015
-- Description	: This Procedure is Used to  Updating Email Ad Details
-- UpdatedBy    : 
--				   
-- ========================================================================
CREATE PROCEDURE [dbo].[sp_EmailUpdateAdDetails] 
(
@Adid AS INT,
@LeadAudioHeadline AS NVARCHAR(Max)='',
@LeadText AS NVARCHAR(Max)='', 
@Visual AS NVARCHAR(Max)='',
@Description AS NVARCHAR(Max)='',
@AdvertiserID  AS INT=0,
@LanguageID AS INT=0,
@CommondAdDate AS DATETIME,
@InternalLookupNotes  AS NVARCHAR(Max)='',
@NotakeReason AS INTEGER,
@Length AS INT=0,
@CreativeAssetQuality AS INT,
@OriginalADID AS INT=0,
@RevisionDetail AS NVARCHAR(Max)='',
@FirstRunDate           AS DATETIME, 
@LastRunDate            AS DATETIME, 
@FirstRunDMA            AS NVARCHAR(max)='', 
@UserId AS INTEGER
)
AS
BEGIN
	
	SET NOCOUNT ON;

	   BEGIN TRY
	   BEGIN TRANSACTION
				
				DECLARE @RunDMAID AS INT = NULL
				declare @CreativeAssetQualityVal AS NVARCHAR(30)
						
				IF @FirstRunDMA <> '' AND @FirstRunDMA IS NOT NULL
				BEGIN
				    SELECT @RunDMAID = MarketID FROM Market 
					   WHERE Descrip = @FirstRunDMA
				END
				ELSE
				BEGIN
				    SELECT @RunDMAID = o.MarketId FROM OccurrenceDetailEM o
					   INNER JOIN Ad a on a.PrimaryOccurrenceID = o.OccurrenceDetailEMID
					   WHERE OccurrenceDetailEMID = @Adid
				END 

				-------Update Ad Table--------------------  
				UPDATE [dbo].[AD] 
				    SET LeadAvHeadline=@LeadAudioHeadline,[LeadText]=@LeadText,[ADVisual]=@Visual,[Description]=@Description,
				    [AdvertiserID]=@AdvertiserID,[LanguageID]=@LanguageID,[CommonAdDT]=@CommondAdDate,[InternalNotes]=@InternalLookupNotes,
				    [NoTakeAdReason]=@NotakeReason,[AdLength]=@Length,[OriginalAdID]=@OriginalADID,[RecutDetail]=@RevisionDetail,
				    [FirstRunMarketID] = @RunDMAID,  FirstRunDate = @FirstRunDate, LastRunDate = @LastRunDate, 
				    ModifiedDate=getdate(),ModifiedBy=@UserId
				Where [AdID]=@Adid

				------Update Creative Master----------------

				select @CreativeAssetQualityVal= ValueTitle FROM [dbo].[Configuration] where  [dbo].[Configuration].[SystemName] ='All' AND ComponentName = 'Creative Quality' AND valueGroup like '%EM%' and ConfigurationID= @CreativeAssetQuality
				IF @CreativeAssetQualityVal='Unpresentable'
				BEGIN 
				 Exec sp_EmailExceptionCreativeOccurrenceIdList @Adid=@Adid, @UserId =@UserId
				END 

				UPDATE [dbo].[Creative]
				SET PrimaryQuality=@CreativeAssetQuality
				Where [AdId]=@Adid

	   COMMIT TRANSACTION
 	   END TRY 
	   BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('sp_EmailUpdateAdDetails: %d: %s',16,1,@error,@message,@lineNo);
				ROLLBACK TRANSACTION
	   END CATCH 
END