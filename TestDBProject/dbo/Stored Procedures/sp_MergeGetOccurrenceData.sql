
-- ==============================================================================================================
-- Author		: Karunakar 
-- Create date	: 4th Jan 2015
-- Description	: This stored procedure is used to fill the Occurrence Data for circular in Merge Form
-- Execution	: sp_MergeGetOccurrenceData '520015',23
-- Updated By	: sp_MergeGetOccurrenceData '520015,520015,520016,520017'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_MergeGetOccurrenceData]
	@OccurrenceID as Nvarchar(50),
	@nonSurvivingAdID as Int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 	
				--Declare @basepath as nvarchar(100)
				--Set @basepath=(Select Value from Configurationmaster where Componentname='Creative Repository' and Systemname='All')
				--set @basepath=@basepath+'\'

				if(@OccurrenceID<>'' and @nonSurvivingAdID<>0)
				BEGIN
				Select [OccurrenceDetailCIRID] as OccurrenceID,FrontPage,BackPage,CreateDTM,Market,MediaType,Theme,Event,AdDate,StartDate,EndDate,FirstMarket,Pages,
				Language,Status,CASE WHEN FlashStatus =1 THEN 'Yes'ELSE 'No' END AS FlashStatus,FlyerID,SizeDescription	
				from vw_MergeQueueOccurrenceData where [OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@OccurrenceID))
				END
				--ELSE if(@nonSurvivingAdID<>0)
				--BEGIN
				--Select PK_OccurrenceID as OccurrenceID,CASE WHEN FrontPage IS NULL THEN Null ELSE @basepath+FrontPage END as FrontPage,CASE WHEN BackPage IS NULL THEN Null ELSE @basepath+BackPage END as BackPage,CreateDTM,Market,MediaType,Theme,Event,AdDate,StartDate,EndDate,FirstMarket,Pages,
				--Language,Status,CASE WHEN FlashStatus =1 THEN 'Yes'ELSE 'No' END AS FlashStatus,FlyerID,SizeDescription	
				--from vw_MergeQueueOccurrenceData where AdID=@nonSurvivingAdID
				--END
	END TRY
	BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('sp_MergeGetOccurrenceData: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 
END
