
-- ===========================================================================================
-- Author                :   Ganesh Prasad
-- Create date           :   01/28/2016
-- Description           :   This stored procedure is used to Get Data for "Event Reference Table" Report Dataset
-- Execution Process     : [dbo].[sp_EventReferenceTable]
-- Updated By            : 
--						 :  Alan Davey- 3/2/2016:  added where clause
-- ============================================================================================

CREATE  PROCEDURE [dbo].[sp_EventReferenceTable]
AS
BEGIN
SET NOCOUNT ON;
       BEGIN TRY
	   select [EventID] as EventId,
Descrip as Description,
[StartDT] as StartDate,
[EndDT] as EndDate
 from [Event] 
 where [EndDT] is null
 order by Descrip
 END TRY
  BEGIN CATCH 
DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
 RAISERROR ('[sp_EventReferenceTable]: %d: %s',16,1,@error,@message,@lineNo); 
 END CATCH 
 END
