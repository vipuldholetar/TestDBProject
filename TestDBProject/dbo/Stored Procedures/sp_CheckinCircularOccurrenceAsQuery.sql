-- =============================================
-- Author		: Iyub
-- Create date	: 07 May 2015
-- Description	: CheckIn Data for OccurrenceCheckIn ,CheckIn And Update Query Status 
-- Execution	: sp_CheckinCircularOccurrenceAsQuery
-- Updated		: Arun Nair 11 May 2015
--===================================================
CREATE PROCEDURE [dbo].[sp_CheckinCircularOccurrenceAsQuery]--'M2005705-20440997'
(
@EnvelopeID AS INT,
@MediaTypeID AS INT,
@MarketCode AS INT ,
@PublicationID AS INT,
@DistDate As DATETIME,
@ADDate As DATETIME,
@AdvertiserID AS INT,
@Priority AS INT,
@InternalReferenceNotes AS NVARCHAR(MAX)='',
@PageCount AS INT,
@LanguageID AS INT,
@IsAudit AS BIT , --When CheckInAudit Clicked  CreateFromAuditIndicator =True
@IsQuery bit,
@QueryCategory  varchar(max)='',
@QueryText varchar(max)='',
@QryRaisedBy varchar(max)='',
@QryRaisedOn Datetime
)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY
				BEGIN TRANSACTION 

					-- Check In and Update QueryStatus 
					INSERT INTO [dbo].[OccurrenceDetailCIR] 
						(
							[AdID],
							[AdvertiserID],
							[MediaTypeID],
							[MarketID],
							[PubEditionID],
							[LanguageID],
							[EnvelopeID],
							[PatternID],
							[SubSourceID],
							[DistributionDate],
							[AdDate],
							[Priority],
							[InternalRefenceNotes],
							[Color],
							[SizingMethod],
							[PubPageNumber],
							[PageCount],
							[NoTakeReason],
							[Query],
							[QueryCategory],
							[QueryText],
							[QryRaisedBy],
							[QryRaisedDT],
							[QueryAnswer],
							[QryAnsweredBy],
							[QryAnsweredDT],
							[MapStatusID],
							[IndexStatusID],
							[ScanStatusID],
							[QCStatusID],
							[RouteStatusID],
							[OccurrenceStatusID],
							[CreateFromAuditIndicator],
							[FlyerID],
							[AuditBy],
							[AuditDTM],
							[CreatedDT],
							[CreatedByID],
							[ModifiedDT],
							[ModifiedByID]
							)
							VALUES
							(
							NULL,
							@AdvertiserID,
							@MediaTypeID,
							@MarketCode,
							@PublicationID,
							@LanguageID,
							@EnvelopeID,
							NULL,
							NULL,
							@DistDate,
							@AdDate,
							@Priority,
							@InternalReferenceNotes,
							NULL,
							NULL,
							NULL,
							@PageCount,
							NULL,
							@IsQuery,
							@QueryCategory,
							@QueryText,
							@QryRaisedBy,
							@QryRaisedOn,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							@IsAudit,
							NULL,
							NULL,
							NULL,
							getdate(),
							1,
							NULL,
							NULL						
						)
						
				COMMIT TRANSACTION
				END TRY 
			
	
	 BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_CheckinCircularOccurrenceAsQuery]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 

END