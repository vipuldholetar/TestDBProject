-- =================================================================   
-- Author            :  RP  
-- Create date       :  01/14/2016   
-- Execution		 :  [sp_UpdateADForNonPrint]
-- Description       :  Update Ad
-- Updated By		 :  
-- =================================================================   
CREATE PROCEDURE [dbo].[sp_UpdateADForNonPrint]
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
@UserId AS INTEGER,
@MediaStreamName       VARCHAR(50)
AS 
  BEGIN 
      SET NOCOUNT ON; 

	  DECLARE @MediaStreamValue As NVARCHAR(50)
	  SELECT @MediaStreamValue = Value FROM [Configuration] WHERE SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamName

				
      BEGIN TRY 
          IF ( @MediaStreamValue = 'RAD') 
            BEGIN 
                EXEC [sp_RadioUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
                  
            END 
			IF ( @MediaStreamValue = 'CIN' ) 
            BEGIN 
               EXEC [sp_CinemaUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
			IF ( @MediaStreamValue = 'OD' ) 
            BEGIN 
             EXEC [sp_OutdoorUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
			IF ( @MediaStreamValue = 'TV' ) 
            BEGIN 
              EXEC [sp_TelevisionUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
			IF ( @MediaStreamValue = 'OND' ) 
            BEGIN 
                EXEC [sp_OnlineDisplayUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
			IF ( @MediaStreamValue = 'ONV' ) 
            BEGIN 
               EXEC [sp_OnlineVideoUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
			IF ( @MediaStreamValue = 'MOB' ) 
            BEGIN 
                EXEC [sp_MobileUpdateAdDetails]
				@Adid,@LeadAudioHeadline,@LeadText, @Visual,@Description,@AdvertiserID,@LanguageID,@CommondAdDate,@InternalLookupNotes,
				@NotakeReason,@Length,@CreativeAssetQuality,@OriginalADID,@RevisionDetail,@UserId
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_UpdateADForNonPrint]: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END
