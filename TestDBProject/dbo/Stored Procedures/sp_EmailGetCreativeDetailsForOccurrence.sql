-- ============================================================================================
-- Author			 : Arun Nair
-- Create date		 : 10/26/2015
-- Description		 : 
-- Execution Process : 
-- Updated By		 : 	
--					 : 
-- ============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailGetCreativeDetailsForOccurrence]
(
@OccurrenceID AS BIGINT
)
AS
BEGIN
			SET NOCOUNT ON;

				BEGIN TRY
						 SELECT   AdId,
								  PK_OccurrenceID AS OccurrenceID,
								  CreativeMasterID,
								  CreativeDetailID,
								  PatternMasterCreativeMasterID,
								  PageNumber,
								  isDeleted,
								  CreativeRepository +  CreativeAssetName AS [PrimarySource],
								  CreativeAssetThumbnailName As [ThumbnailSource] 
						 FROM  [vw_EmailCreatives] WHERE PK_OccurrenceID=@OccurrenceID  AND isDeleted=0  
						 ORDER BY  Pagenumber
				END TRY

			  BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_EmailGetCreativeDetailsForOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 				  
			  END CATCH 

END
