-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec sp_TMSPopulateTMSEpisodes 1,'NT AUTHORITY\SYSTEM' ,1 
-- =============================================  
CREATE PROCEDURE [dbo].[sp_TMSPopulateTMSEpisodes] 
(
	@EthnicId        AS INT, 
	@UserName        AS VARCHAR(20), 
	@IngestionTypeID AS INT 
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
   		 
		-- Insert EpisodeID,EpisodeName from TMS_Transalation which are not present in TMS_TV_Episodes table  
		 INSERT INTO TMSTvEpisodes 
          SELECT DISTINCT [TMSTvProgID], 
                          [ProgEpisodeID], 
                          ProgEpisodeName, 
                          [ProgSyndicatorID], 
                          GETDATE() 
          FROM   [TMSTvProg] TPM 
                 INNER JOIN TMSTranslation TT 
                         ON TPM.ProgDescrip = TT.ProgName 
          WHERE  [ProgEpisodeID] NOT IN (SELECT DISTINCT [CK_EpisodeId] 
                                         FROM   TMSTvEpisodes) 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = ERROR_NUMBER(), 
                 @Message = ERROR_MESSAGE(), 
                 @LineNo = ERROR_LINE() 

          RAISERROR ('sp_TMSPopulateTMSEpisodes: %d: %s',16,1,@Error,@Message, 
                     @LineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
