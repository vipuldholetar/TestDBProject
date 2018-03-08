CREATE PROCEDURE [dbo].[sp_RCSGetRCSIDValues]
	(@ClassName as varchar(100),
	@AdvName as varchar(100),
	@AcctName as varchar(100))
AS
  BEGIN 
          BEGIN try 
			 select 
				(select RCSClassID from RCSClass where Name = @ClassName) RCSClassID, 
				(select RCSAdvID from RCSAdv where name = @AdvName) RCSAdvID,
				(select RCSAcctID from RCSAcct where name = @AcctName) RCSAcctID

			END try 

      BEGIN catch 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_RCSGetRCSIDValues: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 
      END catch 
  END