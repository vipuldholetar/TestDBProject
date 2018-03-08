-- ====================================================================================================================================
-- Author		: Arun Nair  
-- Create date  : 07/07/2015 
-- Description  : stored procedure  for Outdoor Work Queue CreativeSignature Preview Details 
-- Execution	: [dbo].[sp_OutdoorWorkQueueCreativeSignaturePreviewData] --'2(x)ist,NY,PK,58th St & Park Ave,06-03-15.jpg' 
-- Updated By	: Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
--				  suresh on 20/01/2016 -changed Nvarchar to Varchar    
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorWorkQueueCreativeSignaturePreviewData] 
--'2(x)ist,NY,PK,58th St & Park Ave,06-03-15.jpg' 
(@CreativeSignatureId AS VARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          SELECT advertiser, 
                 format 
                 AS FormatDescription, 
                 market 
                 AS MarketDescription, 
                 [Query], 
                 [LanguageID], 
                 [language], 
                 creativefiletype, 
                 creativefilesize, 
                 imagefilename 
                 AS CreativeSignature, 
          --       CONVERT(VARCHAR(max), ( [dbo].[QueryDetail].querytext ) + 
          --                             ' | ' 
          --                             + 
          --CONVERT(VARCHAR(max), [dbo].[QueryDetail].[QryAnswer])) 
          --                                                     AS QA,  
		  [dbo].[QueryDetail].querytext,
		  [dbo].[QueryDetail].[QryAnswer],

          patternmasterstagingid, 
          ( [dbo].[user].fname + ' ' + [dbo].[user].lname ) 
                 AS 
  AuditBy, 
  CONVERT(VARCHAR(30), [dbo].[vw_outdoorworkqueuesessiondata].[AuditedDT], 101) 
  AS 
  AuditDTM 
  FROM   [dbo].[vw_outdoorworkqueuesessiondata] 
  LEFT JOIN [dbo].[QueryDetail] 
         ON 
[dbo].[QueryDetail].[PatternStgID] = [dbo].[vw_outdoorworkqueuesessiondata].patternmasterstagingid 
LEFT JOIN [dbo].[user] 
ON [dbo].[user].userid = [dbo].[vw_outdoorworkqueuesessiondata].[AuditedByID] 
WHERE  imagefilename = @CreativeSignatureId 
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('sp_OutdoorWorkQueueCreativeSignaturePreviewData: %d: %s',16, 
                   1, 
                   @error,@message, 
                   @lineNo); 
    END catch 
END