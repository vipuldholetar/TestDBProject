-- ===============================================================
-- Author			:	Karunakar
-- Create date		:	21st Sep 2015
-- Description		:	Get Thumbnails for Ad for Online Dispaly
-- Execution Process:	[sp_OnlineDisplayThumbnailsForAd] 11104
-- Updated By		:   
-- ===============================================================
Create PROCEDURE [dbo].[sp_OnlineDisplayThumbnailsForAd]
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
							  PrimaryIndicator as IsDefault,PK_Id AS CreativeMasterId

					 FROM  [dbo].[Creative] WHERE [AdId]=@AdID and [SourceOccurrenceId] is null
					 ORDER BY PrimaryIndicator DESC 		
		END TRY

		BEGIN CATCH
				 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('[sp_OnlineDisplayThumbnailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
		
END
