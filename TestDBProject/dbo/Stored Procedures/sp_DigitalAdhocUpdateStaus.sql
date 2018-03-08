-- =============================================
-- Author:		Suman Saurav
-- Create date: 12 Jan 2016
-- Description:	Created to update CreativeDetailStaging and ExceptionDetails tables for Media Type 'OND', 'ONV' and 'MOB'
--EXEC:	EXEC [sp_DigitalAdhocUpdateStaus] 'CreativeDetailStagingOND', '1', false, 'AD', 0, 'OND'
-- =============================================
CREATE PROCEDURE [dbo].[sp_DigitalAdhocUpdateStaus]
(
	@CreativeDetailTable	NVARCHAR(50),
	@IsDownloaded			BIT,
	@SignatureDefault		NVARCHAR(100),
	@Mode					NVARCHAR(2),
	@PatternMasterStgId     INT,
	@MediaStream			NVARCHAR(5)
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			DECLARE @query NVARCHAR(MAX) = ''
			IF(@Mode = 'AD')
			BEGIN
				SET @query = 'UPDATE ' + @CreativeDetailTable + ' SET CreativeDownloaded = ''' + CONVERT(NVARCHAR(1), @IsDownloaded) + ''' WHERE SignatureDefault = ''' + @SignatureDefault + ''''
			END
			ELSE
			BEGIN
				SET @query = 'UPDATE ' + @CreativeDetailTable + ' SET LandingPageDownloaded = ''' + CONVERT(NVARCHAR(1), @IsDownloaded) + ''' WHERE SignatureDefault = ''' + @SignatureDefault + ''''
			END
			EXEC(@query)
			UPDATE [ExceptionDetail] SET ExceptionStatus = 'Resolved' WHERE MediaStream = @MediaStream AND [PatternMasterStagingID] = @PatternMasterStgId 

			SELECT 1
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		DECLARE @Error   INT, @Message VARCHAR(4000), @LineNo  INT 
        SELECT @Error = Error_number(), @Message = Error_message(), @LineNo = Error_line() 
        RAISERROR ('[sp_DigitalAdhocUpdateDataForPatternMediaRetrieval]: %d: %s', 16, 1, @Error, @Message, @LineNo);
	END CATCH
END
