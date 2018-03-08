
-- ===========================================================================================
-- Author                :   Ganesh Prasad
-- Create date           :   01/28/2016
-- Description           :   This stored procedure is used to Get Data for "Social Summary for Last 7 Days" Report Dataset
-- Execution Process     : [dbo].[sp_AutoQuerySocailSummary]
-- Updated By            : 
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_AutoQuerySocailSummary]
As 
Begin
SET NOCOUNT ON;
       BEGIN TRY

select [Advertiser].Descrip as AdvertiserName,mediatype.Descrip as MediaType,
count([OccurrenceDetailSOC].[OccurrenceDetailSOCID]) as Total,
sum(case when [OccurrenceDetailSOC].OccurrenceStatusID = 1 then 1 else 0 END) as Approved,
--sum(case when OccurrenceDetailsSOC.OccurrenceStatus = 'Notake' and OccurrenceDetailsSOC.NoTakeReason = ''
sum(case when [OccurrenceDetailSOC].OccurrenceStatusID = 2 then 1 else 0 END ) as ToBeApproved 

from [OccurrenceDetailSOC]
Inner Join [Advertiser]  ON [Advertiser].AdvertiserID = [OccurrenceDetailSOC].[AdID]
Inner Join mediatype ON mediatype.[MediaTypeID] = [OccurrenceDetailSOC].[MediaTypeID]
where [OccurrenceDetailSOC].[DistributionDT] >= GetDate()-7
Group By [Advertiser].Descrip,mediatype.Descrip
END TRY
  BEGIN CATCH 
DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
 RAISERROR ('[sp_AutoQuerySocailSummary]: %d: %s',16,1,@error,@message,@lineNo); 
 END CATCH 
 END