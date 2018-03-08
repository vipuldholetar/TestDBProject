-- ========================================================================
-- Author		: Arun Nair 
-- Create date	: 07/14/2015
-- Description	: Get Creative Signature Data for Cinema Work Queue 
-- Execution	: [dbo].[sp_CinemaWorkQueueCreativeSignatureData] 15,1
-- Updated By	: Arun Nair  on 9th Sep 2015 - Query Optimise
--				: Karunakar  on 15th Sep 2015 - Query Optimise
--=========================================================================
CREATE PROCEDURE  [dbo].[sp_CinemaWorkQueueCreativeSignatureData]
(
@MarketId AS INTEGER ,
@WorkTypeId AS INTEGER
)
AS
BEGIN
		BEGIN TRY
				SELECT ScoreQ,CreativeAssetName As NCMFileName,
				(SELECT COUNT(occurrenceid) cnt FROM vw_CinemaWorkQueueSessionData a WHERE b.Creativesignature = a.Creativesignature AND	MarketId=@MarketId AND WorkTypeId=@WorkTypeId) AS OccurrenceCount,
				(SELECT MIN(a.OccurrenceId) FROM [vw_CinemaWorkQueueSessionData] a  WHERE b.Creativesignature = a.Creativesignature AND	MarketId=@MarketId AND WorkTypeId=@WorkTypeId) as Occurrencelist,
				MarketDescription AS MediaOutlet,
				CreativeSignature,MarketId from [dbo].[vw_CinemaWorkQueueSessionData] b 
				where (1=1)  AND [IsQuery]<>1 AND [IsException]<>1  AND MarketId=@MarketId AND WorkTypeId=@WorkTypeId
				GROUP BY ScoreQ,CreativeAssetName,CreativeSignature,MarketId,MarketDescription ORDER BY ScoreQ DESC
		END TRY
		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[dbo].[sp_CinemaWorkQueueCreativeSignatureData]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 

END
