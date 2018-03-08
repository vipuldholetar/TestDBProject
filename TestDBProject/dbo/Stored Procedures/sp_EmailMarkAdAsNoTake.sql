

-- ==============================================================================================
-- Author		: Arun Nair
-- Create date	: 10/20/2015
-- Description	: Mark Adid as Notake Ad in Email
-- UpdatedBy	: 
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailMarkAdAsNoTake] 
(
	@AdId int,
	@NoTakeReasonCode int,
	@UserId int
)
AS
BEGIN	
	SET NOCOUNT ON;

		   BEGIN TRY
				Update Ad SET NoTakeAdReason=@NoTakeReasonCode,ModifiedDate=getdate(),ModifiedBy=@userid WHERE [AdID]=@AdId
		   END TRY
		   BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailMarkAdAsNoTake]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END
