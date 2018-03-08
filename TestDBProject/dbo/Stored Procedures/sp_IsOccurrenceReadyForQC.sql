-- =========================================================================================
-- Author		:Karunakar
-- Create date	:20th May 2015
-- Description	:Checking OccurrenceID QC Status and Return Status Yes/No
-- Exec			 SP_IsOccurrenceReadyForQC 1
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_IsOccurrenceReadyForQC]
	@OccurrenceID as Bigint
AS
BEGIN
	
SET NOCOUNT ON;
	BEGIN TRY
		Declare @IsQcStatus As Varchar(50)
		IF EXISTS(SELECT [OccurrenceDetailCIRID] FROM [OccurrenceDetailCIR] 
				WHERE (QCStatusID = 3 or QCStatusID = 1 and IndexStatusID = 1 or IndexStatusID = 4 and ScanStatusID = 1 or ScanStatusID = 4) 
				and [OccurrenceDetailCIRID]=@OccurrenceID) 
				 BEGIN 
						SELECT @IsQcStatus='Yes' 
				 END 
				 ELSE 
				 BEGIN 
						SELECT @IsQcStatus='No' 
				 END 

				 SELECT @IsQcStatus As QCStatus
		END TRY

	BEGIN CATCH
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[dbo].[sp_IsOccurrenceReadyForQC ]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH

END