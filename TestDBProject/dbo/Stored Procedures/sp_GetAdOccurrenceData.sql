  
-- ==============================================================================================================  
-- Author  : S.Dinesh Karthick   
-- Create date : 6th Jan 2015  
-- Description : This stored procedure is used to fill the Occurrence Data  
-- Execution : sp_GetAdOccurrenceData NULL,520015   sp_GetAdOccurrenceData 19622,null  
-- Updated By : sp_GetAdOccurrenceData '520015,520015,520016,520017'  
-- ===============================================================================================================  
CREATE PROCEDURE [dbo].[sp_GetAdOccurrenceData]  
 @AdId as INT,  
 @OccurrenceID INT  
AS  
 DECLARE @GetAdId INT  
BEGIN  
 SET NOCOUNT ON;  
 IF @AdId = 0  
  SET @AdId = NULL  
 IF @OccurrenceID = 0  
  SET @OccurrenceID = NULL  
   
 BEGIN TRY    
  
 --Declare @basepath as nvarchar(100)  
 --Set @basepath=(Select Value from Configurationmaster where Componentname='Creative Repository' and Systemname='All')  
 --set @basepath=@basepath+'\';  
  
 IF (@AdId IS NOT NULL AND (@OccurrenceID IS  NOT NULL OR @OccurrenceID IS NULL))  
  BEGIN   
    
   Select [OccurrenceDetailCIRID] as OccurrenceID ,FrontPage,BackPage,CreateDTM,Market,MediaType,Theme,Event,AdDate,StartDate,
EndDate,FirstMarket,Pages,  
   Language,Status,CASE WHEN FlashStatus =1 THEN 'Yes'ELSE 'No' END AS FlashStatus,FlyerID,SizeDescription,AdId,Advertiser  
   from vw_MergeQueueOccurrenceData where AdId =@AdId AND Status<> (SELECT ValueTitle FROM [Configuration] WHERE ComponentName = 'Occurrence Status' AND Value = 'NT')  
     
  END  
   
 ELSE IF (@AdId IS  NULL AND @OccurrenceID IS  NOT NULL)     
 BEGIN  
 SELECT  @GetAdId =  a.AdID FROM  vw_MergeQueueOccurrenceData a WHERE a.[OccurrenceDetailCIRID] = @OccurrenceID  
    
  SELECT [OccurrenceDetailCIRID] as OccurrenceID,FrontPage,BackPage,CreateDTM,Market,MediaType,Theme,Event,AdDate,StartDate,EndDate,FirstMarket,Pages,  
  Language,Status,CASE WHEN FlashStatus =1 THEN 'Yes'ELSE 'No' END AS FlashStatus,FlyerID,SizeDescription,AdId,Advertiser  
  from vw_MergeQueueOccurrenceData where AdId =@GetAdId  AND Status<> (SELECT ValueTitle FROM [Configuration] WHERE ComponentName = 'Occurrence Status' AND Value = 'NT')
  
 END  
END TRY  
 BEGIN CATCH   
    DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT  
    SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()   
    RAISERROR ('sp_GetAdOccurrenceData: %d: %s',16,1,@error,@message,@lineNo);   
 END CATCH   
END
