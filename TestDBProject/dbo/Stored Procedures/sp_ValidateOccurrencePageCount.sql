
-- ============================================================
-- Author		: Arun Nair
-- Create date	: 07/12/2015
-- Description	: Check Occurance ID Exists or Not
-- Execution	: Exec sp_ValidateOccurrencePageCount 510002
-- ===========================================================
CREATE PROCEDURE [dbo].[sp_ValidateOccurrencePageCount]      
 @OccurrenceID BIGINT
AS
BEGIN
       DECLARE @STREAM VARCHAR(20)
       DECLARE @RESULT INT
       SET NOCOUNT ON;
              BEGIN TRY
              
              SET @STREAM=(SELECT dbo.fn_GetMediaStream(@OccurrenceID));
                          
            
			    IF @STREAM='CIR'   --Page Count for OccurrenceDetailsCIR
				BEGIN
					SET  @RESULT= (SELECT PageCount FROM   [OccurrenceDetailCIR] WHERE  [OccurrenceDetailCIRID] =@OccurrenceID) 
				END             
				 IF @STREAM='PUB'  --Page Count for OccurrenceDetailsPUB
				BEGIN
					 SET  @RESULT= (SELECT PageCount FROM   [OccurrenceDetailPUB] WHERE  [OccurrenceDetailPUBID] = @OccurrenceID) 
				END
				IF @STREAM='EM'  --Page Count for OccurrenceDetailsPUB
				BEGIN
					 SET  @RESULT= 1 
				END
				IF @STREAM='WEB'  --Page Count for OccurrenceDetailsWEB
				BEGIN
					 SET  @RESULT= 1
				END
				IF @STREAM='SOC'  --Page Count for OccurrenceDetailsSOC
				BEGIN
					 SET  @RESULT= 1
				END    

				SELECT @RESULT
              END TRY
              BEGIN CATCH
					DECLARE @ERROR   INT,@MESSAGE VARCHAR(4000),@LINENO  INT 
					SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
					RAISERROR ('[sp_ValidateOccurrencePageCount]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
              END CATCH
  
END
