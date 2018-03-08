
-- Author:    Govardhan   
-- Create date: 2/18/2015   
-- Description:  Fetch active websites from the table COMS_WEBSITES 
-- Query : exec [sp_COMFetchActiveWebsites]   
-- =============================================   
CREATE PROC [dbo].[sp_COMFetchActiveWebsites] 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
          SELECT DISTINCT  top 20  CW.[COMWebsiteID], 
                          CW.[SiteName], 
                          WebES.[ExtSrcName] 
          FROM   [COMWebsite] CW 
                 INNER JOIN [COMWebsiteExtSrcMap] WebES 
                         ON CW.[COMWebsiteID] = WebES.[SiteID] 
          WHERE  WebES.[ExtSrcEndDT] >= Getdate() 
                 AND WebES.[ExtSrcName] <> '' 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_COMFetchActiveWebsites: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 
      END catch; 
  END;
