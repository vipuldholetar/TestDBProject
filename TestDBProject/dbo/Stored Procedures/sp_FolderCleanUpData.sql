-- ===========================================================================================
-- Author                         :      Ganesh prasad
-- Create date                    :      11/18/2015
-- Description                    :      This stored procedure is used for getting Data to "FolderCleanUpData" table to sdisplay as  Report Dataset
-- Execution Process              :      [dbo].[sp_FolderCleanUpData]
-- Updated By                     :      
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_FolderCleanUpData] (@FolderCleanUpData [dbo].[FolderCleanUpData] readonly)
 AS
BEGIN
SET NOCOUNT ON;
      BEGIN try 
          BEGIN TRANSACTION 
			
			INSERT INTO [dbo].[FolderCleanUpData]
						([BusinessOwner], [FolderPath], [ParentFolder], [SizeBeforeCleanup],   
						 [NumberOfFilesBfrCleanup], [NumberofDays],[SubFolderCleanup])
			SELECT [BusinessOwner], [FolderPath], [ParentFolder], [SizeBeforeCleanup],   
						 [NumberOfFilesBfrCleanup], [NumberofDays],[SubFolderCleanup]
				   FROM @FolderCleanUpData		
        
          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_FolderCleanUpData: %d: %s',16,1,@error,@message, 
                     @lineNo 
          ); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
