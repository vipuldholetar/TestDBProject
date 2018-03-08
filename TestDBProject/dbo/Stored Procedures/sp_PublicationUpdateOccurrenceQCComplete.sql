


-- ======================================================================================
-- Author		: 
-- Create date	: 
-- Description	: 
-- Updated By	: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationUpdateOccurrenceQCComplete]
	@OccurrenceID as BigInt
AS
BEGIN
	SET NOCOUNT ON;
			
			BEGIN TRY
				BEGIN TRANSACTION
				declare @CompleteStatusID int
				select @CompleteStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 
				Update [OccurrenceDetailPUB] set QCStatusID = @CompleteStatusID where [OccurrenceDetailPUBID]=@OccurrenceID
				--Updating Occurrence Stage Status for Publication 
				Exec Sp_updatepublicationoccurrencestagestatus @OccurrenceID,4	
				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('sp_PublicationUpdateOccurrenceQCComplete: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
			END CATCH


END