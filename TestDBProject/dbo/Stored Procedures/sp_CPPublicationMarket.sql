-- =========================================================================================================

-- Author			: S Dinesh Karthick  

-- Create date		: 1/19/2016

-- Description		: Get Market  

-- Execution		:[sp_CPPublicationMarket]1

-- Updated By		:

-- ===========================================================================================================

CREATE  PROCEDURE   [dbo].[sp_CPPublicationMarket] 
(
@PublicationId AS nvarchar(max)
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
					WHERE PubEdition.[PublicationID] in (Select Distinct Id from [dbo].[fn_CSVToTable](@PublicationId)) AND [Market].[EndDT] >= getdate()
					ORDER BY ShortName
				END TRY
				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_CPPublicationMarket]: %d: %s',16,1,@error,@message,@lineNo);
				END CATCH
END
