-- =================================================================================
-- Author		:	Govardhan.R
-- Create date	:	11/06/2015
-- Description	:	Get configuration value .
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetConfigurationValueForConfigId]
(
@ConfigId as int
)
AS
BEGIN

		SET NOCOUNT ON;
		BEGIN TRY									
		SELECT * FROM [Configuration] WHERE ConfigurationID=@ConfigId
		END TRY

		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_CPGetConfigurationValueForConfigId]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END