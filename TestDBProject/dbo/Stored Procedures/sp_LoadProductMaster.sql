-- ===========================================================================

-- Author			:Govardhan

-- Create date		:12 Aug 2015

-- Description		:Get  Product Values
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadProductMaster]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY

			SELECT DISTINCT RP.[RefProductID][ID],RP.PRODUCTNAME[NAME] FROM AD a,REFPRODUCT rp 
			WHERE a.PRODUCTID=RP.[RefProductID] order by RP.PRODUCTNAME asc

		END TRY

		BEGIN CATCH 

			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			  RAISERROR ('[sp_LoadProductMaster]: %d: %s',16,1,@error,@message,@lineNo); 			  

		END CATCH 

END
