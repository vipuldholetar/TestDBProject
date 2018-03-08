-- =============================================
-- Author:		Monika. J
-- Create date: 12/07/15
-- Description:	To Get User ID
-- Excecution: sp_CPGetUserIDForCRDEtails 'INDCORP\\850016455'
-- select * from [User]
-- =============================================
CREATE PROCEDURE sp_CPGetUserIDForCRDEtails 
	-- Add the parameters for the stored procedure here
	@UserName NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @UserNm nvarchar(max)

		SET @UserNm = REPLACE(@UserName,'\\','\')
		Select UserID from [User] where UserName=@UserNm
	END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetUserIDForCRDEtails: %d: %s',16,1,@error,@message,@lineNo); 
			  
END CATCH 
END
