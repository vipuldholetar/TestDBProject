-- ===========================================================================================
-- Author                         :      Dinesh Karthick S
-- Create date                    :      15/12/2015
-- Description                    :      This stored procedure is used for Deleting the Prmotional Record
-- Execution Process              :      [dbo].[sp_PEFDeletePromotionalEntryStageing] '5253'
-- Updated By                     :      
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_PEFDeletePromotionalEntryStageing] 
	 @UserID INT
AS 
  BEGIN 
      BEGIN TRY 
	    DECLARE @RowCountDetails INT,
				@RowCountMaster	INT
SELECT @RowCountDetails = COUNT(*) FROM [PromotionalDetailStaging]	
SELECT @RowCountMaster= COUNT(*) FROM [PromotionStaging]
IF(@RowCountDetails>0 AND @RowCountMaster>0 )
BEGIN
DELETE [PromotionalDetailStaging]
FROM [PromotionStaging] a, [PromotionalDetailStaging] b
WHERE b.[PromoStagingID] = a.[PromotionStagingID]
AND a.[LockedByID] = @UserID
DELETE [PromotionStaging]
WHERE [LockedByID] = @UserID
END
END TRY 
BEGIN CATCH 
		  DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_PEFDeletePromotionalEntryStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 
	    END;