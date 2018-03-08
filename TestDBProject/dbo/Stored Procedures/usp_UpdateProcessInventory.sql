

-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Update Process Inventory
-- Query : exec usp_UpdateProcessInventory
-- ============================================= 

CREATE PROC [dbo].[usp_UpdateProcessInventory]

@name varchar(200),@description nvarchar(1000),@status varchar(20),@type varchar(20),@processid varchar(20),@parentprocessid varchar(20),@processgroup varchar(200)

AS 

  BEGIN 

      SET nocount ON 

      BEGIN try 

	 -- Update Process inventory	 
	 
	  if (@parentprocessid='') 
	  begin
    update [dbo].[ProcessInventory]

           set  [Name]=@name,

		  [Descrip]=@description

           ,[Status]=@status

           ,[Type]=@type

		   ,[ParentProcessID]=null

		   ,[ProcessGroup] = @processgroup

           where [ProcessCODE]=@processid
end
else
begin

    update [dbo].[ProcessInventory]

           set  [Name]=@name,

		  [Descrip]=@description

           ,[Status]=@status

           ,[Type]=@type

		   ,[ParentProcessID]=@parentprocessid

		   ,[ProcessGroup] = @processgroup

           where [ProcessCODE]=@processid


		   end
      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('usp_UpdateProcessInventory: %d: %s',16,1,@error,@message,@lineNo); 

      END catch; 

  END;
