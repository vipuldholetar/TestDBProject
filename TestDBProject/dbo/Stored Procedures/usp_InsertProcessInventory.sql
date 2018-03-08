

-- ============================================= 
-- Author:    Rupinderjit 
-- Create date: 12/22/2014 
-- Description:  Insert Process Inventory
-- Query : exec usp_InsertProcessInventory
-- ============================================= 


CREATE PROC [dbo].[usp_InsertProcessInventory]

@name varchar(200),@description varchar(1000),@status varchar(20),@type varchar(200),@parentprocessid varchar(20),@processgroup varchar(200)

AS 

  BEGIN 

      SET nocount ON 
      BEGIN try 
	 -- Insert Process inventory

   	  declare @processid varchar(10)

	  select @processid='PI'+cast(Ident_current('process_inventory')+1 as varchar)

	  if (@parentprocessid='') 
	  begin


    INSERT INTO [dbo].[ProcessInventory]

           ([ProcessCODE]

      ,[Name]

      ,[Descrip]

      ,[Type]

      ,[Status]

      ,[ParentProcessID]

	  ,[ProcessGroup])

     VALUES

           (@processid

           ,@name

           ,@description

           ,@type

		   ,@status           

           ,null

		   ,@processgroup)

		   end
		   else
		   begin
		   
    INSERT INTO [dbo].[ProcessInventory]

           ([ProcessCODE]

      ,[Name]

      ,[Descrip]

      ,[Type]

      ,[Status]

      ,[ParentProcessID]

	  ,[ProcessGroup])

     VALUES

           (@processid

           ,@name

           ,@description

           ,@type

		   ,@status           

           ,@parentprocessid

		   ,@processgroup)
		   end
      END try 
	  
      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('usp_InsertProcessInventory: %d: %s',16,1,@error,@message,@lineNo); 

      END catch; 

  END;
