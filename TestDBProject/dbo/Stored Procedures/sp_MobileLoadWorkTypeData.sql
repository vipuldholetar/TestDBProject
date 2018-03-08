
-- ===========================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 10/1/2015
-- Description	: Get Select Type
-- Execution	: [dbo].[sp_MobileLoadWorkTypeData]
-- Updated By	:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_MobileLoadWorkTypeData]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			--SELECT  WorkType FROM [dbo].[vw_MobileWorkQueueSessionData] Where WorkType='Ingestion' or WorkType='adhoc'
			SELECT value as WorkTypeID,valuetitle as WorkType from [Configuration] where valuetitle='Ingestion' or valuetitle='adhoc'
		END TRY

		BEGIN CATCH 
			  DECLARE @Error  INT,@Message VARCHAR(4000),@LineNo  INT 
			  SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
			  RAISERROR ('[sp_MobileLoadWorkTypeData]: %d: %s',16,1,@Error,@Message,@LineNo); 
		 END CATCH 
END
