
-- =============================================
-- Author:		SURESH N
-- Create date: 07/12/2015
-- Description:	Check Creative Exists or Not
-- Execution :  Exec [sp_CheckIfCreativeExists] 1500002
-- =============================================
CREATE PROCEDURE [dbo].[sp_CheckIfCreativeExists]
	-- Add the parameters for the stored procedure here
		@OccurrenceID BIGINT
AS
BEGIN
	DECLARE @STREAM VARCHAR(20)
	
	SET NOCOUNT ON;
		BEGIN TRY
		
		SET @STREAM=(SELECT dbo.fn_GetMediaStream(@OccurrenceID));
		print @STREAM
		 SELECT dbo.[fn_GetCreativePath](@OccurrenceID,@STREAM) as result
	
		END TRY
		BEGIN CATCH
		   DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_CheckIfCreativeExists]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
		END CATCH
  
END
