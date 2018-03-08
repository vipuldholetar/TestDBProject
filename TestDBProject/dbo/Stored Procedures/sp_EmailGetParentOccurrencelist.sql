-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 10/26/2015
-- Execution		: 
-- Description		: Get list of Parent & Child Occurrence
-- Updated By		: 
--					: 
--================================================================================
CREATE PROCEDURE [dbo].[sp_EmailGetParentOccurrencelist] -- 10
(
@ParentOccurrenceId AS BIGINT
)
AS
BEGIN   
SET NOCOUNT ON;
    BEGIN TRY 
			DECLARE @Occlist  AS NVARCHAR(MAX)
			 declare @Subject as Nvarchar(200), @AdvertiserId as Int, @AdDate as DateTime, @OccurrenceList as varchar(MAX) 
			Select @Subject=[Subject],@AdvertiserId=AdvertiserID,@AdDate = AdDt from vw_EmailReivewQueueData where OccurrenceID =  @ParentOccurrenceId
	

			SELECT  @OccurrenceList =STUFF((SELECT ',' + RTRIM(vw_EmailReivewQueueData.OccurrenceID) FROM vw_EmailReivewQueueData
			WHERE Subject =@Subject and advertiserId=@AdvertiserId and adDt=@AdDate and occurrenceid not in(@ParentOccurrenceId) FOR XML PATH('')),1,1,'') 
						
			SELECT  @Occlist =STUFF((SELECT ',' + RTRIM([OccurrenceDetailEM].[OccurrenceDetailEMID] ) FROM [OccurrenceDetailEM]
			WHERE [OccurrenceDetailEM].[ParentOccurrenceID] = @ParentOccurrenceId FOR XML PATH('')),1,1,'')  
			 
			if @Occlist is null
			begin
			SELECT  CONVERT(NVARCHAR(MAX),@ParentOccurrenceId) + ',' + @OccurrenceList as Occurrencelist
			end 
			else
			begin
			SELECT @Occlist  + ',' + @OccurrenceList  AS Occurrencelist
			end
    END TRY 
    BEGIN CATCH 
			DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_EmailGetParentOccurrencelist]: %d: %s',16,1,@error,@message,@lineNo); 			
    END CATCH 
  END