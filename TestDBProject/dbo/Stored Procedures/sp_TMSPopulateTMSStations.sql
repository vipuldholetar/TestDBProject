-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec sp_TMSPopulateTMSStations 'NT AUTHORITY\SYSTEM'  
-- =============================================  
CREATE PROCEDURE [dbo].[sp_TMSPopulateTMSStations] 
(
	@UserName        AS VARCHAR(20)
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @UserId INT 

          -- Retreiving userID  
          SELECT @UserId = [TMSUserID] 
          FROM   [TMSUser] 
          WHERE  UserName = @Username 
   		 
		-- Inserting records to TMS station master     
          INSERT INTO [TMSTvStation] 
          SELECT DISTINCT [ProgTMSChannel], 
                          null,
                          GETDATE(), 
                          @UserId, 
                          GETDATE(), 
                          @UserId 
          FROM   [TMSTranslation] 
          WHERE  [ProgTMSChannel] NOT IN (SELECT DISTINCT [TvStationName] 
                                          FROM   [TMSTvStation])

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = ERROR_NUMBER(), 
                 @Message = ERROR_MESSAGE(), 
                 @LineNo = ERROR_LINE() 

          RAISERROR ('sp_TMSPopulateTMSStations: %d: %s',16,1,@Error,@Message, 
                     @LineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
