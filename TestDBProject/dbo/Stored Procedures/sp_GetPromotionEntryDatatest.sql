CREATE PROCEDURE [dbo].[sp_GetPromotionEntryDatatest]
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
		SELECT ROW_NUMBER() OVER ( ORDER BY Advertiser ) AS RowNumber,Score AS Priority,Advertiser,RecordID,RunDate,CropID,CropSize,CategoryGroup,Category,Product,ProductDesc, PromoPrice AS PromoPrice
		,KeyID,PromoTemplate,MediaStream,AdID,OccurrenceID,CategoryID,CategoryGroupID,MediastreamID,[ModifiedByID]
		FROM vw_PromotionWorkQueue VW 
		where 
		VW.MediastreamID IN (SELECT Item FROM dbo.SplitString(@MediaStreamId, ',')) and
		( VW.RunDate>= CONVERT(VARCHAR, @RunDateFrom, 110) AND VW.RunDate <= CONVERT(VARCHAR, @RunDateTo, 110) )
	--	AND VW.ModifiedBy=(CASE WHEN @UserID='0' then VW.ModifiedBy else @UserID end)
		AND VW.PromoTemplate=(CASE WHEN @PromotionalTemplateID='0' then VW.PromoTemplate else @PromotionalTemplateID end)
		
	END
END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetPromotionEntryDatatest]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		END CATCH 

END
