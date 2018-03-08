

-- =============================================
-- Author:		Suman Saurav
-- Create date: 07 Jan 2016
-- Description:	Created to retrieve Digital Adhoc Pattern Media 
-- EXE:	EXEC sp_DigitalAdhocGetDataForPatternMediaRetrieval 'CreativeDetailStagingONV', 'ONV', 10, 'AD', '0', '2015-01-02'
-- =============================================
CREATE PROCEDURE [dbo].[sp_DigitalAdhocGetDataForPatternMediaRetrieval]
(
	@CreativeDetailTable	VARCHAR(50),
	@MediaStream			VARCHAR(50),
	@NoOfRows				INT,
	@Mode					VARCHAR(2),
	@FileSize				VARCHAR(20),
	@CreatedDate			DATE
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @query VARCHAR(MAX)
		IF(@Mode = 'AD')
		BEGIN
			SET @query  = 'SELECT DISTINCT TOP ' + CONVERT(VARCHAR(5), @NoOfRows) + ' d.CreativeStagingID AS PatternMasterStagingID, d.PK_CreativeDetailStagingID AS CreativeDetailStagingID, 
				d.MediaIrisCreativeId AS MediaIrisCreativeID, CreativeFileType, d.CreativeAssetName AS CreativeAssetName, SignatureDefault, CreativeDownloaded
				FROM CreativeMasterStg s
				INNER JOIN ' + @CreativeDetailTable + ' d ON s.PK_Id = d.CreativeStagingID
				INNER JOIN PatternMasterStg PMS ON PMS.FK_CreativeStgId = s.PK_Id 
                INNER JOIN ExceptionDetails ED ON PMS.PK_Id = ED.FK_PatternMasterStagingID
				WHERE d.CreativeDownloaded = 0 AND d.CreativeFileType IS NOT NULL
				AND d.FileSize >= ' + @FileSize +
				' AND d.CreateDTM >= ' + CONVERT(VARCHAR(15), @CreatedDate) +
				' AND ED.MediaStream=''' + @MediaStream + ''' and ED.ExceptionStatus = ''Requested''' +
				'ORDER BY d.CreativeStagingID, d.PK_CreativeDetailStagingID, d.CreativeAssetName'
		END
		ELSE IF(@Mode = 'LP')
		BEGIN
			SET @query  = 'SELECT DISTINCT TOP ' + CONVERT(VARCHAR(5), @NoOfRows) + ' d.CreativeStagingID AS PatternMasterStagingID, PK_CreativeDetailStagingID AS CreativeDetailStagingID, 
				d.MediaIrisCreativeId AS MediaIrisCreativeID, CreativeFileType, d.CreativeAssetName AS CreativeAssetName, SignatureDefault, LandingPageDownloaded
				FROM CreativeMasterStg s
				INNER JOIN ' + @CreativeDetailTable + ' d ON s.PK_Id = d.CreativeStagingID
				INNER JOIN PatternMasterStg PMS ON PMS.FK_CreativeStgId = s.PK_Id 
                INNER JOIN ExceptionDetails ED ON PMS.PK_Id = ED.FK_PatternMasterStagingID
				WHERE d.LandingPageDownloaded = 0 AND d.CreativeFileType IS NOT NULL
				AND d.FileSize >= ' + @FileSize +
				' AND d.CreateDTM >= ' + CONVERT(VARCHAR(15), @CreatedDate) +
			    ' AND ED.MediaStream=''' + @MediaStream + ''' and ED.ExceptionStatus=''Requested''' +
				'ORDER BY d.CreativeStagingID, d.PK_CreativeDetailStagingID, d.CreativeAssetName'
		END
	EXEC(@query);
	print(@query);
    END TRY 
    BEGIN CATCH 
        DECLARE @Error   INT, @Message VARCHAR(4000), @LineNo  INT 
        SELECT @Error = Error_number(), @Message = Error_message(), @LineNo = Error_line() 
        RAISERROR ('sp_DigitalAdhocGetDataForPatternMediaRetrieval: %d: %s', 16, 1, @Error, @Message, @LineNo);
    END CATCH
END