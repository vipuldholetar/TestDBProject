-- =============================================
-- Author:		Ganesh Prasad
-- Create date: 09/04/2015
-- Description:	Serves as dataset for "Monthly TBD Previous Month table" in "MonthlyTBD" Report.
-- =============================================
CREATE Procedure [dbo].[sp_MonthlyTBDPreviousMonth]
AS
BEGIN
	 
	SET NOCOUNT ON;
	BEGIN TRY
(select * from 
 (select  
       [dbo].Ad.[AdvertiserID] ,
       [dbo].[Configuration].ValueTitle,--- Converted to Columns of the Report
       [dbo].RefIndustryGroup.IndustryName
       from [dbo].[Pattern]
        Inner Join [dbo].Ad
         On [dbo].[Pattern].[AdID] = [dbo].Ad.[AdID]
        Inner Join [dbo].[Advertiser] 
         On [dbo].Ad.[AdvertiserID] = [Advertiser] .AdvertiserID
        Inner join [dbo].AdvertiserIndustryGroup
         On [dbo].Ad.[AdvertiserID] = [dbo].AdvertiserIndustryGroup.[AdvertiserID]
        Inner Join [dbo].RefIndustryGroup
         On [dbo].AdvertiserIndustryGroup.[IndustryGroupID] = [dbo].RefIndustryGroup.[RefIndustryGroupID]
        Inner join  [dbo].[Configuration] 
		 On [dbo].[Pattern].MediaStream=[dbo].[Configuration].ConfigurationID
                        where Ad.ProductID is null and  
        DATEPART(m,Ad.Createdate )=DATEPART(m, DATEADD(m, -1, getdate())) )----This where clause gets the records of previous month Ad.CreateDate and productId is null
 DataTable
  ----Rows from ConfigurationMaster table are converted to Columns in the report using the below query
PIVOT(count([AdvertiserID]) 
      FOR ValueTitle  IN (Television,Radio,Cinema,
[Online Display],[Online Video],
[Outdoor],[Mobile],[Circular],
[Publication],[Direct Mail],
Email,[Social/Viral], Website)) AS PVTTable)
END TRY
			 BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
         SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
        RAISERROR ('[sp_MonthlyTBDPreviousMonth]: %d: %s',16,1,@error,@message,@lineNo); 
             END CATCH 

END
