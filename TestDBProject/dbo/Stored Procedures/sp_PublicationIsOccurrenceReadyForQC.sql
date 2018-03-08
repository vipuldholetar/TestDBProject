
-- =========================================================================================
-- Author		:Arun Nair
-- Create date	:12/06/2015
-- Description	:Checking OccurrenceID QC Status and Return Status Yes/No
-- Exec			:sp_PublicationIsOccurrenceReadyForQC 1
-- Updated By	: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationIsOccurrenceReadyForQC]
	@OccurrenceID as Bigint
AS
BEGIN
	
	SET NOCOUNT ON;
			BEGIN TRY
			DECLARE @IsQcStatus As VARCHAR(50)

			IF EXISTS(SELECT [OccurrenceDetailPUBID] FROM [OccurrenceDetailPUB] WHERE 
			(QCStatusID = 3 or QCStatusID = 1 and IndexStatusID = 1 or IndexStatusID = 4 and ScanStatusID = 1 or ScanStatusID = 4) 
			and [OccurrenceDetailPUBID]=@OccurrenceID) 
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
			      RAISERROR ('sp_PublicationIsOccurrenceReadyForQC: %d: %s',16,1,@error,@message,@lineNo)   ; 				
			END CATCH

END