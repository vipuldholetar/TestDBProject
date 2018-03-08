CREATE PROCEDURE [dbo].[sp_SavePBSearchAd] 
	@AdID int,
	@MediaStream int,
	@UserId int
	
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 

		INSERT INTO Photoboard
			(AdID,MediaStream,Status,AuditById,AuditDT,Deleted)
			VALUES (@AdID,@MediaStream,'R',@UserId,GETDATE(),0)
	
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_SavePBSearchAd]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END