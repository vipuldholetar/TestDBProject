-- =============================================================================================================
-- Author		: Amrutha Lakshmi
-- Create date	: 14/12/2015
-- Description	: This stored procedure is used to get the MASTER data FOR Promotion Template Work Queue.
-- Execution	: [sp_CPGetPromoTemplateData]
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetPromoTemplateData]
AS
BEGIN
	BEGIN TRY
		--USER MASTER DATA
		SELECT 0[VALUE],'ALL'[VALUETITLE]
		UNION ALL
		SELECT [RefKETemplateID] as [VALUE],[Descrip]as  [VALUETITLE] FROM [dbo].[RefKETemplate]
		where[KElementLevel]Like 'P'		

	
	END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetPromoTemplateData: %d: %s',16,1,@error,@message,@lineNo); 
			 -- ROLLBACK TRANSACTION
END CATCH 
END
