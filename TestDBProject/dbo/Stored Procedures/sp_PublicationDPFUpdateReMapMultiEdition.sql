
-- ===================================================================================
-- Author		: Suresh 
-- Create date	: 01/06/2015
-- Description	: Update Occurrence ReMAP Ad Data for Publication Multi Edition
-- UpdatedBy	: 
--====================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFUpdateReMapMultiEdition] 
(
@AdId			As INTEGER,
@OccurrenceIdList	AS Nvarchar(max),
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
@Size AS NVARCHAR(MAX)
)
AS
BEGIN
	
	SET NOCOUNT ON;
				
				DECLARE @PatternMasterID AS INTEGER

				BEGIN TRY
				BEGIN TRANSACTION
				

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
					WHERE  [OccurrenceDetailPUBID] in (SELECT id FROM [dbo].[fn_CSVToTable](@OccurrenceIdList))
					
					UPDATE [Pattern] SET [AdID]=@adid WHERE [PatternID] in (SELECT [PatternID] FROM [OccurrenceDetailPUB] WHERE [OccurrenceDetailPUBID] in (SELECT id FROM [dbo].[fn_CSVToTable](@OccurrenceIdList)))

					UPDATE [dbo].[Pattern]
					 SET MediaStream=@MediaStreamId,
						 [EventID]=@EventId,
						 [ThemeID]=@ThemeId,
						 [SalesStartDT]=@SaleStartDate,
						 [SalesEndDT]=@SaleEndDate,
						 [FlashInd]=@Flash,
						 NationalIndicator=@National,
						 ModifyDate=getdate()
					WHERE	[PatternID] in (SELECT [PatternID] FROM [OccurrenceDetailPUB] WHERE [OccurrenceDetailPUBID] in (SELECT id FROM [dbo].[fn_CSVToTable](@OccurrenceIdList)))

					COMMIT TRANSACTION
				END TRY

				BEGIN CATCH
					ROLLBACK TRANSACTION
					DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_PublicationDPFUpdateReMapMultiEdition]: %d: %s',16,1,@error,@message,@lineNo); 
				END CATCH 	
    
END
