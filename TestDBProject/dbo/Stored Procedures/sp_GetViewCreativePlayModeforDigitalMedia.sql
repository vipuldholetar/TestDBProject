
-- ===========================================================================================
-- Author			: Karunakar
-- Create date		: 20th October 2015
-- Description		: This stored procedure is used to Getting Media File Viewer for Digital Media 
-- Execution Process: sp_GetViewCreativePlayModeforDigitalMedia 'jpg','edit'
-- Updated By		: 
--					: 
-- ============================================================================================

CREATE PROCEDURE sp_GetViewCreativePlayModeforDigitalMedia 
	(
	@CreativeFileType Nvarchar(50),
	@CreativeMode nvarchar(50)
	)
	as
BEGIN			
		BEGIN TRY
			SELECT ValueTitle As MediaFileViewer,ValueGroup as Mode FROM   [dbo].[Configuration] 
			WHERE Value=@CreativeFileType and ComponentName = 'MediaTypeMapping' and ValueGroup=@CreativeMode
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_GetViewCreativePlayModeforDigitalMedia: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
