-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec usp_TMS_09_PopulateTMSEpisodes 1,'NT AUTHORITY\SYSTEM' ,1 
-- =============================================  
CREATE PROCEDURE [dbo].[usp_TMS_09_PopulateTMSEpisodes] 
(
	@EthnicID        AS INT, 
	@UserName        AS VARCHAR(20), 
	@IngestionTypeID AS INT 
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
   		 
		-- Insert EpisodeID,EpisodeName from TMS_Transalation which are not present in TMS_TV_Episodes table  
		 INSERT INTO tms_tv_episodes 
          SELECT DISTINCT prog_id, 
                          prog_episode_id, 
                          prog_episode_name, 
                          prog_syndicator_id, 
                          GETDATE() 
          FROM   tms_tv_prog_mst tpm 
                 INNER JOIN tms_translation tt 
                         ON tpm.prog_desc = tt.prog_name 
          WHERE  prog_episode_id NOT IN (SELECT DISTINCT episode_id 
                                         FROM   tms_tv_episodes) 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = ERROR_NUMBER(), 
                 @message = ERROR_MESSAGE(), 
                 @lineNo = ERROR_LINE() 

          RAISERROR ('usp_TMS_09_PopulateTMSEpisodes: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
