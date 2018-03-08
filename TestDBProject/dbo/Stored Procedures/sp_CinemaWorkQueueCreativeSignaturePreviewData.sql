
-- ====================================================================================================================================
-- Author    : Arun Nair  
-- Create date  : 07/07/2015 
-- Description  : This stored procedure is used to fill the Data in Outdoor Work Queue CreativeSignature Preview Details 
-- Execution  : sp_CinemaWorkQueueCreativeSignaturePreviewData '244332lov',7 
-- Updated By  : Karunakar on 7th Sep 2015 
--          Arun Nair on 09/15/2015 - Query Optimise 
--          Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaWorkQueueCreativeSignaturePreviewData] ( 
@CreativeSignature AS VARCHAR(max), 
@MarketId          AS INTEGER) 
AS 
BEGIN 
SET nocount ON; 

	BEGIN try 
		SELECT TOP 1 
		customer, 
		[CINPattern].length, 
		isquery, 
		[vw_cinemaworkqueuesessiondata].[LanguageID], 
		[Language].description 
		AS Language, 
		creativefiletype, 
		creativefilesize, 
		marketid, 
		marketdescription 
		AS MediaOutlet, 
		[dbo].[QueryDetail].[QueryText], 
		[dbo].[QueryDetail].[QryAnswer], 
		( [dbo].[user].fname + ' ' + [dbo].[user].lname ) AS AuditBy, 
		CONVERT(VARCHAR(30), [dbo].[vw_cinemaworkqueuesessiondata].auditdtm, 101) AS AuditDTM 
		FROM   [dbo].[vw_cinemaworkqueuesessiondata] 
		INNER JOIN [Language] 
		ON [Language].languageid = 
		dbo.[vw_cinemaworkqueuesessiondata].[LanguageID] 
		INNER JOIN [CINPattern] 
		ON dbo.[CINPattern].[CreativeID] = 
		dbo.[vw_cinemaworkqueuesessiondata].creativesignature 
		LEFT JOIN [dbo].[QueryDetail] 
		ON 
		[dbo].[QueryDetail].[PatternStgID] = [dbo].[vw_cinemaworkqueuesessiondata].patternmasterstagingid 
		LEFT JOIN [dbo].[user] 
		ON [dbo].[user].userid = [dbo].[vw_cinemaworkqueuesessiondata].auditby 
		WHERE  creativesignature = @CreativeSignature 
		AND marketid = @MarketId 
	END try 

	BEGIN catch 
	DECLARE @error   INT, 
	@message VARCHAR(4000), 
	@lineNo  INT 

	SELECT @error = Error_number(), 
	@message = Error_message(), 
	@lineNo = Error_line() 

	RAISERROR ('[sp_CinemaWorkQueueCreativeSignaturePreviewData]: %d: %s',16 
	,1, 
	@error,@message, 
	@lineNo); 
	END catch 
END