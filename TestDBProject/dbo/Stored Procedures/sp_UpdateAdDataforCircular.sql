-- =============================================
-- Author		: Karunakar
-- Create date	: 20/05/2015
-- Description	: Updating Ad that is Edited for Circular 
-- Updated By	: Update By Karunakar on 11th August 2015,Changing Creativemaster and Ad table Fileds
--				: Karunakar on 09/11/15
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateAdDataforCircular] 
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
@RevisionDetail AS NVARCHAR(Max)=''
)
AS
BEGIN
	
	SET NOCOUNT ON;

			BEGIN TRY
				BEGIN TRANSACTION 
						-------Updating  Ad Table--------------------  
						UPDATE [dbo].[Ad] 
						SET [LeadAvHeadline]=@LeadAudioHeadline,[LeadText]=@LeadText,[AdVisual]=@Visual,[Description]=@Description,
						  [AdvertiserID]=@AdvertiserID,[LanguageID]=@LanguageID,[CommonAdDT]=@CommondAdDate,[InternalNotes]=@InternalLookupNotes,
						  [NoTakeAdReason]=@NotakeReason,[AdLength]=@Length,[OriginalAdID]=@OriginalADID,[RecutDetail]=@RevisionDetail
						 Where Ad.[AdID]=@Adid

						  ------Updating Creative Master----------------

						 UPDATE [dbo].[Creative]
						 SET [PrimaryQuality]=@CreativeAssetQuality
						 Where [AdId]=@Adid
				COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('SP_UpdateAdDataforCircular: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
   
END
