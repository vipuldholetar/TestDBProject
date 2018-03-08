-- =======================================================================
-- Author		: Arun,Suresh
-- Create date	: 12/30/2015
-- Description	: Get distinct market count 	
-- Execution	: [sp_PublicationMultiEditionGetDistinctMarketsCount] 1
-- Updated By	: 
-- ========================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionGetDistinctMarketsCount] 
(
@PublicationId AS INTEGER
)
AS 
BEGIN
	SET NOCOUNT ON;
					
				BEGIN TRY					
					SELECT Count(Distinct(PubEdition.PubEditionID))
					FROM PubEdition 
					INNER JOIN [Market] ON PubEdition.[MarketID]=[Market].[MarketID]
					WHERE PubEdition.[PublicationID] =@PublicationId 
					
				END TRY 

				BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_PublicationMultiEditionGetMarketsCount]: %d: %s',16,1,@error,@message,@lineNo);
				END CATCH

END
