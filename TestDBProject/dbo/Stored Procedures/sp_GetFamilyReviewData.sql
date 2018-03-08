-- =============================================    
-- Author:  Karunakar    
-- Create date: 04/01/2015    
-- Description:      
-- Execution Process: sp_GetFamilyReviewData null,31787,null,null,null,null    
-- =============================================    
CREATE PROCEDURE [dbo].[sp_GetFamilyReviewData]     
@AdvertiserId int,    
@Mediatype int,    
@AdId int,    
@OccuranceId BIGINT,    
@AdDateFrom datetime,    
@AdDateTo datetime    
AS    
BEGIN    
  
   DECLARE @Stmnt AS NVARCHAR(4000)=''     
      DECLARE @SessionType VARCHAR(50)=''     
      DECLARE @SelectStmnt AS NVARCHAR(max)=''     
      DECLARE @Where AS NVARCHAR(max)=''     
      DECLARE @Groupby AS NVARCHAR(max)=''     
      DECLARE @Orderby AS NVARCHAR(max)=''     
    
   DECLARE @GetAdID as INTEGER    
   DECLARE @GetOriginalAdID as INTEGER    
   Declare @isExecute as Bit=0    
   --DECLARE @basepath as nvarchar(100)    
   --SET @basepath=(Select Value from Configurationmaster where Componentname='Creative Repository' and Systemname='All')    
   --SET @basepath=@basepath+'\';    
    
  IF( @AdId Is  Null)    
  BEGIN    
  SET @AdId=0    
  END     
  IF( @OccuranceId Is  Null)    
  BEGIN    
  SET @OccuranceId=0    
  END     
    
   SET @SelectStmnt ='SELECT AdID,OriginalAdId,NoTakeReason,Unclassified,CreateDTM,Advertiser,Market,MediaType,Theme,Event,AdDate,StartDate,EndDate,    
      FirstRunMarket as FirstMarket,Pages,Size,Language, AdType,AdDistribution,EntryEligible,FrontPage,BackPage,OccuranceId,OccuranceStatus     
      FROM vw_FamilyReviewData'    
    
   SET @Where=' where (OriginalAdId IS NULL)'     
    
   IF(@AdId <> 0  OR @OccuranceId <> 0)    
    BEGIN    
     IF( @AdId <> 0)     
     BEGIN     
  SELECT @GetAdID=OriginalAdId from vw_FamilyReviewData where AdID=@AdId  
  IF (@GetAdID <> 0)  
   BEGIN  
    SET @AdId = @GetAdID  
   END     
 SET @Where=@Where + ' and AdID=' + Cast(@AdId AS VARCHAR)  
 --SET @Where=@Where + ' and AdID IN (SELECT AdID FROM vw_FamilyReviewData WHERE OriginalAdId =' + Cast(@AdId AS VARCHAR) +')'
  SET @isExecute=1    
     END     
     ELSE IF( @OccuranceId <> 0)     
     BEGIN      
      SELECT @GetAdID=AdID,@GetOriginalAdID=OriginalAdId from vw_FamilyReviewData where OccuranceId=@OccuranceId        
      IF(@GetOriginalAdID<>0 AND @GetOriginalAdID Is Not Null)    
      BEGIN    
        SET @AdId=@GetOriginalAdID    
            
      END    
      ELSE    
      BEGIN    
        SET @AdId=@GetAdID    
            
      END    
          
       IF( @AdId <> 0)     
       BEGIN       
        SET @Where=@Where + ' and AdID=' + Cast(@AdId AS VARCHAR)    
        SET @isExecute=1     
       END      
     END    
             
   END    
   ELSE    
    BEGIN    
     IF( @AdvertiserId <> 0 AND @AdvertiserId Is Not Null)     
     BEGIN     
       SET @Where=@Where + ' and AdvertiserID=' + Cast(@AdvertiserId AS VARCHAR)    
       SET @isExecute=1     
     END     
         
     IF( @Mediatype <> 0 AND @Mediatype Is Not Null)     
     BEGIN   
    IF @Mediatype<>-1   
    BEGIN  
  SET @Where=@Where + ' and MediaTypeID=' + Cast(@Mediatype AS VARCHAR)   
    END    
       SET @isExecute=1    
     END   
        
     IF( @AdDateFrom <> '' )     
     BEGIN     
      SET @Where= @where + ' AND AdDate >='''+convert(varchar,Cast(@AdDateFrom as date),110)+''''    
      SET @isExecute=1    
     END     
         
     IF(  @AdDateTo <> '' )     
     BEGIN     
      SET @Where= @where + ' AND AdDate <='''+convert(varchar,Cast(@AdDateTo as date),110)+''''    
      SET @isExecute=1    
     END     
             
   END    
       
   IF(@isExecute=1)    
    BEGIN    
     SET @Stmnt=@SelectStmnt + @Where    
     PRINT @Stmnt    
     EXECUTE Sp_executesql @Stmnt    
    END    
       
   END