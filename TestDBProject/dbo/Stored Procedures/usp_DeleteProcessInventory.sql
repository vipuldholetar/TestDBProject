-- ============================================= 

-- Author:    Rupinderjit 

-- Create date: 12/22/2014 

-- Description:  Delete Process Inventory

-- Query : exec usp_DeleteProcessInventory 'PI87'

-- ============================================= 

CREATE PROC [dbo].[usp_DeleteProcessInventory]

@processid nvarchar(20)

AS 

  BEGIN 

      BEGIN try 

	 -- Delete Process inventory	 

	  delete from [ProcessInventory]

           where [ParentProcessID]=@processid

    delete from [ProcessInventory]

           where [ProcessCODE]=@processid

      END try 
      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('usp_DeleteProcessInventory: %d: %s',16,1,@error,@message,@lineNo); 

      END catch; 

  END;
