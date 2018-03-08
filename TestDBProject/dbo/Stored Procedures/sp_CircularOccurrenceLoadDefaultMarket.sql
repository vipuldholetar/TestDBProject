
-- ===================================================================
-- Author			: Arun Nair 
-- Create date		: 09/28/2015
-- Description		: Select Default MarketValue to OccurrenceCheckin
-- Execution Process: 
-- Updated By		: 
-- ====================================================================

CREATE PROCEDURE [dbo].[sp_CircularOccurrenceLoadDefaultMarket]
(
@EnvelopeID AS INTEGER
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY		
		Select [MarketID],[Descrip] from [Market] where [MarketID] 
		IN 
		 (
		   SELECT  Sender.[DefaultMktID] FROM Sender
		   INNER JOIN [Envelope] ON Sender.[SenderID] = [Envelope].[SenderID] AND [Envelope].[EnvelopeID]= @EnvelopeID
		 )
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('[sp_CircularOccurrenceLoadDefaultMarket]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END
