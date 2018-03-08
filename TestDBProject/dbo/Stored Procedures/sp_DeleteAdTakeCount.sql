/****** Object:  StoredProcedure [dbo].[sp_DeleteAdTakeCount]    Script Date: 5/9/2016 10:50:24 AM ******/
CREATE PROCEDURE [dbo].[sp_DeleteAdTakeCount](
	@AdTakeCountID int
)
as
begin
	delete from AdTakeCount
	where AdTakeCountID = @AdTakeCountID
end