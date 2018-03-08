

-- ============================================================================================================
-- Author		: Karunakar
-- Create date	: 06/11/2015
-- Description	: This Procedure is Used to Store Publication Occurrence Data
-- Exec			: [dbo].[sp_PublicationDPFSaveOccurrenceData]   9,3023,25,2,73,1, 1,'6/13/2015','6/13/2015','6/13/2015','6/13/2015',29692010,'',2,'',false,true,3,1,'',Null,'Column Inch','',29711029
-- Updated By	: Arun Nair on 2015/06/24 for Publication Review 
--				: Updated Changes Based on Configuration Master table LOV on 01 july 2015 By Karunakar/
--				: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--				: Arun Nair on 08/25/2015 -Change in OccurrenceID DataType,Seed Value
--				: Arun Nair on 12/31/2015 -Change for Multiedition New Columns Added 
--				: Arun Nair on 01/06/2015 -Added MNIIndicator for OccurrencedetailsPub from pubissue
--				: Arun Nair 01/19/2016 - Added MapMOD details
--				: Lisa East 02.15.2017 - Map Occurrence updated with scan status of complete
-- ============================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFSaveOccurrenceData]
(
@AdId														As Int,
@PubIssueId													as Int,
@MediaTypeId												as int,
@LanguageId													as Int,
@MediaStreamId												as Int,
@MarketId													as Int,
@SubSourceId												as Int,
@ADDate														as DATETIME,
@DistDate													AS DATETIME,
@SaleStartDate												AS DATETIME,
@SaleEndDate												AS DATETIME,
@AdvertiserID												AS INT,
@InternalReferenceNotes                                     AS NVARCHAR(max), 
@PageCount                                                  AS INT=0,
@PubPageNumber                                              As NVARCHAR(max),
@National													AS BIT, 
@Flash														AS BIT, 
@EventId													As Integer,
@ThemeId													As Integer,
@color														As Nvarchar(50),         
@Priority													As Int=0,
@SizingMethod												As NVARCHAR(max),
@NotakeReason                                               As Varchar(max),
@UserId														AS Int,
@NewOccurrence												As Int,
@PageDefinitionParamXml										As Xml,
@CreativeAssetQuality										AS Integer,
@FK_SizeID													As Integer,
@FK_PubSectionID											As Integer,
@Size														AS NVARCHAR(MAX),
@ADPubDate													AS DATETIME
)
	
