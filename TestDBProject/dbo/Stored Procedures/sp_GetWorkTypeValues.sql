-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_GetWorkTypeValues
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select -1 AS ID, 'ALL' AS Name union all
    select Value AS ID, ValueTitle AS Name from [Configuration] where [ComponentName]  ='WorkType'
END