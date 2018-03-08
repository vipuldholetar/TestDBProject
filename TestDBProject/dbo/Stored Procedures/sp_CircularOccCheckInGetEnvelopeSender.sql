--===============================================================================
-- Author			: Arun Nair 
-- Create date		: 14 Sep 2015
-- Execution		: [dbo].[sp_CircularOccCheckInGetEnvelopeSender] 6093
-- Description		: Get Sender based on EnvelopeId 
-- Updated By		: 
--					  
--================================================================================
CREATE PROCEDURE [dbo].[sp_CircularOccCheckInGetEnvelopeSender]
(
@EnvelopeId AS INTEGER
)
AS
BEGIN
	
		SET NOCOUNT ON;	    
		BEGIN TRY
			SELECT [User].fname+' '+ [User].lname as loadedby,
			Sender.[SenderID],
			Sender.Name,
			Sender.Priority,
			Sender.IndNoPublications,
			[Envelope].[EnvelopeID] 
			FROM Sender INNER JOIN
			[Envelope] ON Sender.[SenderID] = [Envelope].[SenderID] INNER JOIN [User] on [user].userid=[Envelope].[ReceivedByID]
			WHERE       ([Envelope].[EnvelopeID] = @EnvelopeId) ORDER BY Sender.Name
		END TRY 
		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[dbo].[sp_CircularOccCheckInGetEnvelopeSender]: %d: %s',16,1,@error,@message,@lineNo);		
		END CATCH 
END
