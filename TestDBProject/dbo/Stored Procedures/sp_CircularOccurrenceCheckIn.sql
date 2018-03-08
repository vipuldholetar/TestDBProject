
-- =================================================================================================================
-- Author		: Arun Nair 
-- Create date	: 07 May 2015 
-- Description	: CheckIn Data for OccurrenceCheckIn 
-- Update By    : Updated Changes Based Configuration Master table LOV on 01 july 2015
--				  on 08/10/2015 by Arun Nair for OccurrenceDetailsCIR insert into QueryDetails for Occurrence
--				: Arun Nair on 08/20/2015 - Add AssignedTo,Filetype
--				: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--				  Karunakar on 7th Sep 2015
--==================================================================================================================
CREATE PROCEDURE [dbo].[sp_CircularOccurrenceCheckIn] 
(
@EnvelopeID AS INT, 
@MediaTypeID AS                                                         INT, 
@MarketCode AS                                                          INT , 
@PublicationEditionID AS                                                INT, 
@DistDate AS                                                            DATETIME, 
@ADDate AS                                                              DATETIME, 
@AdvertiserID AS                                                        INT, 
@InternalReferenceNotes AS                                              VARCHAR(max), 
@PageCount AS                                                           INT, 
@National AS                                                            BIT, 
@Flash AS                                                               BIT, 
@IsAudit AS                                                             BIT, --When CheckInAudit Clicked  CreateFromAuditIndicator =True 
@UserID AS                                                              INT,
@Priority as int,
@NoTakeReasonCode AS VARCHAR(MAX),
@IsQuery bit,
@QueryCategory  NVARCHAR(max),
@QueryText NVARCHAR(max),
@CreateBy AS INT, 
@AssignedTo	AS INT,
@FileType	AS VARCHAR(MAX),
@PageDefinitionParamXml As Xml
) 

