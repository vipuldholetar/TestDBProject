-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 07 May 2015 
-- Execution		: [dbo].[sp_UpdateCircularOccurrenceAsNoTake]
-- Description		: Update Circular Occurrence as NoTake
-- Updated By		: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--					: Karunakar on 09/11/2015
--================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateCircularOccurrenceAsNoTake]
 ( 
 @OccurrenceList AS VARCHAR(100),
 @Configurationid AS INTEGER
 ) 
AS 
  BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY 
			BEGIN TRANSACTION 
				--Updating Occurrencedetailcir for Occurrence Status
				declare @NoTakeStatusID int
				select @NoTakeStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
				UPDATE [OccurrenceDetailCIR] set OccurrenceStatusID = @NoTakeStatusID , 
				notakereason=(SELECT value FROM [Configuration] WHERE configurationid=@configurationID) 
				WHERE [OccurrenceDetailCIRID] in (@OccurrenceList)   
			COMMIT TRANSACTION 
    END TRY 
    BEGIN CATCH 
			DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_UpdateCircularOccurrenceAsNoTake]: %d: %s',16,1,@error,@message,@lineNo); 
			ROLLBACK TRANSACTION 
    END CATCH 
  END