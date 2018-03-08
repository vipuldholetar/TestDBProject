
-- ===================================================================================================
-- Author				: Karunakar
-- Create date			: 5th October 2015
-- Description			: Get Ad Primary Creative File from Creative Master for Outdoor,Circular,Publication,Online Display,Mobile
-- Execution Process	: [dbo].[sp_GetPrimaryCreativeFileForAd] 
-- Updated By			: 
-- ===================================================================================================
Create PROCEDURE [dbo].[sp_GetPrimaryCreativeFileForAd]
(
@adid INT
)
AS
BEGIN
	SET NOCOUNT ON;
         BEGIN TRY
		      select ThmbnlRep+AssetThmbnlName as primarycreativepath from [Creative] 
			  where [AdId]=@adid and PrimaryIndicator=1 and [SourceOccurrenceId] is null
          END TRY 
		   BEGIN CATCH 
				DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT
				SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
				RAISERROR ('[dbo].[sp_GetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END
