


-- ============================================================================================================
-- Author		: Arun Nair 
-- Create date	: 11 JUNE 2015 
-- Description	: Create a New Occurrence based on Ad For Publication
-- Updated By	: Karaunakar 06/15/2015
-- Updated By	: Updated Changes Based on Configuration Master table LOV on 01 july 2015 By Karunakar 
--				: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--===============================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFMapAdToOccurrence] ---2003,9,27,3,29711029
(
@AdId			As INTEGER,
@PubIssueId		as INTEGER,
@MediaTypeId	as INTEGER,
@LanguageId		as INTEGER,
@MediaStreamId	as INTEGER,
@MarketId		as INTEGER,
@SubSourceId	as INTEGER,
@ADDate			as DATETIME,
@DistDate		AS DATETIME,
@SaleStartDate	AS DATETIME,
@SaleEndDate	AS DATETIME,
@AdvertiserID	AS INTEGER,
@InternalReferenceNotes  AS NVARCHAR(max), 
@PageCount      AS INTEGER,
@PubPageNumber  As NVARCHAR(max),
@National		AS BIT, 
@Flash			AS BIT, 
@EventId		As INTEGER,
@ThemeId		As INTEGER,
@color			As NVARCHAR(50),         
@Priority		As INTEGER,
@SizingMethod	As NVARCHAR(max),
@NotakeReason   As NVARCHAR(max),
@UserId			AS INTEGER 
)
AS
BEGIN
		SET NOCOUNT ON;
					
					BEGIN TRY
						BEGIN TRANSACTION
							Declare @OccurrenceId As BigInt
							DECLARE @PatternMasterID AS INTEGER
							Declare @OccurrenceStatus AS NVARCHAR(Max)
							Declare @MapIndexStatus AS NVARCHAR(Max)
							Declare @ScanQCStatus AS NVARCHAR(Max)
							 
							--SELECT @MapIndexStatus=valuetitle FROM [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'	
							declare @MapIndexStatusID int
							select @MapIndexStatusID = os.[OccurrenceStatusID] 
							from OccurrenceStatus os
							inner join Configuration c on os.[Status] = c.ValueTitle
							where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

							SELECT @PatternMasterID=[PatternID] FROM [dbo].[Pattern] WHERE [AdID]=@AdId

						INSERT INTO [dbo].[OccurrenceDetailPUB] 
							 (
								[AdID],[MediaTypeID],[MarketID],[PubIssueID],[PatternID],[SubSourceID],[AdDT],[Priority],
								[InternalRefenceNotes],[Color],[SizingMethod],[PubPageNumber],[PageCount],[NoTakeReason],[Query],[QueryCategory],
								[QueryText],[QryRaisedBy],[QryRaisedDT],[QueryAnswer],[QryAnsweredBy],[MapStatusID],[IndexStatusID],[ScanStatusID],
								[QCStatusID],[RouteStatusID],[OccurrenceStatusID],[CreateFromAuditIndicator],[FlyerID],[CreatedDT],[CreatedByID],
								[ModifiedDT],[ModifiedByID]
							  )
					    VALUES(
								 @AdId,@MediaTypeId,@MarketId,@PubIssueId,@PatternmasterId,@SubSourceId,@ADDate,@Priority,
								 @InternalReferenceNotes,@color,@SizingMethod,@PubPageNumber,@PageCount,@NotakeReason,0,NUll,
								 Null,Null,Null,Null,Null,@MapIndexStatusID,@MapIndexStatusID,NULL,
								 Null,Null,Null,Null,Null,GetDate(),@UserId,
								 Null,Null	
							 )

							 Set @OccurrenceId=Scope_Identity();
						Exec sp_PublicationDPFOccurrenceStatus @OccurrenceId,1
						COMMIT TRANSACTION
					END TRY

					BEGIN CATCH
						DECLARE @error INTEGER,@message     VARCHAR(4000),@lineNo INTEGER
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_PublicationDPFMapAdToOccurrence: %d: %s',16,1,@error,@message,@lineNo); 
						ROLLBACK TRANSACTION
					END CATCH
END