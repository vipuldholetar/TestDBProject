-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get Bad File Names List.  
-- Query :   
/* exec sp_ODRGetBadFileNamesList '15648381142',  
*/ 
-- ================================================================================================================   
Create PROCEDURE [dbo].[sp_ODRGetBadFileNamesList]
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 
		    SELECT * FROM 
			FTPSITEINVENTORY SI
			INNER JOIN CMSRAWDATA RD
			ON SI.[CMSFileName]=RD.CMSFILENAME
			WHERE RD.INGESTIONSTATUS='BADFILENAME'
		   COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_ODRGetBadFileNamesList: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
