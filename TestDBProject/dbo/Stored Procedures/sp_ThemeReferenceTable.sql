
-- ===========================================================================================
-- Author                :   Ganesh Prasad
-- Create date           :   01/28/2016
-- Description           :   This stored procedure is used to Get Data for "Theme Reference Table" Report Dataset
-- Execution Process     : [dbo].[sp_ThemeReferenceTable]
-- Updated By            : 
--						 :  Alan Davey - 3/2/2016:  Added where clause to filter on EndDate
-- ============================================================================================

CREATE  PROCEDURE [dbo].[sp_ThemeReferenceTable]
AS
BEGIN
SET NOCOUNT ON;
       BEGIN TRY
	   select [ThemeID] as ThemeId,
Descrip as Description ,
[StartDT] as StartDate,
[EndDT] as EndDate from [Theme]
where [EndDT] is null

ORDER BY Descrip
END TRY
  BEGIN CATCH 
DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
 RAISERROR ('[sp_ThemeReferenceTable]: %d: %s',16,1,@error,@message,@lineNo); 
 END CATCH 
 END
