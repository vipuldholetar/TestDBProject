
-- ============================================================================
-- Author			: Arun Nair 
-- Create date		: 09/29/2015
-- Description		: Get Exception Market
-- Execution Process: [sp_LoadMarket] 4824
-- Updated By		: 
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_LoadMarket]
(
@SenderId AS INT
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY		
		SELECT a.[MarketID],a.[Descrip],a.[StartDT],a.[EndDT]  FROM [Market] a INNER JOIN SenderMktAssoc b  ON a.[MarketID] = b.[MktID]
			WHERE  b.[SenderID] =@SenderId  AND a.[StartDT] <= GETDATE() AND (a.[EndDT] >= GETDATE()  or a.[EndDT] is null)
			ORDER BY 2
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('[sp_LoadMarket]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END
