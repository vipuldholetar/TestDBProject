
-- ===============================================================================================
-- Author			: Arun Nair
-- Create date		: 11/13/2015
-- Description		: Check if the Ad Id Exist in  Creative Master 
-- Execution Process: sp_WebsiteDPFCheckIsCreativeExist 10427
-- UpdatedBy		: 
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_WebsiteDPFCheckIsCreativeExist]
	@AdId As Int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsCreativeExists As  Bit
	DECLARE @CreativeMasterID INT
	
		BEGIN TRY
			SELECT @CreativeMasterID=[CreativeID] FROM [Pattern] WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailWEB] WHERE [OccurrenceDetailWEBID]=(SELECT [PrimaryOccurrenceID] FROM Ad WHERE [AdID]=@AdId))
			IF Exists(SELECT 1 FROM [Creative] inner join CreativeDetailWEb on  [Creative].PK_Id=CreativeDetailWEb.CreativeMasterID  WHERE [Creative].PK_Id=@CreativeMasterID and CreativeDetailWEb.CreativeRepository Is Not Null)
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
				  RAISERROR ('[sp_WebsiteDPFCheckIsCreativeExist]: %d: %s',16,1,@error,@message,@lineNo); 
	  END CATCH
END
