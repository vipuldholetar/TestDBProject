



-- =========================================================================================================
-- Author			: Arun Nair  
-- Create date		: 12/29/2015
-- Description		: Get Market  
-- Execution		:[sp_PublicationMultiGetMarket]15
-- Updated By		:
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiGetMarket] 
(
@PublicationId AS INTEGER
)
AS 
BEGIN
	SET NOCOUNT ON;
		
				BEGIN TRY
					SELECT DISTINCT CASE 
					WHEN [Market].Abbrevation IS NULL THEN [Market].[Descrip] 
					ELSE [Market].Abbrevation
					END  as ShortName,
					[Market].[MarketID]	
					FROM PubEdition 
					INNER JOIN [Market] ON PubEdition.[MarketID]=[Market].[MarketID]
					WHERE PubEdition.[PublicationID] =@PublicationId AND ([Market].[EndDT] is null or [EndDT] >= getdate())
					ORDER BY ShortName
				END TRY
				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_PublicationMultiGetMarket]: %d: %s',16,1,@error,@message,@lineNo);
				END CATCH

END
