


-- =====================================================================
-- Author		: Arun Nair 
-- Create date	: 21 Dec 2015
-- Description	: Update Scantracker Source
-- Updated By	: 
--=======================================================================
CREATE PROCEDURE sp_ScanTrackerUpdateScanImageSource
(
@ScanImageSource AS NVARCHAR(MAX)
)
AS
BEGIN
	BEGIN TRY			
			UPDATE [Configuration] SET Value=@ScanImageSource WHERE ComponentName='ScanImageSource' AND SystemName='All'
	END TRY
	BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_ScanTrackerUpdateScanImageSource]: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH
END
