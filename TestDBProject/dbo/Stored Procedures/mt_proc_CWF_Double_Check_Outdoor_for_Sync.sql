






-- =============================================
-- Author:		jhetler
-- Create date: 5/1/2017
-- Description:	Retrieves the latest set of creatives that are need for Omnis Sync
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_CWF_Double_Check_Outdoor_for_Sync]
AS
BEGIN
	
	if object_id('tempdb.dbo.ImageCheck') is null
		Create Table tempdb.dbo.ImageCheck (id int)
	else
		delete tempdb.dbo.ImageCheck

	DECLARE my_cursor CURSOR
	FOR
	--for Current MCAP
	select ID, DestinationPath + DestinationFile  from CWF.dbo.OD_CreativeCopy
	where InsertDt > dateadd(d, -45, getdate())
	OPEN my_cursor
		--declare vars
		declare @Id varchar(50)
		declare @Path as varchar(600)
	declare @fileexist as int
		FETCH NEXT FROM my_cursor INTO @Id, @Path
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN	
			
				--EXECUTE code
				exec master.dbo.xp_fileexist @Path, @fileexist output
				if @fileexist=0
				begin
					insert tempdb.dbo.ImageCheck select @Id
				end
			END
			FETCH NEXT FROM my_cursor INTO @Id, @Path
		END
	CLOSE my_cursor
	DEALLOCATE my_cursor
	
	--reset so it tries again
	Update CWF.dbo.OD_CreativeCopy set FileCopyDt=null from CWF.dbo.OD_CreativeCopy
	where id in (select id from tempdb.dbo.ImageCheck)


END





