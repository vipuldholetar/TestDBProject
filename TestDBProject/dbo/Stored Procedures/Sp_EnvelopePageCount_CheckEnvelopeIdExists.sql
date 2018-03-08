
-- ====================================================================================================================================
-- Author                :  Ganesh Prasad  
-- Create date           :  01/19/2016  
-- Description           :  Check if Envelope Exists
-- Execution Process     : [dbo].[Sp_EnvelopePageCount_CheckEnvelopeIdExists]  99999999999999999999999
-- Updated By            :  Arun Nair on 02/12/2016 - altered sp to Check if Envelope Exists 
-- =============================================================================================================

CREATE PROCEDURE [dbo].[Sp_EnvelopePageCount_CheckEnvelopeIdExists]
(
@EnvelopeId AS INT
)
AS
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT * FROM [Envelope] Where [EnvelopeID]=@EnvelopeId )
			BEGIN
				SELECT 1 AS Result --Exists
			END
		ELSE
			BEGIN
				SELECT 0 As Result --Not Exists
			END 				
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[dbo].[Sp_EnvelopePageCount_CheckEnvelopeIdExists]: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH 

END
