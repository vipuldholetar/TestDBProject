

-- ========================================================================================
-- Author		:   Arun Nair
-- Create date	:	25 May 2015
-- Description	:   Update Audit Circular Preview Queue
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value	
--===========================================================================================
CREATE PROCEDURE [dbo].[sp_MarkOccurrenceAsAudit]
(
@OccurrenceID AS  BIGINT,
@AuditBy AS NVARCHAR(MAX)
)
AS
BEGIN
		SET NOCOUNT ON; --Update 
				BEGIN TRY
					BEGIN TRANSACTION
						UPDATE  [dbo].[OccurrenceDetailCIR] SET [AuditBy]=@AuditBy,[AuditDTM]=getdate() WHERE [OccurrenceDetailCIRID]=@OccurrenceID
					COMMIT TRANSACTION
				END TRY 

				BEGIN CATCH
					ROLLBACK TRANSACTION
					 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					 RAISERROR ('[sp_MarkOccurrenceAsAudit]: %d: %s',16,1,@error,@message,@lineNo); 
				END CATCH

END
