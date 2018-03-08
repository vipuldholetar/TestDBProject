-- ============================================================================================
-- Author            : Arun Nair 
-- Create date       : 07/14/2015
-- Description       : Get Session Data for Cinema Work Queue 
-- Execute           : [sp_CinemaWorkQueueSessionSearch]
-- Updated By        : Arun Nair  on 09/04/2015 Added distinct for CreativeSignature Count      
--                     Arun Nair on 09/11/2015 -Removed CreativeMasterStaging Check to View   
--==============================================================================================
CREATE PROCEDURE  [dbo].[sp_CinemaWorkQueueSessionSearch] 
    @WorkType as VARCHAR(50),
    @MarketIdlist AS VARCHAR(max),
    @CreativeCount VARCHAR(10),
    @QScore VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; 
    BEGIN TRY 

	   SELECT  WorkType,MarketDescription AS Market,Count(distinct CreativeSignature) AS CreativeSignatureCount,TotalQScore,MarketId,getdate() as createdtm,WorkTypeId
	   FROM [dbo].[vw_CinemaWorkQueueSessionData] 
	   WHERE  [IsQuery]<>1 AND [IsException]<>1 AND MarketId IS NOT NULL 
	   AND (MarketId IN((SELECT Item FROM dbo.SplitString(@MarketIdlist, ','))) OR @MarketIdlist IS NULL OR @MarketIdlist ='' or @MarketIdlist = '-1') 
	   AND (WorkType = @WorkType OR @WorkType IS NULL OR @WorkType = '' OR LOWER(@WorkType) ='all')
	   AND (TotalQScore = @QScore OR @QScore IS NULL OR @QScore ='')
	   GROUP BY WorkType,MarketDescription,TotalQScore,MarketId,WorkTypeId
	   HAVING (Count(distinct CreativeSignature) = @CreativeCount OR @CreativeCount IS NULL OR @CreativeCount ='') 
	   ORDER BY WorkType,MarketDescription

    END TRY

    BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_CinemaWorkQueueSessionSearch]: %d: %s',16,1,@error,@message,@lineNo); 
    END CATCH

END