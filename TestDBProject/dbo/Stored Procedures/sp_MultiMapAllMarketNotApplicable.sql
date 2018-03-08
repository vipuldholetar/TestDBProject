  
 CREATE PROCEDURE [dbo].[sp_MultiMapAllMarketNotApplicable] 
 ( 
 	@AdvertiserId int 
 ) 
 AS  
 BEGIN 
   SET NOCOUNT ON 
       BEGIN TRY          
 		DECLARE @Status as int 
 		DECLARE @Flag as int  
 	    SELECT  @Status = COUNT(*) FROM AdvertiserMarket  
 		WHERE [AdvertiserID] = @AdvertiserId AND AllMarketIndicator = 1
 		SELECT @Status as IsStatus		 
       END TRY 
       BEGIN CATCH 
           DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT  
           SELECT @error = Error_number(),@message = Error_message(), 
                  @lineNo = Error_line() 
           RAISERROR ('[sp_MultiMapAllMarketNotApplicable]: %d: %s',16,1,@error,@message,@lineNo)		   
       END CATCH 
   END