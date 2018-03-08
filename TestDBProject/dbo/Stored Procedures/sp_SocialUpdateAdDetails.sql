-- ===========================================================================
-- Author		: KARUNAKAR
-- Create date	: 23rd NOV 2015
-- Description	: This Procedure is Used to  Updating Social Ad Details
-- UpdatedBy    : 
--				   
-- ========================================================================
CREATE PROCEDURE [dbo].[sp_SocialUpdateAdDetails] 
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
@UserId AS INTEGER
)
AS
BEGIN
	
	SET NOCOUNT ON;

				BEGIN TRY
				BEGIN TRANSACTION
				
				 
						-------Update Ad Table--------------------  
						UPDATE [dbo].[AD] 
						SET LeadAvHeadline=@LeadAudioHeadline,[LeadText]=@LeadText,[ADVisual]=@Visual,description =description+','+ @Description,
						  [AdvertiserID]=@AdvertiserID,[LanguageID]=@LanguageID,[CommonAdDT]=@CommondAdDate,[InternalNotes]=@InternalLookupNotes,
						  [NoTakeAdReason]=@NotakeReason,[AdLength]=@Length,[OriginalAdID]=@OriginalADID,[RecutDetail]=@RevisionDetail,ModifiedDate=getdate(),ModifiedBy=@UserId
						 Where [AdID]=@Adid

						  ------Update Creative Master----------------

						 UPDATE [dbo].[Creative]
						 SET PrimaryQuality=@CreativeAssetQuality
						 Where [AdId]=@Adid
				COMMIT TRANSACTION
 				END TRY 
				BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_SocialUpdateAdDetails: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
				END CATCH 
END