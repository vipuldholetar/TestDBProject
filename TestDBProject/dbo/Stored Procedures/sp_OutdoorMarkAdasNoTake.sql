
-- ======================================================================
-- Author			: Arun Nair
-- Create date		: 07/10/2015
-- Description		: This stored procedure is used to Mark Adid as Notake Ad
-- Execution Process: [dbo].[sp_OutdoorMarkAdasNoTake]
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorMarkAdasNoTake]
(
	@adId int,
	@notakereasoncode int,
	@UserId Int
	)
AS
BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			Update Ad SET NoTakeAdReason=@notakereasoncode,ModifiedDate=getdate(),ModifiedBy=@UserId WHERE [AdID]=@AdId
		End TRY

	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_OutdoorMarkAdasNoTake: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 

END
