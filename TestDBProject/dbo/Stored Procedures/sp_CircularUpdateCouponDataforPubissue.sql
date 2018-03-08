

-- =============================================================================================
-- Author			: Karunakar
-- Create date		: 18th Jan 2016
-- Description		: This Procedure is used to creating  new Pub Issue Id when Occurrence ID in Coupon Book
-- Exec				: sp_CircularUpdateCouponDataforPubissue 580083,29712031
-- ==============================================================================================

CREATE PROCEDURE [dbo].[sp_CircularUpdateCouponDataforPubissue]
	@OccurrenceID as bigint,
	@UserID as int
AS
BEGIN
SET NOCOUNT ON;			
	BEGIN TRY
		BEGIN TRANSACTION
			Declare @SectionList as Nvarchar(max)
			Declare @AdvID as  integer
			Declare @MediaTypeID as  integer
			Declare @Section as INTEGER
			Declare @IssueDate as Date
			Declare @PubEditionID as INTEGER
			Declare @PubIssueCount as INTEGER=0
			Declare @IsPubIssueExists as Bit
			Declare @PubIssueStatus as Nvarchar(30)
			Declare @PubIssueID as INTEGER
			DECLARE @Status AS BIT=0

			Select @AdvID=[AdvertiserID],@IssueDate=AdDate,@PubEditionID=[PubEditionID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@OccurrenceID
			
			--Print(@AdvID)

			SET @MediaTypeID=(Select [MediaTypeID] from Mediatype where Mediastream ='CIR' and Descrip ='Coupon Book')

			--Print(@MediaTypeID)

			SET @PubIssueStatus=(Select ValueTitle from [Configuration] where  ComponentName='Published Issue Status' and Value='P')

			IF(@AdvID<>0)
			BEGIN
			SELECT @SectionList = COALESCE(@SectionList + ', ', '') + CAST(Value AS varchar(10))
								  FROM [Configuration] 
								  WHERE SystemName ='All'
								  AND ComponentName = 'Coupon Book to PUB'
								  AND  @AdvID IN (select * from [dbo].[Split](',',valuegroup))
		
			END
	
			--Coupon Book to Pub data replication
			IF EXISTS(SELECT [OccurrenceDetailCIRID] FROM [OccurrenceDetailCIR]  WHERE [OccurrenceDetailCIRID]=@OccurrenceID AND [MediaTypeID]=@MediaTypeID AND  @SectionList Is Not NULL)
				BEGIN

						--Print N'Occurrence and Media Type  Exists'
						--Validate whether Coupon Book to Pub data replication 
						IF EXISTS (SELECT 1 FROM PubIssue WHERE CpnOccurrenceID = @OccurrenceID)
							BEGIN
									SET @IsPubIssueExists=1
									SET @Status=0	
							END
							ELSE
							BEGIN

									
									----Print N'Coupon Book to Pub data replication '
									SET @Section = (SELECT TOP 1 a.[PubSectionID] FROM PubSection a, PubEdition b,[OccurrenceDetailCIR] ocr
													WHERE b.[PubEditionID] = ocr.[PubEditionID]
													AND a.[PublicationID] = b.[PublicationID]
													AND a.[PubSectionID] IN (Select Distinct Id from [dbo].[fn_CSVToTable](@SectionList)))


									SELECT @PubIssueCount=COUNT(*) FROM PubIssue WHERE [PubEditionID] = @PubEditionID AND IssueDate = @IssueDate AND FK_PubSection = @Section
									IF (@PubIssueCount>0)
									BEGIN
											SET @IsPubIssueExists=1
									END
									ELSE
									BEGIN
											SET @IsPubIssueExists=0
									END
								
							END

							IF(@IsPubIssueExists=0)
							BEGIN
								--Proceed create corresponding record in PubIssue table
								INSERT INTO PubIssue
								([EnvelopeID],
								[SenderID],
								[PubEditionID],
								[ShippingMethodID],
								[PackageTypeID],
								IssueDate,
								TrackingNumber,
								PrintedWeight,
								ActualWeight,
								PackageAssignment,
								CpnOccurrenceID,
								FK_PubSection,
								ReceiveOn,
								ReceiveBy,
								IssueCompleteIndicator,
								IssueAuditedIndicator,
								[Status],
								CreateDTM,
								CreateBy
								)
								SELECT b.[EnvelopeID],
										b.[SenderID],
										a.[PubEditionID],
										b.[ShippingMethodID],
										b.[PackageTypeID],
										a.AdDate,
										b.[TrackingNumber],
										b.ListedWeight,
										b.ActualWeight,
										b.[PackageAssignmentID],
										a.[OccurrenceDetailCIRID],
										@Section,
										CURRENT_TIMESTAMP,
										@UserID,
										0,
										0,
										@PubIssueStatus,
										CURRENT_TIMESTAMP,
										@UserID
									FROM [OccurrenceDetailCIR] a, [Envelope] b
									WHERE a.[OccurrenceDetailCIRID] = @OccurrenceID
									AND b.[EnvelopeID] = a.[EnvelopeID]
								
									SET @PubIssueID=SCOPE_IDENTITY()

									Print(@PubIssueID)
									SET @Status=1
							END
						ELSE
							BEGIN
									SET @Status=0
							END
				END
			ELSE
			 --Occurrence and Media Type Not Exists
			BEGIN
			SET @Status=0
			END

			Select  @Status  as Result

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('sp_CircularUpdateCouponDataforPubissue: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	END CATCH
	END
