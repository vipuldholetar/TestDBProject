
-- ===========================================================================
-- Author			: Arun Nair 
-- Create date		: 12 August 2015
-- Description		: Get RCS AccountMaster
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=============================================================================
CREATE PROCEDURE sp_LoadRCSAccountMaster
AS
BEGIN
	SET NOCOUNT ON;		
		  BEGIN TRY
				SELECT DISTINCT [RCSAcct].[RCSAcctID] AS RCSAccountID, [RCSAcct].Name AS RCSAccountName
				FROM   [RCSAcct] INNER JOIN	[RCSCreative] ON [RCSAcct].[RCSAcctID] = [RCSCreative].[RCSAcctID]
		  END TRY
		  BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadRCSAccountMaster]: %d: %s',16,1,@error,@message,@lineNo);           
		  END CATCH
END
