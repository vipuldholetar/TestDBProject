-- ======================================================================
-- Author			: Arun Nair
-- Create date		: 07/28/2015
-- Description		: This stored procedure is used to Mark Adid as Notake Ad
-- Execution Process: [dbo].[sp_TelevisionMarkAdasNoTake]
-- Updated By		: Arun on 08/13/2015 -Cleanup OnemT 
-- =======================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionMarkAdasNoTake]
	@AdId int,
	@NoTakeReasonCode int,
	@userId Int
AS
BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			UPDATE Ad set NoTakeAdReason=@NoTakeReasonCode, ModifiedDate=Getdate(),ModifiedBy=@UserId where Ad.[AdID]=@AdId
		END TRY
	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_TelevisionMarkAdasNoTake: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END
