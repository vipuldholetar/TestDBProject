
-- =============================================
-- Author		:		SURESH N
-- Create date	:		11/01/2016
-- Description	:		GetMapModReasons
-- Execution	:		[sp_GetMapModReasons]
-- Updated By   : 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetMapModReasons]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    BEGIN TRY
	SELECT [MadMODControlID] AS MODId
      ,[MapModReason]
            ,[ConditionCODE] AS MapModConditionID
      ,(case when [NewRevYesInd] is not NULL then 1 else 0 end) AS [NewRevYesInd]
      ,(case when [MapAdYesInd] is not NULL then 1 else 0 end) AS [MapAdYesInd]
      ,(case when [ScanReqYesInd] is not NULL then 1 else 0 end) AS [ScanReqYesInd]
      ,[AppendDescYesCODE]
      ,[AppendTextYes]
      ,(case when [NewRevNoInd] is not NULL then 1 else 0 end) AS [NewRevNoInd]
      ,(case when [MapAdNoInd] is not NULL then 1 else 0 end) AS [MapAdNoInd]
      ,(case when [ScanReqNoInd] is not NULL then 1 else 0 end) AS [ScanReqNoInd]
      ,[AppendDescNoCODE]
      ,[AppendTextNo] FROM [dbo].[MapMODControl] 
	END TRY
	BEGIN CATCH
	  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
      SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
      RAISERROR ('sp_GetMapModReasons: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH
END
