
-- =============================================================================================
-- Author			: Karunakar
-- Create date		: 20th May 2015
-- Description		: Updating OccureenceId QC Status
-- Exec				: SP_UpdateOccurrenceQCComplete 550055,29712040
-- Updated By		: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--					: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateOccurrenceQCComplete]
	@OccurrenceID as bigint,
	@UserID as INT
AS
BEGIN
	SET NOCOUNT ON;			
			BEGIN TRY
				BEGIN TRANSACTION

				DECLARE @Status AS BIT=0

				declare @CompleteStatusID int
				select @CompleteStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

				--Updating QC Status--
				Update [OccurrenceDetailCIR] 
				set QCStatusID = @CompleteStatusID 
				where [OccurrenceDetailCIRID] = @OccurrenceID
				
				--Updating Occrrence Status
				EXEC  Sp_updateoccurrencestagestatus @OccurrenceID, 4

				--Updating Coupon Book data
				EXEC @Status=sp_CircularUpdateCouponDataforPubissue @OccurrenceID,@UserID
				
				SELECT @Status	as [Status]			 		
				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
					 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('SP_UpdateOccurrenceQCComplete: %d: %s',16,1,@error,@message,@lineNo)   ; 
					ROLLBACK TRANSACTION 
			END CATCH


END