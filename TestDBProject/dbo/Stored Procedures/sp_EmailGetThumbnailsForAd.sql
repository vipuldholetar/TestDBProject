-- =============================================
-- Author			:	KARUNAKAR
-- Create date		:	2nd Nov 2015
-- Description		:	Get Thumbnails for Ad
-- Execution Process:	[sp_EmailGetThumbnailsForAd] 5210
-- Updated By		:	
-- =============================================
Create PROCEDURE [dbo].[sp_EmailGetThumbnailsForAd]
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
				  RAISERROR ('sp_EmailGetThumbnailsForAd]: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
		
END
