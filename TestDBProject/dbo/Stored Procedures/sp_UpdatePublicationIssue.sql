-- ============================================= 
-- Author		: Arun Nair 
-- Create date	: 10 June 2015 
-- Execution	: [dbo].[sp_UpdatePublicationIssue]
-- Description	: Update Data for Publication Issue
-- Updated By	:
--=================================================== 

CREATE PROCEDURE [dbo].[sp_UpdatePublicationIssue]
(
@PubIssueID AS INT,
@EnvelopeID AS INT,
@SenderID AS INT,
@PubEditionID AS INT,
@ShippingMethodID AS INT,
@PkgTypeID AS INT,
@IssueDate AS DATETIME,
@TrackingNumber AS NVARCHAR(MAX),
@PrintedWeight AS float,
@ActualWeight AS float,
@PackageAssignment AS NVARCHAR(MAX),
@NoTakeReason AS NVARCHAR(MAX),
@CpnOccurrenceID AS INT,
@ReceiveOn AS DATETIME,
@ReceiveBy NVARCHAR(MAX),
@IssueCompleteIndicator AS BIT,
@IssueAuditedIndicator AS BIT,
@Status AS NVARCHAR(MAX),
@IsQuery AS BIT,
@QueryCategory AS NVARCHAR(MAX),
@QueryText AS NVARCHAR(MAX),
@QryRaisedBy AS NVARCHAR(MAX),
@QryRaisedOn AS DATETIME,
@QueryAnswer AS NVARCHAR(MAX),
@QryAnsweredBy NVARCHAR(MAX),
@QryAnsweredOn AS DATETIME,
@AuditBy AS NVARCHAR(MAX),
@AuditDTM AS NVARCHAR(MAX),
@CreateDTM AS DATETIME,
@CreateBy AS INT,
@ModifiedDTM AS DATETIME,
@ModifiedBy AS INT
)
AS
BEGIN
		SET NOCOUNT ON; ---Update Pubissue 
			BEGIN TRY
				BEGIN TRANSACTION
				UPDATE [dbo].[PubIssue]
				 SET 
					[EnvelopeID]=@EnvelopeID,
					[SenderID]=@SenderID,
					[PubEditionID]=@PubEditionID,
					[ShippingMethodID]=@ShippingMethodID,
					[PackageTypeID]=@PkgTypeID,
					[IssueDate]=@IssueDate,
					[TrackingNumber]=@TrackingNumber,
					[PrintedWeight]=@PrintedWeight,
					[ActualWeight]=@ActualWeight,
					[PackageAssignment]=@PackageAssignment,
					[NoTakeReason]=@NoTakeReason,
					[CpnOccurrenceID]=@CpnOccurrenceID,
					[ReceiveOn]=@ReceiveOn,
					[ReceiveBy]=@ReceiveBy,
					[IssueCompleteIndicator]=@IssueCompleteIndicator,
					[IssueAuditedIndicator]=@IssueAuditedIndicator,
					[Status]=@Status,
					[IsQuery]=@IsQuery,
					[QueryCategory]=@QueryCategory,
					[QueryText]=@QueryText,
					[QryRaisedBy]=@QryRaisedBy,
					[QryRaisedOn]=@QryRaisedOn,
					[QueryAnswer]=@QueryAnswer,
					[QryAnsweredBy]=@QryAnsweredBy,
					[QryAnsweredOn]=@QryAnsweredOn,
					[AuditBy]=@AuditBy,
					[AuditDTM]=@AuditDTM,
					[CreateDTM]=@CreateDTM,
					[CreateBy]=@CreateBy,
					[ModifiedDTM]=@ModifiedDTM,
					[ModifiedBy]=@ModifiedBy
					WHERE [dbo].[PubIssue].[PubIssueID]=@PubIssueID
				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				  DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
				  RAISERROR ('sp_UpdatePublicationIssue: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION 
			END CATCH



END
