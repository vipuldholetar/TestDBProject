

-- ===========================================================================================
-- Author                         :   Ganesh Prasad
-- Create date                    :   11/09/2015
-- Description                    :   This stored procedure is used to Get Data for Daily New advertsiers Report Dataset
-- Execution Process              :   [dbo].[sp_CleanUpSession] 
-- Updated By                     :  
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_CleanUpSession] 

AS
BEGIN
       
       SET NOCOUNT ON;
       BEGIN TRY
       
       select distinct
        BusinessOwner,FolderPath,ParentFolder,SizeBeforeCleanup,NumberOfFilesBfrCleanup,NumberofDays,
SubFolderCleanup from FolderCleanupData
 
       END TRY
                           BEGIN CATCH 
                 DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
                 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                 RAISERROR ('[sp_CleanUpSession] : %d: %s',16,1,@error,@message,@lineNo); 
                END CATCH 

       END
