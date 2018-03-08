-- =============================================================================================================
-- Author		: Monika. J
--Modified By :Amrutha
--Modifide date:12/22/2015
-- Create date	: 10/20/2015
-- Description	: This stored procedure is used to get the MASTER data FOR Crop&Route Work Queue.
-- Execution	: [sp_CPGetAdClassificationWorkQueueMasterData]
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetCRWorkQueueMasterData]
AS
BEGIN
	BEGIN TRY
		--USER MASTER DATA
		SELECT 0[VALUE],'ALL'[VALUETITLE]
		UNION ALL
		SELECT USERID [VALUE],FNAME+' '+LNAME [VALUETITLE] FROM [USER] --order by [VALUETITLE]
		--SELECT USERID [VALUE],UserName[VALUETITLE] FROM [User] 		

	END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetCRWorkQueueMasterData: %d: %s',16,1,@error,@message,@lineNo); 
			 -- ROLLBACK TRANSACTION
END CATCH 
END
