-- Execution	: [sp_GetPromotionEntryData] 
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[sp_GetPromotionEntryData]
(
@PromotionalTemplateID varchar(250),
@MediaStreamId varchar(250),
@UserID varchar(250),
@RunDateFrom varchar(25),
@RunDateTo varchar(25)
)
as
BEGIN 
BEGIN TRY	
	BEGIN
		

		SELECT ROW_NUMBER() OVER ( ORDER BY Advertiser ) AS RowNumber,Score AS Score ,Advertiser,RecordID as[Ad/OccurrenceID] ,RunDate,CropID,CropSize,CategoryGroup,Category,Product,ProductDesc as [Product Description], PromoPrice AS [Promo Price]
		,KeyID,PromoTemplate,MediaStream,AdID,OccurrenceID,CategoryID,CategoryGroupID,MediastreamID,[ModifiedByID],MediastreamName
		FROM vw_PromotionWorkQueue VW
		where 
		VW.MediastreamID IN (SELECT Item FROM dbo.SplitString(@MediaStreamId, ',')) and
		( VW.RunDate>= CONVERT(VARCHAR, @RunDateFrom, 110) AND VW.RunDate <= CONVERT(VARCHAR, @RunDateTo, 110) )
	AND (VW.[ModifiedByID]=@UserID OR @UserID = '0')
		AND (VW.PromoTemplate=@PromotionalTemplateID OR @PromotionalTemplateID ='0')
		AND ISNULL(VW.[Query],0)<>1  order by score, RunDate asc
	END
END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetPromotionEntryData]: %d: %s',16,1,@error,@message,@lineNo);
			  ROLLBACK TRANSACTION
		END CATCH 

END

