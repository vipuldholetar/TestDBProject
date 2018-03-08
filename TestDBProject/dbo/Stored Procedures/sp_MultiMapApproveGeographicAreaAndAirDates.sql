  
 CREATE PROCEDURE [dbo].[sp_MultiMapApproveGeographicAreaAndAirDates] 
 	 ( 
         @OriginalPatternCode varchar(max), 
         @AdId int, 
         @MediaStream INT, 
         @Status Varchar(20), 
 		@MarketId INT,  
 		@MINDATE DATETIME, 
 		@TempForApproval dbo.MultiMapApproval readonly,
		@CreatedBy INT   
 	  ) 
 AS 
  IF 1 = 0  
       BEGIN  
           SET FMTONLY OFF  
       END   
 BEGIN 
   SET NOCOUNT ON 
       BEGIN TRY  
 		  DECLARE @FakePatternCode INT = 0  
 		  DECLARE @FinalPatterMasterID INT = 0	 
 		  DECLARE @TempALLMarket TABLE  (OccurrenceID INT,FakePatternCode INT,OriginalPatternCode VARCHAR(200)) 
         BEGIN TRANSACTION 
 		  SELECT @FakePatternCode = [TVMMPRCodeCODE] FROM [TVMMPRCode] WHERE OriginalPatternCode = @OriginalPatternCode and [AdID]=@AdId and [ApprovedMarketID] = @MarketId 
 		  print @FakePatternCode 
 		  IF(@FakePatternCode=0) 
 			BEGIN 
 				INSERT INTO [TVMMPRCode] (OriginalPatternCode,MediaStream,[AdID],ApprovedForAllMarkets,[ApprovedMarketID],Status,[EffectiveEndDT],[EffectiveStartDT],[CreatedDT],[CreatedByID],[ModifiedDT])  
 				VALUES (@OriginalPatternCode,'TV',@AdId,0,@MarketId,@Status,NULL,@MINDATE,GetDate(),@CreatedBy,GetDate())	 
 				 
 				SELECT @FakePatternCode = MAX([TVMMPRCodeCODE]) FROM [TVMMPRCode]					 
 			END		   
 		 BEGIN			 
 			BEGIN 
 				INSERT INTO [Pattern] ([AdID],[CreativeID],CreativeSignature,MediaStream,Status) 
 				SELECT DISTINCT @AdId,NULL,@FakePatternCode,@MediaStream,'Valid' 
 				FROM [TVMMPRCode] a 
 				INNER JOIN @TempForApproval b ON a.OriginalPatternCode = b.OriginalPatternCode 
 				WHERE a.ApprovedForAllMarkets = 0 
 				AND a.[AdID] = @AdId 
 				AND (b.AirDate >= a.[EffectiveStartDT] OR a.[EffectiveStartDT] IS NULL) 
 				AND (b.AirDate <= a.[EffectiveEndDT] OR a.[EffectiveEndDT] IS NULL) 
 				AND (a.Status = @Status) 
  
 				SELECT @FinalPatterMasterID = MAX([PatternID]) FROM [Pattern] 
 				print @FinalPatterMasterID 
 			END	 		 
 		   END 		   
 		   BEGIN 
 			INSERT INTO @TempALLMarket(OccurrenceID,FakePatternCode,OriginalPatternCode) 
 			SELECT a.OccurrenceID as OccurrenceID, @FakePatternCode as FakePatternCode,@OriginalPatternCode as OriginalPatternCode 
 			FROM @TempForApproval a WHERE a.MarketId = @MarketId				 
 		   END		 
 		   DECLARE @RowCount INT = (SELECT COUNT(*) FROM @TempALLMarket) 
 		   print @RowCount	 
 		   IF @RowCount > 0                     
 			BEGIN 
 				UPDATE [OccurrenceDetailTV] 
 				SET [AdID] = @AdId, 
 				[FakePatternCODE] = @FakePatternCode, 
 				[PatternID] = @FinalPatterMasterID 
 				WHERE [OccurrenceDetailTVID] IN (SELECT OccurrenceID FROM @TempALLMarket) 
             END   
 		COMMIT TRANSACTION  
       END TRY 
       BEGIN CATCH  
           DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT  
           SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line()  
           RAISERROR ('[sp_MultiMapApproveGeographicAreaAndAirDates]: %d: %s',16,1,@error,@message,@lineNo) 
           ROLLBACK TRANSACTION  
       END CATCH  
   END