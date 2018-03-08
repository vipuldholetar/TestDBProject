-- ===========================================================================================
-- Author                         :      Dinesh Karthick S
-- Create date                    :      28/12/2015
-- Description                    :      This stored procedure is used for DeletingRejecting the Prmotional Record
-- Execution Process              :      [dbo].[sp_PEFDeleteRejectPromotionalEntryStageing] '5253'
-- Updated By                     :      
-- ============================================================================================


CREATE PROCEDURE [dbo].[sp_PEFDeleteRejectPromotionalEntryStageing] 
	 @UserID INT,
	 @CorpID INT
AS 
  BEGIN 
      BEGIN TRY 
		BEGIN
		UPDATE [PromotionStaging]
		set [DeletedInd]= 1
		where [LockedByID] =@UserID AND [CompositeCropID]=@CorpID
		END
	  END TRY 
BEGIN CATCH 
		  DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_PEFDeleteRejectPromotionalEntryStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 
	    END;