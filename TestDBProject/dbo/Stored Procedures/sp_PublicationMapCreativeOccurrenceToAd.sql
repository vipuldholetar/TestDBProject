

-- ====================================================================================================================== 
-- Author			: Lisa
-- Create date		: 10th October 2017
-- Description		: This Procedure is Used to Map and occurrence to and Ad
-- Updated By		:
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMapCreativeOccurrenceToAd]
(
 @Adid         AS     INT, 
 @OccurrenceID AS INT,
 @PubIssueId as Int,
 @UserID            AS INT 

)
	
AS
IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	
	SET NOCOUNT ON;

					DECLARE @NewOccurrenceId As BigInt
					DECLARE @PatternmasterId As Int
					DECLARE @PatternId As Int
					DECLARE @CompleteStatusID AS INT
					DECLARE @IsDefinitionData As Int 
					DECLARE @CreativeMasterID As Int 
					DECLARE @PageDefinitionParamXml AS NVARCHAR (max) ='<DocumentElement><PageDefinition><PageTypeId>B</PageTypeId><SizeId>8</SizeId><PageName>1</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>1</PageNumberOrder><PageNumber>1</PageNumber><PubPageNumber>1</PubPageNumber></PageDefinition></DocumentElement>'
		BEGIN TRY 
          BEGIN TRANSACTION 
		  
			select @CompleteStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

			Select @PatternId = patternid from occurrencedetailpub where adid=@AdId and occurrencedetailpubid =@OccurrenceID

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
				Select
				   Null,
				   @AdId,
				   MediaStream,
				   'Valid',
				   EventId,
				   ThemeId,
				   SalesStartDT,
				   SalesEndDT,
				   FlashInd,
				   NationalIndicator,
				   GetDate()
				  FROM PATTERN 
				  where PATTERNID=@PatternId

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
				Select @AdId,MediaTypeId,MarketId,@PubIssueId,@PatternmasterId,SubSourceId,ADDT,Priority,
					InternalRefenceNotes,color,SizingMethod,PubPageNumber,[PageCount],NotakeReason,0,NUll,
					Null,Null,Null,Null,Null,[MapStatusID],[IndexStatusID],Null,
					Null,Null,Null,0,Null,GetDate(),@UserId,
					Null,Null,SizeID,PubSectionID,Size,@MNIIndicator
					from occurrencedetailpub
					 where AdID=@AdId and occurrencedetailpubid=@OccurrenceID
			      
				SET @NewOccurrenceId=Scope_identity();

				Print(@NewOccurrenceId)
				-- New Ad and New Occurrence ,Passing Value @NewOccurrence=1
				If(@NewOccurrenceId=1)
				BEGIN
					update Ad set [PrimaryOccurrenceID]=@NewOccurrenceId where [AdID]=@AdId 
					Print(@AdId)
				END


				----Update PubIssue for New Occurrence on Notake Status 
				DECLARE @PubissueStatus AS NVARCHAR(20)
				SELECT @PubissueStatus=[STATUS] FROM [dbo].[PubIssue] WHERE [PubIssueID]=@PubIssueId
				IF(@PubissueStatus='No Take')
					BEGIN 
						UPDATE [dbo].[PubIssue] SET [NoTakeReason]=NULL,[Status]='In Progress' WHERE [PubIssueID]=@PubIssueId
						UPDATE [dbo].[OccurrenceDetailPUB] SET [CreateFromAuditIndicator]=1  WHERE [OccurrenceDetailPUBID]=@NewOccurrenceId
					END
										

			   -- Update status in OccurrenceDetailsPUB
				EXEC sp_PublicationDPFOccurrenceStatus @NewOccurrenceId,1

				Declare @CreativeAssetQuality as Int
				Select @CreativeAssetQuality=PrimaryQuality 
				from creative 
				where adid=@AdId and sourceoccurrenceID=@OccurrenceID

		
				INSERT INTO [dbo].[Creative]
				([AdId],[SourceOccurrenceId],PrimaryIndicator,PrimaryQuality)
				Values
				(@AdId,@NewOccurrenceId,1,@CreativeAssetQuality)
				 SET @CreativeMasterID=Scope_identity();
				 Update [Pattern] Set [CreativeID]=@CreativeMasterID Where [PatternID]=@PatternmasterId
				 --Inserting New Records For Page Definition Details in CreativeDetailPub
				Exec [sp_PublicationDPFInsertPageDefinitionData] @NewOccurrenceId,@CreativeMasterID,@PageDefinitionParamXml
			
             END

		  COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_PublicationMapCreativeOccurrenceToAd]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
END