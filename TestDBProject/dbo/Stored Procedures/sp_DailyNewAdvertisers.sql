
-- ===========================================================================================
-- Author                         :   Ganesh Prasad
-- Create date                    :   09/02/2015
-- Description                    :   This stored procedure is used to Get Data for Daily New advertsiers Report Dataset
-- Execution Process              :   [dbo].[sp_DailyNewAdvertisers] 
-- Updated By                     :  
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_DailyNewAdvertisers]  

AS
BEGIN
       
       SET NOCOUNT ON;
       BEGIN TRY
       
       select distinct
          [dbo].[Configuration].ValueTitle as [MediaType],
          [dbo].Ad.[AdID] as [ADID], .
          [dbo].Ad.[AdvertiserID] as [AdvertiserID],
          [dbo].[Advertiser].Descrip as [AdvertiserName],
          [dbo].RefIndustryGroup.IndustryName as Industry,
          [dbo].[Advertiser].[ParentAdvertiserID],
           (select b.Descrip from [Advertiser] b where b.advertiserid=[Advertiser].[ParentAdvertiserID])  as [ParentAdvertiserName],--sub query with self join to get parentAdvertsierName
         [dbo].[User].fname+' ' +[dbo].[user].lname as [CreatedBy]
         from [dbo].[Pattern]
        Inner Join [dbo].Ad
         On [dbo].[Pattern].[AdID] = [dbo].Ad.[AdID]
        Inner Join [dbo].[Advertiser] 
         On [dbo].Ad.[AdvertiserID] = [dbo].[Advertiser] .AdvertiserID
        Inner join [dbo].AdvertiserIndustryGroup
         On [dbo].[Advertiser] .AdvertiserID = AdvertiserIndustryGroup.[AdvertiserID]
        Inner Join  [dbo].RefIndustryGroup
         On [dbo].AdvertiserIndustryGroup.[IndustryGroupID] = RefIndustryGroup.[RefIndustryGroupID]
        Inner Join [dbo].[User]
         On [dbo].Ad.CreatedBy = [dbo].[User].UserId
       Inner join  [dbo].[Configuration]
           on  [dbo].[Pattern].MediaStream=[dbo].[Configuration].ConfigurationID  
		    
      --where convert(Date,Ad.Createdate )= convert(Date,GetDate() -1) --filters the records of previous day
	   order by   CreatedBy  
       END TRY
                           BEGIN CATCH 
                 DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
                 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                 RAISERROR ('[SP_DailyNewAdvertisers]: %d: %s',16,1,@error,@message,@lineNo); 
                END CATCH 

       END
