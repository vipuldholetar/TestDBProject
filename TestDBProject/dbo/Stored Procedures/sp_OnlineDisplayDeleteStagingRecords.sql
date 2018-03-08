
-- =================================================================================================================      
-- Author			: Karunakar     
-- Create date		: 21st September 2015     
-- Description		: This Procedure is Used to delete records from online display staging tables
-- Execution		: sp_OnlineDisplayDeleteStagingRecords  
-- Updated By		:      
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineDisplayDeleteStagingRecords] 
(
@CreativeStagingID INT
) 
AS 
  BEGIN try 
      --BEGIN TRANSACTION 

      --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster                  
      DELETE FROM [dbo].[PatternStaging] 
      WHERE  [CreativeStgID] = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeDetailStagingOND] 
      WHERE  CreativeStagingID = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeStaging] 
      WHERE  [CreativeStagingID] = @CreativeStagingID 
  END try 

  BEGIN catch 
			  DECLARE @error   INT, 
              @message VARCHAR(4000), 
              @lineno  INT 
      SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
      RAISERROR ('sp_OnlineDisplayDeleteStagingRecords: %d: %s',16,1,@error,@message, @lineno); 
      --ROLLBACK TRANSACTION 
  END catch