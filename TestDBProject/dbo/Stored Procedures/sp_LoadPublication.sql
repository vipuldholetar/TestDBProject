
-- =================================================================================
-- Author			: Arun Nair 
-- Create date		: 09/29/2015
-- Description		: Get Exception Market
-- Execution Process: [sp_LoadPublication] 50
-- Updated By		: Karunakar on 1st Oct 2015,Load Publication  based on SenderId
--					: Arun Nair 
-- ===================================================================================

CREATE PROCEDURE [dbo].[sp_LoadPublication]
(
--@SenderId AS INT
@MarketId AS INT
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY		
				--------------------------------------------------------------------------------------------------------------------------------------------
				--Load Publication Based On SenderID --Karunakar on 1st Oct 2015,Load Publication  based on SenderId	to be Removed As per Circular SRD
				--SELECT PK_PublicationId,publication.descrip	FROM Publication iNNER JOIN  SenderPublication
				--ON Publication.PK_PublicationId=SenderPublication.PublicationId	WHERE publication.startdt<=GETDATE() and publication.enddt>=GETDATE() 
				--AND SenderPublication.SenderId = @SenderId	 
				--------------------------------------------------------------------------------------------------------------------------------------------

				--Load Publication Based On MarketId
				SELECT DISTINCT a.Descrip, a.[PublicationID] FROM Publication a INNER JOIN PubEdition b ON a.[PublicationID] = b.[PublicationID]
				 AND b.[MarketID] = @MarketId AND a.[StartDT] <= GETDATE() AND (a.[EndDT] >= GETDATE() or a.[EndDT] is null)  ORDER BY 1				 			
		END TRY
		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
			RAISERROR ('[sp_LoadPublication]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 
END
