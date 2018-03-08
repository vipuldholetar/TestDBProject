-- ==============================================================================================
-- Author			: Arun Nair
-- Create date		: 13/06/2015
-- Description		: Get OccurrenceCreative Details for Publication
-- Execution Process: 
-- Updated By		: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_GetPublicationCreativeDetailsForOccurrence]
(
@OccurrenceID AS BIGINT
)
AS
BEGIN
			SET NOCOUNT ON;
				BEGIN TRY
						 SELECT   AdId,
								  [OccurrenceDetailPUBID] AS OccurrenceID,
								  CreativeMasterID,
								  CreativeDetailID,
								  PatternMasterCreativeMasterID,
								  PageNumber,
								  isDeleted,
								  CreativeRepository +  CreativeAssetName AS [PrimarySource],
								  CreativeAssetThumbnailName As [ThumbnailSource] 
						 FROM  vw_PublicationCreatives WHERE [OccurrenceDetailPUBID]=@OccurrenceID  AND isDeleted=0  
						 ORDER BY  Pagenumber
				END TRY

			  BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_GetPublicationCreativeDetailsForOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 				  
			  END CATCH 

END
