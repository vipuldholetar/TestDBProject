
-- ===================================================================================  
-- Author    : Arun Nair    
-- Create date  : 01/29/2016  
-- Description  : Update Occurrence ReMAP Ad Data for Publication MultiCouponBook  
-- UpdatedBy  :   
--====================================================================================  
CREATE PROCEDURE [dbo].[Sp_publicationdpfupdateremapmulticouponbook] (@AdId AS 
INTEGER,@OccurrenceIdList AS NVARCHAR(max),@MediaTypeId AS INTEGER,@MarketId AS 
INTEGER,@MediaStreamId AS INTEGER,@SubSourceId AS INTEGER,@ADDate AS DATETIME, 
@DistDate AS DATETIME,@SaleStartDate AS DATETIME,@SaleEndDate AS DATETIME, 
@PageCount AS INTEGER,@PubPageNumber AS NVARCHAR(max),@National AS BIT,@Flash AS 
BIT,@EventId AS INTEGER,@ThemeId AS INTEGER,@Color AS NVARCHAR(50),@Priority AS 
INTEGER,@SizingMethod AS NVARCHAR(max),@UserId AS INTEGER,@MODReason AS VARCHAR( 
max),@FK_SizeID AS INTEGER,@FK_PubSectionID AS INTEGER,@Size AS NVARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @PatternMasterID AS INTEGER 

      BEGIN try 
          BEGIN TRANSACTION 

          UPDATE [OccurrenceDetailPUB] 
          SET    [AdID] = @AdId,[MediaTypeID] = @MediaTypeId, 
                 [MarketID] = @MarketId 
                 , 
                 [SubSourceID] = @SubSourceId,[AdDT] = @ADDate, 
                 priority = @Priority, 
                 color 
                 = @Color,sizingmethod = @SizingMethod, 
                 pubpagenumber = @PubPageNumber, 
                 pagecount = @PageCount,[ModifiedDT] = Getdate(), 
                 [ModifiedByID] = @UserId, 
                 [SizeID] = @FK_SizeID,[PubSectionID] = @FK_PubSectionID,size 
                 = 
                 @Size 
          WHERE  [OccurrenceDetailPUBID] IN (SELECT id 
                                     FROM 
                 [dbo].[Fn_csvtotable](@OccurrenceIdList)) 

          UPDATE [Pattern] 
          SET    [AdID] = @adid 
          WHERE  [PatternID] IN (SELECT [PatternID] 
                           FROM   [OccurrenceDetailPUB] 
                           WHERE  [OccurrenceDetailPUBID] IN (SELECT id 
                                                      FROM 
                                  [dbo].[Fn_csvtotable](@OccurrenceIdList))) 

          UPDATE [dbo].[Pattern] 
          SET    mediastream = @MediaStreamId,[EventID] = @EventId, 
                 [ThemeID] = @ThemeId, 
                 [SalesStartDT] = @SaleStartDate,[SalesEndDT] = @SaleEndDate, 
                 [FlashInd] = @Flash,nationalindicator = @National, 
                 modifydate = Getdate() 
          WHERE  [PatternID] IN (SELECT [PatternID] 
                           FROM   [OccurrenceDetailPUB] 
                           WHERE  [OccurrenceDetailPUBID] IN (SELECT id 
                                                      FROM 
                                  [dbo].[Fn_csvtotable](@OccurrenceIdList))) 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          ROLLBACK TRANSACTION 

          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_PublicationDPFUpdateReMapMultiCouponBook]: %d: %s',16, 
                     1, 
                     @error,@message, 
                     @lineNo); 
      END catch 
  END
