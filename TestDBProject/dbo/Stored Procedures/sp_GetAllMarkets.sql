-- =============================================
-- Author:		Edwin
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllMarkets] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from Market
END