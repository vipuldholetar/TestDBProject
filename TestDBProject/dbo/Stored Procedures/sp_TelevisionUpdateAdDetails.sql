

-- ===================================================================
-- Author			: Arun Nair
-- Create date		: 28th July 2015
-- Description		: This Procedure is used to Update Ad for TV 
-- Updated By		: Arun on 08/13/2015 -Cleanup OnemT 
--					:Arun Nair on 08/25/2015 - Added ModifiedDate,ModifiedBy
--=====================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionUpdateAdDetails]
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
						UPDATE [dbo].[Ad] 
						SET LeadAvHeadline=@LeadAudioHeadline,LeadText=@LeadText,AdVisual=@Visual,[Description]=@Description,
						  [AdvertiserID]=@AdvertiserID,[LanguageID]=@LanguageID,[CommonAdDT]=@CommondAdDate,InternalNotes=@InternalLookupNotes,
						  [NoTakeAdReason]=@NotakeReason,AdLength=@Length,[OriginalAdID]=@OriginalADID,RecutDetail=@RevisionDetail,ModifiedDate=getdate(),ModifiedBy=@UserId
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
						RAISERROR ('[sp_TelevisionUpdateAdDetails]: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
	
END
