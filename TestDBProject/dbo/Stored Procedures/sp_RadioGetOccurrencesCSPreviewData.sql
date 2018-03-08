
-- ==========================================================================================================================
-- Author		: Arun Nair 
-- Create date  : 04/01/2015 
-- Description  : This stored procedure is used to fill the Data in Radio Work Queue CreativeSignature Preview Details 
-- Execution	: [dbo].[sp_RadioGetOccurrencesCSPreviewData] "M2856905-21585350"   
-- Updated By	: Karunakar on 04/27/2015 - Added RCSAccountID 
--				  Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[sp_RadioGetOccurrencesCSPreviewData] (@pCreativeId 
VARCHAR(50)) 
AS 
  BEGIN 
      SET nocount ON; 

      --BEGIN try 
          SELECT top 1 market, 
					creativefiletype, 
					creativefilesize, 
					rcsparentcompany, 
					rcsaccount, 
					rcsaccountid, 
					rcsclass, 
					[Language], 
					[dbo].[QueryDetail].[QueryText],
					[dbo].[QueryDetail].[QryAnswer],
					languageid, 
					( fname + ' ' + lname ) AS AuditBy, 
					CONVERT(VARCHAR(30), [AuditedDT], 101) AS AuditDTM 
			FROM   vw_occurencesbysessiondate 
			LEFT JOIN [dbo].[QueryDetail] ON [dbo].[QueryDetail].[PatternStgID] = [dbo].[vw_occurencesbysessiondate].patternmasterstagingid 
			LEFT JOIN [dbo].[user] 
			ON [dbo].[user].userid = vw_occurencesbysessiondate.[AuditedByID] 
			WHERE  rcscreativeid = @pCreativeId 
			Option (maxdop 1)
	--END try 

	--BEGIN catch 
	--DECLARE @error   INT, 
	--@message VARCHAR(4000), 
	--@lineNo  INT 

	--SELECT @error = Error_number(), 
	--@message = Error_message(), 
	--@lineNo = Error_line() 

	--RAISERROR ('sp_RadioGetOccurrencesCSPreviewData: %d: %s',16,1,@error, 
	--@message,@lineNo); 
	--END catch 
END