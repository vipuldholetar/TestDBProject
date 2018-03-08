
-- Author:    Govardhan   
-- Create date: 2/18/2015   
-- Description:  Fetch active websites from the table COMS_WEBSITES 
-- Query : exec [usp_COMS_FetchActiveWebsites]   
-- =============================================   
CREATE PROC [dbo].[usp_COMS_FetchActiveWebsites] 
AS 
  BEGIN 
      SET nocount ON 

      BEGIN try 
          SELECT DISTINCT  top 20  CW.siteid, 
                          CW.sitename, 
                          WebES.externalsourcename 
          FROM   coms_websites CW 
                 INNER JOIN coms_website_external_source_map WebES 
                         ON CW.siteid = WebES.siteid 
          WHERE  WebES.externalsource_enddate >= Getdate() 
                 AND WebES.externalsourcename <> '' 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_COMS_FetchActiveWebsites: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 
      END catch; 
  END;
