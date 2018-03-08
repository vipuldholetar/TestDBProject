
-- =============================================
-- Author		:   Arun Nair
-- Create date	:	25 May 2015
-- Description	:   Load UserData Values
-- Updated By	:	
--===================================================

CREATE PROCEDURE [dbo].[sp_GetUserDataForCircularReviewQueue]
AS 
BEGIN
			SET NOCOUNT ON;--Load Circular Review Queue User Data	
				BEGIN TRY
					SELECT UserID,Fname+' '+LName AS [UserName] FROM [dbo].[USER] WHERE ActiveInd=1
				END TRY

		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_GetUserDataForCircularReviewQueue]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH

END
