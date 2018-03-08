-- ======================================================================
-- Author			: KARUNAKAR
-- Create date		: 09/28/2015
-- Description		: This stored procedure is used to Mark Adid as Notake Ad
-- Execution Process: [dbo].[sp_OnlineVideoMarkAdasNoTake]
-- =======================================================================
Create PROCEDURE [dbo].[sp_OnlineVideoMarkAdasNoTake]
	@AdId int,
	@NoTakeReasonCode int
AS
BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			UPDATE Ad set NoTakeAdReason=@NoTakeReasonCode where Ad.[AdID]=@AdId
		END TRY
	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_OnlineVideoMarkAdasNoTake: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END
