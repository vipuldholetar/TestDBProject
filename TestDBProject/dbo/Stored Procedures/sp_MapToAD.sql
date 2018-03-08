-- =================================================================   
-- Author            :  RP  
-- Create date       :  01/13/2016   
-- Execution		 :  [sp_MapToAD] 
-- Description       :  Map to AD  
-- Updated By		 :  
-- =================================================================   
CREATE PROCEDURE [dbo].[sp_MapToAD] @Description       AS NVARCHAR(max), 
                                   @Revision          AS NVARCHAR(max), 
                                   @Adid              INT, 
                                   @CreativeSignature AS VARCHAR(100), 
                                   @MediaStream       VARCHAR(50), 
                                   @UserID            AS INT 
AS 
  BEGIN 
      SET NOCOUNT ON; 

	  DECLARE @MediaStreamValue As NVARCHAR(50)
	  SELECT @MediaStreamValue = Value FROM [Configuration] WHERE SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStream

				
      BEGIN TRY 
          IF ( @MediaStreamValue = 'RAD') 
            BEGIN 
                EXEC [Sp_radiomapcstoad] 
                  @AdID, 
                  @CreativeSignature, 
                  @Description, 
                  @Revision, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'CIN' ) 
            BEGIN 
               EXEC [sp_CinemaMapCreativeSignatureToAd] 
                  @Description, 
                  @Revision,
				  @AdID, 
                  @CreativeSignature, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'OD' ) 
            BEGIN 
               EXEC [sp_OutdoorMapCreativeSignatureToAd] 
                  @Description, 
                  @Revision,
				  @AdID, 
                  @CreativeSignature, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'TV' ) 
            BEGIN 
                EXEC [sp_TelevisionMapCreativeSignatureToAd]				
					@Description, 
                  @Revision,
				  @AdID, 
                  @CreativeSignature, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'OND' ) 
            BEGIN 
                EXEC [sp_OnlineDisplayMapCreativeSignatureToAd] 
                 @Description, 
                  @Revision,
				  @AdID, 
                  @CreativeSignature, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'ONV' ) 
            BEGIN 
               EXEC [sp_OnlineVideoMapCreativeSignatureToAd] 
                @Description, 
                  @Revision,
				  @AdID, 
                  @CreativeSignature, 
                  @UserId 
            END 
			IF ( @MediaStreamValue = 'MOB' ) 
            BEGIN 
                EXEC [sp_MobileMapCreativeSignatureToAd]
				@Description, 
                  @Revision, 
                  @AdID, 
                  @CreativeSignature,                   
                  @UserId 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_MapToAD]: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END
