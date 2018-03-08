



-- ========================================================================================================================
-- Author		:   Arun Nair 
-- Create date	:   13 June 2015 
-- Description	:   Update Occurrence Publication Based on AdId 
-- Updated By	:	Updated By Karunakar on 08/04/2015,Adding Page Definition SP for Updating/Inserting New Page Data
--	UpdatedBy	:	Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--					Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--					Arun Nair on 12/31/2015 - Change for MultiEdition New Cols Added 
--				:   Arun Nair on 01/06/2015 -Added MNIIndicator for OccurrencedetailsPub from pubissue
--				:	Arun Nair on 01/19/2015 - Added MapMOD Details
--				:	Lisa East on 2/9/2017 - Added  @IsMapAD parameter for sp_UpdateMapMODDetails procedure call
--=======================================================================================================================

CREATE PROCEDURE [dbo].[sp_PublicationDPFUpdateOccurrenceData]
(
@AdId			As INTEGER,
@OccurrenceId	AS BIGINT,
@MediaTypeId	AS INTEGER,
@MarketId		AS INTEGER,
@MediaStreamId  AS INTEGER,
@SubSourceId	AS INTEGER,
@ADDate			AS DATETIME,
@DistDate		AS DATETIME,
@SaleStartDate	AS DATETIME,
@SaleEndDate	AS DATETIME,
@PageCount      AS INTEGER,
@PubPageNumber  As NVARCHAR(max),
@National		AS BIT, 
@Flash			AS BIT, 
@EventId		AS INTEGER,
@ThemeId		AS INTEGER,
@Color			AS NVARCHAR(50),         
@Priority		AS INTEGER,
@SizingMethod	AS NVARCHAR(max),
@UserId			AS INTEGER,
@PageDefinitionParamXml As Xml,
@FK_SizeID		As Integer,
@FK_PubSectionID As Integer,
@Size AS NVARCHAR(MAX),
@originalAdDescription	AS NVARCHAR(MAX),
@originalAdRecutDetail	AS NVARCHAR(MAX),
@isScanReqd as bit, 
@IsMapAD as bit 

)
AS
BEGIN
	SET NOCOUNT ON;
			BEGIN TRY
				BEGIN TRANSACTION

				    DECLARE @PatternMasterID AS INTEGER
				    Declare @PubissueId as Integer
				    Declare @IsDefinitionData As Int 
				    DeClare @CreativemasterId As Int
				    DECLARE @OccurrenceMediaStream AS VARCHAR(50)

				    IF EXISTS(select 1 
								    from [OccurrenceDetailPUB] 
										  where [OccurrenceDetailPUBID]=@OccurrenceId)
				    BEGIN
					   SET @OccurrenceMediaStream = 'PUB'

					    UPDATE [OccurrenceDetailPUB]
						    SET [MediaTypeID]=@MediaTypeId,
							    [MarketID]=@MarketId,
							    [SubSourceID]=@SubSourceId,
							    [AdDT]=@ADDate,
							    Priority=@Priority,
							    Color=@Color,
							    SizingMethod=@SizingMethod,
							    PubPageNumber=@PubPageNumber,
							    PageCount=@PageCount,
							    [ModifiedDT]=getdate(),
							    [ModifiedByID]=@UserId,
							    [SizeID]=@FK_SizeID,
							    [PubSectionID]=@FK_PubSectionID,
							    Size=@Size
					    WHERE  [OccurrenceDetailPUBID]=@OccurrenceId
				    END
				    ELSE IF EXISTS(select 1 
								    from [OccurrenceDetailCIR] 
										  where [OccurrenceDetailCIRID]=@OccurrenceId)
				    BEGIN
					    SET @OccurrenceMediaStream = 'CIR'

						  update [OccurrenceDetailCIR]  SET [OccurrenceDetailCIR].[MediaTypeID]=@MediaTypeId, 
								[OccurrenceDetailCIR].[MarketID]=@MarketId, 
								[OccurrenceDetailCIR].DistributionDate=@DistDate, 
								[OccurrenceDetailCIR].AdDate=@AdDate, 
								[OccurrenceDetailCIR].PageCount=@PageCount,
								[OccurrenceDetailCIR].Color= @Color, 
								[OccurrenceDetailCIR].SizingMethod=@SizingMethod,
								[OccurrenceDetailCIR].[SubSourceID]=@SubSourceId,
							 [OccurrenceDetailCIR].[AdID]=@AdId,
								[OccurrenceDetailCIR].Priority=@Priority,
								[OccurrenceDetailCIR].[ModifiedDT]= Getdate(),
								[OccurrenceDetailCIR].[ModifiedByID]=@UserId
						  where [OccurrenceDetailCIR].[OccurrenceDetailCIRID]=@OccurrenceID
				    END

				SELECT @PatternMasterID=[PatternID] FROM [dbo].[Pattern] WHERE [AdID]=@AdId

				UPDATE [dbo].[Pattern]
					 SET MediaStream=@MediaStreamId,
						 [EventID]=@EventId,
						 [ThemeID]=@ThemeId,
						 [SalesStartDT]=@SaleStartDate,
						 [SalesEndDT]=@SaleEndDate,
						 [FlashInd]=@Flash,
						 NationalIndicator=@National,
						 ModifyDate=getdate()
				WHERE	[PatternID]=@PatternMasterID AND  [AdID]=@AdId

				IF @OccurrenceMediaStream = 'PUB'
				BEGIN
				    Select @PubissueId=[PubIssueID] from [OccurrenceDetailPUB] WHERE  [OccurrenceDetailPUBID]=@OccurrenceId

				    --Update Issue Date
					    --IF @ADDate <> ''
					    --BEGIN					
					    --UPDATE [dbo].[PubIssue] SET IssueDate= @ADDate WHERE [PubIssueID]=@PubIssueId
					
					    --END 

				    --Added Update MNI Indicator for Occurrence
				    DECLARE @MNIIndicator AS INTEGER				
				    SELECT @MNIIndicator = [MNIInd] from PubEdition INNER JOIN PubIssue ON Pubissue.[PubEditionID]=PubEdition.[PubEditionID] 
								    WHERE [PubIssueID]=@PubissueId

				    UPDATE [OccurrenceDetailPUB] SET MNIIndicator=@MNIIndicator WHERE  [OccurrenceDetailPUBID]=@OccurrenceId
				END

				--Add MapMod Details
				EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,
									   @OccurrenceMediaStream,@AdId,@isScanReqd,@UserId, @IsMapAD
			

				if (@pubissueid>0)
				begin
				    exec [sp_UpdatePublicationIssueStatusAsComplete] @pubissueid
				end
				
				--Page Definition Data

				--Checking If PageDefinitionParamXml have Data or Not
				SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				IF(@IsDefinitionData=1)
				BEGIN		
				    
				    Set @CreativemasterId=(Select [CreativeID] from [Pattern] where  [PatternID]=@PatternMasterID)

					IF Exists(Select 1  from [Creative] Where PK_Id=@Creativemasterid)
					BEGIN
							-- Updating Records For Page Definition Details in CreativeDetailPub
							Exec [sp_PublicationDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml
					END
					ELSE
					BEGIN
									--Inserting New Records For Page Definition Details in CreativeDetailPub
									INSERT INTO [dbo].[Creative]
									([AdId],[SourceOccurrenceId],PrimaryIndicator,PrimaryQuality)
									Values
									(@AdId,@OccurrenceId,1,null)
									 SET @CreativeMasterID=Scope_identity();
									Update [Pattern] Set [CreativeID]=@CreativeMasterID Where [PatternID]=@PatternmasterId				
									Exec [sp_PublicationDPFInsertPageDefinitionData] @OccurrenceId,@CreativeMasterID,@PageDefinitionParamXml
					END				
				END
					--Page Definition Data
									
				COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION
				 DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
				 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				 RAISERROR ('sp_PublicationDPFUpdateOccurrenceData: %d: %s',16,1,@error,@message,@lineNo); 
			END CATCH 	

END
