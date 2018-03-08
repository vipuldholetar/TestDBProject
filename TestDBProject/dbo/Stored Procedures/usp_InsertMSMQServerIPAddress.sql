
-- =============================================   
-- Author:    Jayaprakash  
-- Create date: 01/05/2015   
-- Description:  Insert new MSMQ Server IP Address  
-- Query : exec usp_InsertMSMQServerIPAddress '182.198.1.1', 1
-- =============================================   

CREATE PROC [dbo].[usp_InsertMSMQServerIPAddress] @IPAddress nvarchar(50),@CreatedBy bigint
as

Set Nocount on

IF NOT EXISTS(Select 1 from [dbo].[MSMQServer] where ServerIP=@IPAddress)
BEGIN
	INSERT INTO [dbo].[MSMQServer]
			   ([ServerIP]
			   ,[CreatedByID])
		 VALUES
			   (@IPAddress
			   ,@CreatedBy)
END
ELSE
BEGIN
	Update [dbo].[MSMQServer]
	Set Status=1
	Where ServerIP=@IPAddress
END
