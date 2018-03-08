
-- ===========================================================================================
-- Author                :   Ganesh Prasad
-- Create date           :   01/19/2016
-- Description           :   This stored procedure is used to Get Data for "Media Type Reference Table" Report Dataset
-- Execution Process     : [dbo].[sp_MediaTypeReferenceTable]
-- Updated By            : 
-- ============================================================================================

CREATE  PROCEDURE [dbo].[sp_MediaTypeReferenceTable]
AS
BEGIN
SET NOCOUNT ON;
       BEGIN TRY
	   SELECT a.[MediaTypeID], 
               a.Descrip,
               b.ValueTitle as MediaStream
               --a.StartDT,
               --a.EndDT
FROM MediaType a, [Configuration] b
WHERE b.ConfigurationID = a.MediaStream
--AND a.ActiveInd = 1  
ORDER BY MediaStream, Descrip
END TRY
  BEGIN CATCH 
DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
 RAISERROR ('[sp_MediaTypeReferenceTable]: %d: %s',16,1,@error,@message,@lineNo); 
 END CATCH 
 END
