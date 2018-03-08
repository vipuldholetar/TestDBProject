

-- ===========================================================================================
-- Author			:	Karunakar
-- Create date		:	7/29/2015
-- Description		:	This stored procedure is used to Updating Alternative Creative Exception
-- Execution		:	sp_ExceptionUpdateAlternateCreative 2
-- Updated By		:	Karunakar on 7th Sep 2015
-- ============================================================================================

 CREATE  PROCEDURE [dbo].[sp_ExceptionUpdateAlternateCreative]  
 (
 @ExceptionId As Int
 )
 AS
 BEGIN
		BEGIN TRY		
			--	Updating ExceptionDetails for ExceptionStatus
			Update [ExceptionDetail] Set ExceptionStatus='Requested' Where [ExceptionDetailID]=@ExceptionId
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_ExceptionUpdateAlternateCreative]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
 END
