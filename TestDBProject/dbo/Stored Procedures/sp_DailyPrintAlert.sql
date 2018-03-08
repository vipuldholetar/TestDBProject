-- ====================================================================
-- Author            : Ganesh Prasad
-- Create date       : 10/13/2015
-- Description       : Serves as dataset for "SameDayPrintAlert"  Report Dataset.
-- Execution Process : [dbo].[sp_DailyPrintAlert]
-- Updated By        : 

-- ====================================================================
CREATE Procedure [dbo].[sp_DailyPrintAlert]
AS
BEGIN
SET NOCOUNT ON;
    BEGIN TRY
	 select 
     distinct [dbo].[Advertiser].Descrip as Advertiser , [dbo].Ad.[AdID] as AdCode,
     [dbo].Ad.LeadAvHeadline as Headline , [dbo].Ad.ADVisual as KeyVisual,
    [dbo].RefCategory.CategoryName as Category,[dbo].RefSubCategory.SubCategoryName as SubCategory,
    [dbo].RefProduct.ProductName as Product,[dbo].[Market].[Descrip] as Target,
    [dbo].Publication.Descrip as Publication,[dbo].Ad.FirstRunDate as FirstRunDate,
    [dbo].Ad.CreateDate as AdDate ,([dbo].Size.Height +[dbo].Size.Width) as pageSize,
    [dbo].PubEdition.EditionName as Edition,[dbo].[OccurrenceDetailPUB].Color as Color,
     '' as status --- No Specific DB Column is defined
from [dbo].Ad
Inner Join [dbo].[Advertiser]
ON [dbo].[Advertiser].AdvertiserId = [dbo].Ad.[AdvertiserID]
Inner Join [dbo].[OccurrenceDetailPUB]
ON [dbo].Ad.[PrimaryOccurrenceID] = [dbo].[OccurrenceDetailPUB].[OccurrenceDetailPUBID]
and Ad.[AdID]=[OccurrenceDetailPUB].[AdID]
Inner Join [dbo].PubIssue
ON [dbo].[OccurrenceDetailPUB].[PubIssueID]= [dbo].PubIssue.[PubIssueID]
Inner Join [dbo].PubEdition
ON [dbo].PubIssue.[PubEditionID] = [dbo].PubEdition.[PubEditionID]
Inner Join [dbo].Publication
ON PubEdition.[PublicationID] = Publication.[PublicationID]
Inner Join  [dbo].refproduct   ---- "[Refproduct]" do not have matching records so not pulling any records by joining this table 
ON [dbo].RefProduct.[RefProductID] = [dbo].Ad.ProductId
Inner Join [dbo].RefSubCategory --"[RefSubCategory]" do not have matching records so not pulling any records by joining this table 
ON [dbo].RefSubCategory.[RefSubCategoryID] = [dbo].RefProduct.[SubCategoryID]
Inner Join [dbo].RefCategory
ON [dbo].RefCategory.[RefCategoryID] = [dbo].RefSubCategory.[CategoryID]
Inner Join [Market]
ON [dbo].[Market].[MarketID] = [dbo].Ad.[TargetMarketId]
Inner Join [dbo].[Creative]
On [dbo].[Creative].[AdId] =  [dbo].Ad.[AdID]
Inner Join [dbo].CreativeDetailPUB
ON CreativeDetailPUB.CreativeMasterID = [Creative].Pk_ID
Inner Join [dbo].Size
ON [dbo].Size.[SizeID] =[dbo].CreativeDetailPUB.FK_SizeID
--where convert(Date,Ad.Createdate )= convert(Date,GetDate() -1) --filters the records of previous day


END TRY
			  BEGIN CATCH 

              DECLARE @error INT, @message VARCHAR(4000), @lineNo INT 
              SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
              RAISERROR ('[sp_DailyPrintAlert]: %d: %s',16,1,@error,@message,@lineNo); 
              
			  END CATCH 

END