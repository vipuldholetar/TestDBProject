-- =============================================
-- Author			:	Karunakar		
-- Create date		:	30th December 2015
-- Description		:	This Procedure is used for getting Publication DefaultSizingMethod from RateCard table
-- =============================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFGetDefaultPubSizingMethod] 
	(
	@publicationid as Int	
	)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 

	--Selecting DefaultSizingMethod from RateCard
	SELECT TOP 1 DefaultSizingMethod FROM RateCard
	WHERE [PublicationID]=@publicationid

	END TRY
	 BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number() 
                 ,@message = Error_message() 
                 ,@lineNo = Error_line() 

          RAISERROR ('sp_PublicationDPFGetDefaultPubSizingMethod: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH
END
