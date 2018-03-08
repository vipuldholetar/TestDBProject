CREATE FUNCTION [dbo].[ufn_IsQualifiedForMultiMap] (@AdvID int) 
 RETURNS int 
 AS 
 	BEGIN 
 		DECLARE @QualifiedforMultiMap bit = 0 
 		DECLARE @Count int 
  
 		SELECT @Count =  Count(b.[RefIndustryGroupID]) FROM AdvertiserIndustryGroup a, RefIndustryGroup b WHERE a.[AdvertiserID] = @AdvID 
 					   AND b.[RefIndustryGroupID] = a.[IndustryGroupID] AND b.[MultiMapInd] = 1
  
 		IF(@Count > 0) 
 		BEGIN 
 			SET @QualifiedforMultiMap = 1 
 		END 
 		ELSE IF (@Count = 0) 
 		BEGIN  
 			SELECT @Count = Count([MarketID]) FROM AdvertiserMarket WHERE [AdvertiserID] = @AdvID 
 			IF(@Count > 0) 
 			BEGIN 
 				SET @QualifiedforMultiMap = 1 
 			END 
 		END 
 		RETURN (@QualifiedforMultiMap) 
 	END