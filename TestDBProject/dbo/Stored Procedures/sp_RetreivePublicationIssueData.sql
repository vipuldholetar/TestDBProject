-- =============================================

-- Author:		Arun Nair

-- Create date: 06/09/2015

-- Description:	Retreive Pub Issue data Based on PubIssueID

-- Exec 

-- =============================================

CREATE PROCEDURE [dbo].[sp_RetreivePublicationIssueData] --5093

(

@IssueId As INT

)

AS

BEGIN

		SET NOCOUNT ON;

		 SET NOCOUNT ON; 

			BEGIN TRY

		SELECT 

			 [PubIssueID],

			[dbo].[Publication].[PublicationID],

			[EnvelopeID],

			[SenderID],

			pubEdition.[PubEditionID],

			[dbo].[ShippingMethod].[ShipperID],

			[dbo].[ShippingMethod].[ShippingMethodID],

			[PackageTypeID],

			[IssueDate],

			[TrackingNumber],

			[PrintedWeight],

			[ActualWeight],

			[PackageAssignment],

			[NoTakeReason],

			[CpnOccurrenceID],

			[ReceiveOn],

			[IssueCompleteIndicator],

			[IssueAuditedIndicator],

			[Status],

			[IsQuery],

			[QueryCategory],

			[QueryText],

			[QryRaisedBy],

			[QryRaisedOn],

			[QueryAnswer],

			[QryAnsweredBy],

			[QryAnsweredOn],

			[AuditBy],

			[AuditDTM],

			[dbo].[PubIssue].[CreateDTM],

			[dbo].[PubIssue].[CreateBy],

			[dbo].[PubIssue].[ModifiedDTM],

			[dbo].[PubIssue].[ModifiedBy],

			[dbo].[Publication].[Comments],

			[dbo].[USER].USERID,[dbo].[USER].fname+' '+[dbo].[USER].lname as Username, [dbo].[Publication].Descrip as PublicationDescription,[dbo].[Publication].priority as Publicationpriority

		FROM [dbo].[PubIssue]

		 INNER JOIN [dbo].[PubEdition] ON [dbo].[PubIssue].[PubEditionID]=[dbo].[PubEdition].[PubEditionID]

		 INNER JOIN [dbo].[Publication] ON [dbo].[Publication].[PublicationID] =[dbo].[PubEdition].[PublicationID] 

		 INNER JOIN  [dbo].[USER] ON [dbo].[USER].USERID=[dbo].[PubIssue].[CreateBy]

		 LEFT JOIN [dbo].[ShippingMethod] ON [dbo].[ShippingMethod].[ShippingMethodID]=[dbo].[PubIssue].[ShippingMethodID]

		 LEFT JOIN [dbo].[Shipper] ON [dbo].[Shipper] .[ShipperID] =[dbo].[ShippingMethod].[ShipperID]

		  WHERE  [PubIssueID]=@IssueId



		  END TRY 

		BEGIN CATCH

				  DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 

				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()

				  RAISERROR ('sp_RetreivePublicationIssueData: %d: %s',16,1,@error,@message,@lineNo); 

				  ROLLBACK TRANSACTION 

		END CATCH

END
