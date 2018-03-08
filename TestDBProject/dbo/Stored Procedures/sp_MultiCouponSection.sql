-- ===================================================================================================
-- Author            : Amrutha
-- Create date       : 1/20/2016
-- Description       : Display of Section in MultiCoupon 
-- EXEC              : sp_MultiCouponSection
-- Updated By		 : Arun Nair on 01/27/2016 - Added Exception in Sp,Distinct
-- ====================================================================================================
CREATE PROCEDURE [dbo].[sp_MultiCouponSection]
            
AS
BEGIN
	 SET NOCOUNT ON;
      BEGIN TRY 
			SELECT Distinct ValueTitle,Value,ValueGroup FROM [Configuration] 
			WHERE SystemName = 'All' AND ComponentName = 'Coupon Book to Pub'
	  END TRY 
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_MultiCouponSection]: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH 
END
