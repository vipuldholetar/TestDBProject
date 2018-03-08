CREATE Proc [dbo].[usp_GetProcessIdbyServiceName]
@ServiceName NVARCHAR(200)
AS
SET NOCOUNT ON
		begin
				Select [ProcessCODE] from [ProcessInventory] where [Name]=@ServiceName
		end
