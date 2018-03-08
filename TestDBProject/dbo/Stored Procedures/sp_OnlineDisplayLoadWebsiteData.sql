-- ===========================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 9/8/2015
-- Description	: Get Website Urls
-- Execution	: [dbo].[sp_OnlineDisplayLoadWebsiteData]
-- Updated By	:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_OnlineDisplayLoadWebsiteData]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT [WebsiteID],SiteURL  FROM [dbo].[Website]
		END TRY

		BEGIN CATCH 
			  DECLARE @error  INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_OnlineDisplayLoadWebsiteData]: %d: %s',16,1,@error,@message,@lineNo); 
		 END CATCH 
END
