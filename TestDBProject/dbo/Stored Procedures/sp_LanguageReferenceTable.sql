
-- ===========================================================================================
-- Author                :   Ganesh Prasad
-- Create date           :   01/28/2016
-- Description           :   This stored procedure is used to Get Data for "Language Reference Table" Report Dataset
-- Execution Process     : [dbo].[sp_LanguageReferenceTable]
-- Updated By            : 
-- ============================================================================================

CREATE  PROCEDURE [dbo].[sp_LanguageReferenceTable]
AS 
BEGIN
SET NOCOUNT ON;
       BEGIN TRY
SELECT a.LanguageID as LanguageID, 
               b.EthnicGroupName as EthnicGroup,
               a.Description as Description
FROM [Language] a, RefEthnicGroup b
WHERE b.[RefEthnicGroupID] = a.[EthnicGroupID]
ORDER BY a.Description

END TRY
  BEGIN CATCH 
DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
 RAISERROR ('[sp_LanguageReferenceTable]: %d: %s',16,1,@error,@message,@lineNo); 
 END CATCH 
 END