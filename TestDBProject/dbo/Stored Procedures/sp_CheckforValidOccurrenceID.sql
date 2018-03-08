-- =============================================
-- Author:           SURESH N
-- Create date: 07/12/2015
-- Description:      Check Occurance ID Exists or Not
-- Execution :  Exec sp_CheckIfOccuranceExists 26
-- =============================================
Create PROCEDURE sp_CheckforValidOccurrenceID
       -- Add the parameters for the stored procedure here
              @OccurrenceID BIGINT
AS
BEGIN
       DECLARE @STREAM VARCHAR(20)
       DECLARE @RESULT BIT
       SET NOCOUNT ON;
              BEGIN TRY
              
              SET @STREAM=(SELECT dbo.fn_GetMediaStream(@OccurrenceID));
                            
              SELECT CASE 
              --Checks OccurrenceID Exists in Circular OccurrenceDetails
        WHEN @STREAM='CIR' THEN (SELECT CASE WHEN EXISTS(SELECT 1 FROM   [OccurrenceDetailCIR] WHERE  [OccurrenceDetailCIRID] = @OccurrenceID) THEN 1 ELSE 0 END AS RESULT) 
              --Checks OccurrenceID Exists in Publisher OccurrenceDetails
              WHEN @STREAM='PUB' THEN (SELECT CASE WHEN EXISTS(SELECT 1 FROM [OccurrenceDetailPUB] WHERE [OccurrenceDetailPUBID]=@OccurrenceID) THEN 1 ELSE 0 END AS RESULT) 
              --Checks OccurrenceID Exists in Email OccurrenceDetails
              WHEN @STREAM='EM' THEN (SELECT CASE WHEN EXISTS(SELECT 1 FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceID) THEN 1 ELSE 0 END AS RESULT) 
              --Checks OccurrenceID Exists in Website OccurrenceDetails
              WHEN @STREAM='WEB' THEN (SELECT CASE WHEN EXISTS(SELECT 1 FROM [OccurrenceDetailWEB] WHERE [OccurrenceDetailWEBID]=@OccurrenceID) THEN 1 ELSE 0 END AS RESULT) 
              --Checks OccurrenceID Exists in Social OccurrenceDetails
              WHEN @STREAM='SOC' THEN (SELECT CASE WHEN EXISTS(SELECT 1 FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceID) THEN 1 ELSE 0 END AS RESULT) 
    
       END

              END TRY
              BEGIN CATCH
                 DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_CheckforValidOccurrenceID]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
              END CATCH
  
END
