-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec usp_TMS_04_PopulateTMSSTations 'NT AUTHORITY\SYSTEM'  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_TMS_04_PopulateTMSSTations] 
(
	@UserName        AS VARCHAR(20)
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @userid INT 

          -- Retreiving userID  
          SELECT @userid = userid 
          FROM   tms_users 
          WHERE  username = @Username 
   		 
		-- Inserting records to TMS station master     
          INSERT INTO tms_tv_station 
          SELECT DISTINCT prog_tms_channel, 
                          null,
                          GETDATE(), 
                          @userid, 
                          GETDATE(), 
                          @userid 
          FROM   tms_translation 
          WHERE  prog_tms_channel NOT IN (SELECT DISTINCT tv_station_name 
                                          FROM   tms_tv_station)

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = ERROR_NUMBER(), 
                 @message = ERROR_MESSAGE(), 
                 @lineNo = ERROR_LINE() 

          RAISERROR ('usp_TMS_04_PopulateTMSSTations: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
