-- =============================================
-- Author			:	Rupinderjit Singh Batra
-- Create date		:	02/06/2015
-- Description		:	Get Thumbnails for Ad
-- Execution Process: [sp_GetCircularThumbnailsForAd] 5210
-- Updated By		:	Arun Nair on 29/05/2015
-- Updated By		:   Updated Changes Based on Configuration Master table LOV on 01 july 2015
-- UPdated By		:	Karunakar on 11th August 2015
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetCircularThumbnailsForAd]
(
@AdID AS INT
)
AS
BEGIN
		BEGIN TRY
		declare @basepath varchar(500)
		select @basepath=value from [Configuration] where systemname='All' and ComponentName='Creative Repository'
					 SELECT	  
							  @basepath+'\'+ThmbnlRep +AssetThmbnlName AS Imagepath,
							  AssetThmbnlName As ImageName, 
							  0 as ImageSize ,
							  PrimaryIndicator as IsSelected,
							  PrimaryIndicator as IsDefault,
							 [Creative].PK_Id As CreativeMasterId

					 FROM  [dbo].[Creative] WHERE [AdId]=@AdID and [SourceOccurrenceId] is null
					 ORDER BY PrimaryIndicator DESC
		
		
		END TRY

		BEGIN CATCH
				 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_GetCircularThumbnailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
		
END
