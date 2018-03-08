  
 CREATE PROCEDURE [dbo].[sp_MultiMapAproveforAllMarketAndAirDate] ( 
    @TempForApproval dbo.MultiMapApproval readonly, 
    @OriginalPatternCode varchar(max), 
    @AdId int, 
    @MediaStream INT, 
    @Status Varchar(20) ,  
    @MarketId INT,    
    @MINDATE DATETIME,
	@CreatedBy INT 
 )  
 AS  
  IF 1 = 0  
       BEGIN  
           SET FMTONLY OFF  
       END 
   BEGIN  
       SET nocount ON;  
       BEGIN TRY  
 		  DECLARE @FakePatternCode INT = 0  
 		  DECLARE @FinalPatterMasterID INT = 0	 
 		  DECLARE @TempALLMarket TABLE  (OccurrenceID INT,FakePatternCode INT,OriginalPatternCode VARCHAR(200)) 
           BEGIN TRANSACTION			  
 		  SELECT @FakePatternCode = [TVMMPRCodeCODE] FROM [TVMMPRCode] WHERE OriginalPatternCode = @OriginalPatternCode and [AdID]=@AdId and [ApprovedMarketID] IS NULL 
 		  IF(@FakePatternCode = 0) 
 			  BEGIN 
 		  		INSERT INTO [TVMMPRCode] (OriginalPatternCode,MediaStream,[AdID],ApprovedForAllMarkets,[ApprovedMarketID],Status,[EffectiveEndDT],[EffectiveStartDT],[CreatedDT],[CreatedByID],[ModifiedDT])  
 				VALUES (@OriginalPatternCode,'TV',@AdId,1,NULL,@Status,NULL,@MINDATE,GetDate(),@CreatedBy,GetDate())	 
  
 				SELECT @FakePatternCode = MAX([TVMMPRCodeCODE]) FROM [TVMMPRCode] 
 			  END 
 		 
 			  BEGIN 
 					INSERT INTO [Pattern] ([AdID],[CreativeID],CreativeSignature,MediaStream,Status) 
 					SELECT DISTINCT @AdId,NULL,@FakePatternCode,@MediaStream,'Valid' 
 					FROM [TVMMPRCode] a , @TempForApproval b  
 					WHERE a.OriginalPatternCode = b.OriginalPatternCode 
 					AND a.ApprovedForAllMarkets = 1 
 					AND a.[AdID] = @AdId 
 					AND (b.AirDate >= a.[EffectiveStartDT] OR a.[EffectiveStartDT] IS NULL) 
 					AND (b.AirDate <= a.[EffectiveEndDT] OR a.[EffectiveEndDT] IS NULL) 
 					AND a.[Status] = @Status 
  
 					SELECT @FinalPatterMasterID = MAX([PatternID]) FROM [Pattern] 
 				END					 
 				DECLARE @RowCount INT = (SELECT COUNT(*) FROM @TempForApproval)		 
 	 
 			    IF @RowCount > 0 
 					UPDATE [OccurrenceDetailTV] 
 					SET [AdID] = @AdId, 
 					[FakePatternCODE] = @FakePatternCode, 
 					[PatternID] = @FinalPatterMasterID 
 					WHERE [OccurrenceDetailTVID] IN (SELECT OccurrenceID FROM @TempForApproval)					 
 		COMMIT TRANSACTION  
       END TRY  
  
       BEGIN CATCH  
           DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
           SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()  
           RAISERROR ('[sp_MultiMapGetRejGeoAndAirDate]: %d: %s',16,1,@error,@message,@lineNo) 
           ROLLBACK TRANSACTION  
       END CATCH  
   END