AS
IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	
	SET NOCOUNT ON;

					DECLARE @OccurrenceId As BigInt
					DECLARE @PatternmasterId As Int
					DECLARE @CompleteStatusID AS INT
					DECLARE @IsDefinitionData As Int 
					DECLARE @CreativeMasterID As Int
		BEGIN TRY 
          BEGIN TRANSACTION 
		  
			select @CompleteStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

		  --Insert Into Pattern Master
		    
			INSERT INTO [Pattern] 
                  (
				  [CreativeID],
				  [AdID],
				  MediaStream,
				  Status,
				  [EventID],
				  [ThemeID],
				  [SalesStartDT],
				  [SalesEndDT],
				  [FlashInd],
				  NationalIndicator,
                  CreateDate
				  )
				   VALUES 
				   (
				   Null,
				   @AdId,
				   @MediaStreamId,
				   'Valid',
				   @EventId,
				   @ThemeId,
				   @SaleStartDate,
				   @SaleEndDate,
				   @Flash,
				   @National,
				   GetDate()
				   )

             SET @PatternmasterId=Scope_identity();

			 Print(@PatternmasterId)
			  --Insert Into OccurrenceDetailPUB
			  BEGIN 
			  ---Insert MMI INDICATOR to [OccurrenceDetailsPUB]
				DECLARE @MNIIndicator AS INTEGER				
				SELECT  @MNIIndicator=[MNIInd] from PubEdition INNER JOIN PubIssue ON Pubissue.[PubEditionID]=PubEdition.[PubEditionID] WHERE [PubIssueID]=@PubIssueId

               INSERT INTO [dbo].[OccurrenceDetailPUB]
			        ([AdID],[MediaTypeID],[MarketID],[PubIssueID],[PatternID],[SubSourceID],[AdDT],[Priority],
					 [InternalRefenceNotes],[Color],[SizingMethod],[PubPageNumber],[PageCount],[NoTakeReason],[Query],[QueryCategory],
					 [QueryText],[QryRaisedBy],[QryRaisedDT],[QueryAnswer],[QryAnsweredBy],[MapStatusID],[IndexStatusID],[ScanStatusID],
					 [QCStatusID],[RouteStatusID],[OccurrenceStatusID],[CreateFromAuditIndicator],[FlyerID],[CreatedDT],[CreatedByID],
					 [ModifiedDT],[ModifiedByID],[SizeID],[PubSectionID],[Size],[MNIIndicator]
					)
					Values
					(@AdId,@MediaTypeId,@MarketId,@PubIssueId,@PatternmasterId,@SubSourceId,@ADDate,@Priority,
					@InternalReferenceNotes,@color,@SizingMethod,@PubPageNumber,@PageCount,@NotakeReason,0,NUll,
					Null,Null,Null,Null,Null,@CompleteStatusID,@CompleteStatusID,Null,
					Null,Null,Null,0,Null,GetDate(),@UserId,
					Null,Null,@FK_SizeID,@FK_PubSectionID,@Size,@MNIIndicator
					)
			      
				SET @OccurrenceId=Scope_identity();
				--Update Issue Date
					--IF @ADPubDate <> ''
					--BEGIN

					--UPDATE [dbo].[PubIssue] SET IssueDate= @ADPubDate WHERE [PubIssueID]=@PubIssueId

					--END 
				Print(@OccurrenceId)
				-- New Ad and New Occurrence ,Passing Value @NewOccurrence=1
				If(@NewOccurrence=1)
				BEGIN
					update Ad set [PrimaryOccurrenceID]=@OccurrenceId where [AdID]=@AdId 
					Print(@AdId)
				END

				IF @NotakeReason <> '' 
                BEGIN 
					UPDATE Ad 
					SET    description ='MOD:'+@NotakeReason 
					WHERE  [AdID] = @AdId 
                END 

				----Update PubIssue for New Occurrence on Notake Status 
				DECLARE @PubissueStatus AS NVARCHAR(20)
				SELECT @PubissueStatus=STATUS FROM [dbo].[PubIssue] WHERE [PubIssueID]=@PubIssueId
				IF(@PubissueStatus='No Take')
					BEGIN 
						UPDATE [dbo].[PubIssue] SET [NoTakeReason]=NULL,[Status]='In Progress' WHERE [PubIssueID]=@PubIssueId
						UPDATE [dbo].[OccurrenceDetailPUB] SET [CreateFromAuditIndicator]=1  WHERE [OccurrenceDetailPUBID]=@OccurrenceId
					END
										

			   -- Update status in OccurrenceDetailsPUB
				EXEC sp_PublicationDPFOccurrenceStatus @OccurrenceId,1

				
				--L.E. 3.19.2017 MI-977
				If(@NewOccurrence = 1) or (@NewOccurrence = 0 AND @NotakeReason='Visual Change' )
				BEGIN				
					---'New Occurrence or MapMod reason visual change update ScanStatus as Inprogress/waiting
					EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 5
				END
				ELSE IF (@NewOccurrence = 0 AND NOT EXISTS (select top 1 * from  OccurrenceDetailPUB Pub Inner join Ad  on Pub.AdID=Ad.AdID and Pub.OccurrenceDetailPUBID=Ad.PrimaryOccurrenceID
				where Pub.OccurrenceDetailPubID=@OccurrenceId AND PUB.ADID=@AdId))
				BEGIN 
				 EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 6
				END 
				
				--Update Map Occurrence as scan complete L.E. 2.15.17 MI-974
				--If Not Exists (select top 1 * from  OccurrenceDetailPUB Pub
				--inner join Ad  on Pub.AdID=Ad.AdID and Pub.OccurrenceDetailPUBID=Ad.PrimaryOccurrenceID
				--where MapStatusID > 0 and Pub.OccurrenceDetailPubID=@OccurrenceId) 
				--BEGIN
				--EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId,3
				--END

				
				--Checking If PageDefinitionParamXml have Data or Not
				SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				IF(@IsDefinitionData=1)
				BEGIN
				INSERT INTO [dbo].[Creative]
				([AdId],[SourceOccurrenceId],PrimaryIndicator,PrimaryQuality)
				Values
				(@AdId,@OccurrenceId,1,@CreativeAssetQuality)
				 SET @CreativeMasterID=Scope_identity();
				 Update [Pattern] Set [CreativeID]=@CreativeMasterID Where [PatternID]=@PatternmasterId
				 --Inserting New Records For Page Definition Details in CreativeDetailPub
				Exec [sp_PublicationDPFInsertPageDefinitionData] @OccurrenceId,@CreativeMasterID,@PageDefinitionParamXml
				END
             END

		  COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_PublicationDPFSaveOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
END