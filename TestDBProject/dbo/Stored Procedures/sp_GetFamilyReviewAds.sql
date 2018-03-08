--sp_helptext 'sp_GetFamilyReviewAds'  
  
  
  
--=============================================================================        
-- Author  : Pronobesh          
-- Create date : 11th Jan 2016        
-- Description : Get the Family Review Ad Data        
-- Updated By :               
-- Execution : Exec sp_GetFamilyReviewAds 19621        
--===============================================================================        
        
CREATE PROCEDURE [dbo].[sp_GetFamilyReviewAds]        
@AdId int        
AS        
BEGIN     
  DECLARE @originalAdId int       
  DECLARE @FamilyReviewAds TABLE (        
  AdID     int NULL,        
  OriginalAdId int NULL,        
  NoTakeReason int NULL,        
  Unclassified bit NULL,        
  CreateDTM   datetime NULL,        
  AdvertiserID int NULL,        
  Advertiser       varchar(50) NULL,        
  Market   varchar(50) NULL,        
  MediaTypeID int NULL,        
  MediaType       varchar(50) NULL,        
  Theme       varchar(100) NULL,        
  Event       varchar(100) NULL,        
  AdDate       datetime NULL,        
  StartDate       datetime NULL,        
  EndDate       datetime NULL,        
  FirstMarket       nvarchar(100) NULL,        
  Pages       int NULL,        
  Size       nvarchar(100) NULL,        
  Language       varchar(50) NULL,        
  AdType       nvarchar(100) NULL,        
  AdDistribution       nvarchar(100) NULL,        
  EntryEligible       varchar(10) NULL,        
  FrontPage       varchar(200) NULL,        
  BackPage       varchar(200) NULL,        
  OccuranceId  int NULL,        
  OccuranceStatus Varchar(50)        
 )        
     
 BEGIN        
  INSERT INTO @FamilyReviewAds        
  SELECT AdID,OriginalAdId,NoTakeReason,Unclassified,CreateDTM,AdvertiserID,Advertiser,Market,MediaTypeID,MediaType,Theme,Event,        
  AdDate,StartDate,EndDate,[FirstRunMarketID] as FirstMarket,Pages,Size,Language,AdType,AdDistribution,EntryEligible,FrontPage,BackPage,        
  OccuranceId,OccuranceStatus FROM vw_FamilyReviewData WHERE AdID = @AdId    
 END     
     
     
 SET @originalAdId = (SELECT OriginalAdId FROM vw_FamilyReviewData WHERE  AdID = @AdId)   
 print @originalAdId    
 IF (@originalAdId <> 0)    
 BEGIN       
  INSERT INTO @FamilyReviewAds         
  SELECT AdID,OriginalAdId,NoTakeReason,Unclassified,CreateDTM,AdvertiserID,Advertiser,Market,MediaTypeID,MediaType,Theme,Event,        
  AdDate,StartDate,EndDate,[FirstRunMarketID] as FirstMarket,Pages,Size,Language,AdType,AdDistribution,EntryEligible,FrontPage,BackPage,        
  OccuranceId,OccuranceStatus FROM vw_FamilyReviewData WHERE AdID = @originalAdId     
 END   
 --ELSE  
  BEGIN  
	 INSERT INTO @FamilyReviewAds         
	 SELECT AdID,OriginalAdId,NoTakeReason,Unclassified,CreateDTM,AdvertiserID,Advertiser,Market,MediaTypeID,MediaType,Theme,Event,        
	 AdDate,StartDate,EndDate,[FirstRunMarketID] as FirstMarket,Pages,Size,Language,AdType,AdDistribution,EntryEligible,FrontPage,BackPage,        
	 OccuranceId,OccuranceStatus FROM vw_FamilyReviewData WHERE AdID IN (SELECT AdID FROM vw_FamilyReviewData WHERE OriginalAdId = @AdId)  
  END  
   
       
        
 SELECT AdID,        
 OriginalAdId,        
 NoTakeReason,        
 Unclassified,        
 CONVERT(VARCHAR(10),CreateDTM,20) As CreateDTM,        
 AdvertiserID,        
 Advertiser,        
 Market,        
 MediaTypeID,        
 MediaType,        
 Theme,        
 Event,        
 AdDate,        
 StartDate,        
 EndDate,        
 FirstMarket,        
 Pages,        
 Size,        
 Language,        
 AdType,        
 AdDistribution,        
 EntryEligible,        
 FrontPage,        
 BackPage,        
 OccuranceId,        
 OccuranceStatus         
 FROM @FamilyReviewAds         
END