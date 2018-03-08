
-- =========================================================================
-- Author		: Arun Nair  
-- Create date  : 17/June/2015  
-- Description  : Load Data for Pub Issue CheckIn based on Parent Envelope
-- Updated By	:  
--==========================================================================
CREATE PROCEDURE sp_PublicationGetParentEnvelope-- 2017
(
@EnvelopeId AS INTEGER
)
AS 
BEGIN
		  SET nocount ON; 

			BEGIN TRY
				SELECT [EnvelopeID],ActualWeight,FormName,ListedWeight,[EnvelopeID],[PackageAssignmentID],[PackageTypeID],
				[ReceivedByID],[ReceivedDT],[SenderID],[ShipperID],[ShippingMethodID],[TrackingNumber]
				FROM [Envelope]
				WHERE([EnvelopeID] = @EnvelopeId)
			END TRY

			BEGIN CATCH
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_PublicationGetParentEnvelope: %d: %s',16,1,@error,@message,@lineNo); 
			END CATCH

END