AS 
  BEGIN 
    SET nocount ON; 
    
			DECLARE @languageID AS      INT 
			Declare @NoTakeStatus as varchar(20)
			DECLARE @PatternMasterID AS INTEGER 
			DECLARE @OccurrenceID AS    BIGINT 
			DECLARE @QueryId AS INT
			DECLARE @QueryPath AS NVARCHAR(100)
			DECLARE @QueryDetailFolder AS NVARCHAR(100)='Query'
			DECLARE @QueryAssetname AS NVARCHAR(100)
			DeClare @CreativemasterId As Int
			Declare @IsDefinitionData As Int

			BEGIN TRY 
			BEGIN TRANSACTION 
			--Get languageId 
			SELECT @languageID=[LanguageID] 
			FROM   pubedition 
			WHERE  pubedition.[PubEditionID]=@publicationEditionID 
			-- Insert pattern master
			INSERT INTO [Pattern] 
			( 
						status, 
						[FlashInd], 
						nationalindicator ,
						priority,
						CreateDate,
						mediastream
			) 
			VALUES 
			( 
						'Valid', 
						@Flash, 
						@National ,
						@Priority,
						getdate(),
						(select configurationid from dbo.[Configuration] where systemname='All' and componentname='Media Stream' and value='CIR')
			) 
			SET @PatternMasterID=Scope_identity(); 
			BEGIN 
			--Inserting data into  [OccurrenceDetailsCIR] 
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
						@PublicationEditionID, 
						@languageID, 
						@EnvelopeID, 
						@PatternMasterID, 
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
						0, 
						NULL, 
						NULL, 
						NULL, 
						NULL, 
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
						Getdate(), 
						@userid, 
						NULL, 
						NULL 
			) 
			SET @OccurrenceID=Scope_identity(); 

			-- Update status in OccurrenceDetailsCIR
			EXEC [sp_UpdateOccurrenceStatus] @OccurrenceID,1
		
			IF  @isaudit='true'
			BEGIN
			UPDATE [OccurrenceDetailCIR] set auditby=@userid, auditdtm=getdate() WHERE [OccurrenceDetailCIRID]= @OccurrenceID
			END
			IF @IsQuery='true'
			BEGIN
			UPDATE [OccurrenceDetailCIR] set [Query]=@IsQuery,QueryCategory=@querycategory,QueryText=@querytext,QryRaisedBy=@userid, [QryRaisedDT]=getdate()
			WHERE [OccurrenceDetailCIRID]= @OccurrenceID

			INSERT INTO [dbo].[QueryDetail]
			(
			[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
				[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
				[CreatedDT],[CreatedByID],[AssignedToID]
				)
			VALUES
			(
			NULL,@OccurrenceID,NULL,NULL,NULL,'CIR','I&O','OCC',@QueryCategory,@QueryText,@UserID,getdate(),NULL,NULL,NULL,NULL,getdate(),@CreateBy,@AssignedTo
			) 
			Set @QueryId=Scope_identity();
			IF(@FileType<>'')
			BEGIN
				SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
				SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'
				UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
			END
			END

			IF @NoTakeReasonCode ! =''
			BEGIN		
			declare @NoTakeStatusID int
			--SELECT @NoTakeStatus = valuetitle  FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'NT' 

			select @NoTakeStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

			UPDATE [OccurrenceDetailCIR] 
			set Notakereason = @NoTakeReasonCode, OccurrenceStatusID = @NoTakeStatusID 
			where [OccurrenceDetailCIRID]= @OccurrenceID
			END

						        
			SELECT SenderName, 
			[OccurrenceDetailCIRID], 
			mediatypedescription, 
			MarketDescription, 
			publication, 
			editionname, 
			language, 
			distributiondate, 
			addate, 
			advertiser, 
			tradeclass, 
			occurrencecirpriority, 
			'' AS comments, 
			[AdvertiserID], 
			vw_circularoccurrences.[MediaTypeID], 
			[MarketID], 
			[PubEditionID], 
			[LanguageID], 
			vw_circularoccurrences.[EnvelopeID], 
			internalrefencenotes, 
			vw_circularoccurrences.[PatternID], 
			vw_circularoccurrences.[AdID], 
			pagecount, 
			[FlashInd], 
			nationalindicator, 
			vw_circularoccurrences.[CreatedByID], 
			username,
			[dbo].[QueryDetail].[QueryID],
			[dbo].[QueryDetail].QryCreativeRepository,
			[dbo].[QueryDetail].QryCreativeAssetName 
			FROM   vw_circularoccurrences  LEFT JOIN [dbo].[QueryDetail] ON [dbo].[QueryDetail].[OccurrenceID]= vw_circularoccurrences.[OccurrenceDetailCIRID]
			WHERE  [OccurrenceDetailCIRID]=@OccurrenceId 

			
			Set @CreativemasterId=(Select [Pattern].[CreativeID] from [Pattern] where  [Pattern].[PatternID]=@PatternMasterID)

						--Checking If PageDefinitionParamXml have Data or Not
				SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				IF(@IsDefinitionData=1)
				BEGIN		
					IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
					BEGIN
							-- Updating Records For Page Definition Details in CreativeDetailPub
							Exec [sp_CircularDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml
					END
					ELSE
					BEGIN
									--Inserting New Records For Page Definition Details in CreativeDetailPub
									INSERT INTO [dbo].[Creative]
									([SourceOccurrenceId],[PrimaryIndicator])
									Values
									(@OccurrenceId,1)
									 SET @CreativeMasterID=Scope_identity();
									Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID Where [Pattern].[PatternID]=@PatternmasterId				
									Exec [sp_CircularDPFInsertPageDefinitionData] @OccurrenceId,@CreativeMasterID,@PageDefinitionParamXml
					END				
				END
					--Page Definition Data

			END     

			COMMIT TRANSACTION 
			END TRY 
			BEGIN CATCH 
			DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_CircularOccurrenceCheckIn]: %d: %s',16,1,@error,@message,@lineNo);
			ROLLBACK TRANSACTION 
			END CATCH 
  END