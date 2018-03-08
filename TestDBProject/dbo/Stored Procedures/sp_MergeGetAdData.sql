
-- ==============================================================================================================
-- Author		: Karunakar 
-- Create date	: 4th Jan 2015
-- Description	: This stored procedure is used to fill the ad Data for circular in Merge Form
-- Execution	: sp_MergeGetAdData 19619
-- Updated By	: 
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_MergeGetAdData] --19619
	@AdID as Int
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 
	
	Declare @basepath as nvarchar(100)
	Set @basepath=(Select Value from [Configuration] where Componentname='Creative Repository' and Systemname='All')
	set @basepath=@basepath+'\';
	--Print(@basepath)

	Select  AdID,LeadAvHeadline,LeadText,AdVisual,AdvertiserName,AdDescription,Language,MediaStreamID,AdLength,FirstRunDate,[FirstRunMarketID],LastRunDate,
	[PrimaryOccurrenceID],MediaStream,CreativeMasterID,PatternmasterID,cm.ValueTitle as PrimaryCreativeQuality,OccurrenceCount,PatternmasterCount,
	CASE WHEN Thumbnail IS NULL THEN Null ELSE @basepath+Thumbnail END as Thumbnail
	from vw_MergeQueueAdData a left join [Configuration] cm
	on a.PrimaryQuality=cm.configurationID
	where a.AdID=@AdID
	
	 
	END TRY
	 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_MergeGetAdData: %d: %s',16,1,@error,@message,@lineNo); 
		  END CATCH 

END