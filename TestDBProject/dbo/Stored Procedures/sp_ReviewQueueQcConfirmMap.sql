-- =============================================
-- Author		:	Karunakar
-- Create date	:	1st September 2015
-- Description	:	This Procedure is Used to Qc Map Index in Review Queue
--				:	1.Confirm the Map of Pattern QC.
-- =============================================
CREATE PROCEDURE sp_ReviewQueueQcConfirmMap
	@PatternmasterId as Int,
	@AuditBy as Int
AS
BEGIN

	SET NOCOUNT ON;

		Update [Pattern] Set AuditBy=@AuditBy,AuditDate=getdate() Where [PatternID]=@PatternmasterId
   
END
