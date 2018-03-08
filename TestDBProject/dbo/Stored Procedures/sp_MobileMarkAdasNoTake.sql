
-- ======================================================================
-- Author			: Karunakar
-- Create date		: 6th October 2015
-- Description		: This stored procedure is used to Mark Ad as Notake Ad
-- Execution Process: [sp_MobileMarkAdasNoTake] 
-- Updated By		: 
-- =======================================================================
Create PROCEDURE [dbo].[sp_MobileMarkAdasNoTake]
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
			RAISERROR ('sp_MobileMarkAdasNoTake: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END
