
-- ===================================================================================
-- Author		: Karunakar 
-- Create date	: 17 June 2015 
-- Description	: Update Occurrence Data for Publication Based on ReMap AdId 
-- UpdatedBy	: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--				: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--====================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFUpdateReMapOccurrenceDetails] 
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
@MODReason		as Varchar(max),
@FK_SizeID		As Integer,
@FK_PubSectionID As Integer,
@Size AS NVARCHAR(MAX),
@originalAdDescription as varchar(max),
@originalAdRecutDetail as varchar(max),
@isScanReqd as bit,
@isMapAD as bit,
@ADPubDate	AS DATETIME
)
AS
BEGIN
	
	SET NOCOUNT ON;
			BEGIN TRY
				BEGIN TRANSACTION
					DECLARE @PatternMasterID AS INTEGER
					DECLARE @OccurrenceMediaStream AS VARCHAR(50)

					IF EXISTS(select 1 
								from [OccurrenceDetailPUB] 
									   where [OccurrenceDetailPUBID]=@OccurrenceId)
					BEGIN
						  SET @OccurrenceMediaStream = 'PUB'
						  
						  UPDATE [OccurrenceDetailPUB]
							   SET [AdID]=@AdId,
								    [MediaTypeID]=@MediaTypeId,
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
						   
						  select @PatternMasterID=[PatternID] from [OccurrenceDetailPUB] where [OccurrenceDetailPUBID]=@OccurrenceId
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

						  select @PatternMasterID=[PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@OccurrenceID
					END

					--update [Pattern] set [AdID]=@adid where [PatternID]=@patternmasterid

					UPDATE [dbo].[Pattern]
					 SET	  [AdID]=@adid,
						  MediaStream=@MediaStreamId,
						  [EventID]=@EventId,
						  [ThemeID]=@ThemeId,
						  [SalesStartDT]=@SaleStartDate,
						  [SalesEndDT]=@SaleEndDate,
						  [FlashInd]=@Flash,
						  NationalIndicator=@National,
						  ModifyDate=getdate()
					WHERE  [PatternID]=@PatternMasterID


				  -- Updating Map MOD Reason into Ad table
					IF @MODReason <> '' 
					BEGIN 
						UPDATE ad 
						SET    description ='MOD:'+@MODReason 
						WHERE  [AdID] = @AdId 
					END 

					--Update Issue Date
					--IF @ADPubDate <> ''
					--BEGIN

					--declare @PubissueId as int
					--Select @PubissueId=[PubIssueID] from [OccurrenceDetailPUB] WHERE  [OccurrenceDetailPUBID]=@OccurrenceId
					--UPDATE [dbo].[PubIssue] SET IssueDate= @ADPubDate WHERE [PubIssueID]=@PubIssueId

					--END 
					
					IF @OccurrenceMediaStream = 'CIR'
					BEGIN
						  exec  sp_UpdateOccurrenceStageStatus @OccurrenceID, 2
					END
					ELSE IF @OccurrenceMediaStream = 'PUB'
					BEGIN
						   -----Update  OccurrencePub if Notake Status 
						   --DECLARE @OccurrenceStatusID AS INT
						   --SELECT @OccurrenceStatusID = [OccurrenceStatusID] 
								 --   FROM [OccurrenceDetailPUB] WHERE [OccurrenceDetailPUBID]=@OccurrenceId
						   --IF(@OccurrenceStatusID = 3 OR @OccurrenceStatusID = 1)
						   -- BEGIN
							  --  UPDATE [OccurrenceDetailPUB] SET [NoTakeReason] = NULL, [OccurrenceStatusID] = 2
								 --   WHERE [OccurrenceDetailPUBID]=@OccurrenceId
						   -- END

						   -- Update status in OccurrenceDetailsPub
						   Exec sp_PublicationDPFOccurrenceStatus @OccurrenceId,2

						   IF @MODReason ='Visual Change' ---L.E. 3.16.17 MI-977 If visual change MapMod occurrenece req new scan
						   BEGIN 
							   EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 5
						   END 
						   ELSE
						   BEGIN 
							   EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 3
						   END 

				    END
						-- Update MapMOD Data
				    EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,
								    @OccurrenceMediaStream,@AdId,@isScanReqd,@UserId,@isMapAd



					COMMIT TRANSACTION
				END TRY

				BEGIN CATCH
					ROLLBACK TRANSACTION
					DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_PublicationDPFUpdateReMapOccurrenceDetails: %d: %s',16,1,@error,@message,@lineNo); 
				END CATCH 	
    
END




