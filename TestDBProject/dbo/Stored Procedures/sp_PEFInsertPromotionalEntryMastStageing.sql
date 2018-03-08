-- ===========================================================================================
-- Author                         :      Dinesh Karthick S
-- Create date                    :      15/12/2015
-- Description                    :      This stored procedure is used for Deleting the Prmotional Record
-- Execution Process              :      [dbo].[sp_PEFInsertPromotionalEntryStageing] '5253'
-- Updated By                     :      
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_PEFInsertPromotionalEntryMastStageing] 
	 @CorpID INT,
	 @CategoryID INT,
	 @UserID INT

AS 
BEGIN 
BEGIN TRY 
BEGIN TRANSACTION

INSERT INTO [PromotionStaging]
([PromoID],
[CompositeCropID],
[CategoryID],
[AdvertiserID],
[ProductID],
[ProductDescrip],
[DeletedInd],
[LockedByID],
[LockedDT])
		SELECT [PromotionID],
			[CropID],
			[CategoryID],
			[AdvertiserID],
			[ProductID],
			[ProductDescrip],
			'False',
			@UserID,
			CURRENT_TIMESTAMP
		FROM [Promotion]
		WHERE [CropID] = @CorpID
		AND [CategoryID]= @CategoryID
		ORDER BY [PromotionID]

	 COMMIT TRANSACTION	
	  END TRY
	  BEGIN CATCH 
		  DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_PEFInsertPromotionalEntryMastStageing: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 
	    END;