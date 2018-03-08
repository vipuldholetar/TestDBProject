
-- ===============================================================================================
-- Author			: Karunakar
-- Create date		: 11/26/2015
-- Description		: Check if the Ad Id Exist in  Creative Master 
-- Execution Process: sp_SocialDPFCheckIsCreativeExist 10427
-- UpdatedBy		: 
-- ===============================================================================================
cREATE PROCEDURE [dbo].[sp_SocialDPFCheckIsCreativeExist]
	@AdId As Int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsCreativeExists As  Bit
	DECLARE @CreativeMasterID INT
	
		BEGIN TRY
			SELECT @CreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=(SELECT [PrimaryOccurrenceID] FROM Ad WHERE Ad.[AdID]=@AdId))
			IF Exists(SELECT 1 FROM [Creative] inner join CreativeDetailSOC on  [Creative].PK_Id=CreativeDetailSOC.CreativeMasterID  WHERE [Creative].PK_Id=@CreativeMasterID and CreativeDetailSOC.CreativeRepository Is Not Null)
				BEGIN
				   SET @IsCreativeExists=1
				END
			ELSE
				BEGIN
				   SET @IsCreativeExists=0
				END
			SELECT @IsCreativeExists As IsCreativeExists
	  END TRY
	  BEGIN CATCH
		 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_SocialDPFCheckIsCreativeExist]: %d: %s',16,1,@error,@message,@lineNo); 
	  END CATCH
END
