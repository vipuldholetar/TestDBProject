-- ==============================================================
-- Author: Sherebyah Tisbi	
-- Create date: 09/10/2015
-- Description:	Populating Creative media path for TV media files
-- ==============================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionMediaPathUpdate] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @patternList TABLE
	(
		[RowId] [INT] IDENTITY(1,1) NOT NULL,		  
		[OriginalPRCode] [varchar](25),
		[CreativeMasterStgId] [int],
		[CreativeDetailsStgId] [int]		 
	);

	declare @currentRow int
	declare @totalRows int
	declare @mediaPath varchar(50)
	declare @mediaFileName varchar(50)
	declare @creativeDetailsStgId int

	--declare @basePath varchar(50) = '\\napfileserver3\tv_cap2mcq\#CAP2MCQ'
		
	-- Fetch all records from CreativeDetails 
	insert into @patternList
	select tp.OriginalPRCode,cds.[CreativeStgMasterID], cds.[CreativeDetailStagingTVID] from [CreativeDetailStagingTV] CDS, [PatternStaging] PMS, [TVPattern] TP  
	where cds.[CreativeStgMasterID] = pms.[CreativeStgID] and tp.[TVPatternCODE] = pms.[CreativeSignature]
	
	select @totalRows = count(*) from @patternList
	select @currentRow = 1

	print 'Total Rows to Process - ' + convert(varchar(10),@totalRows) 

	while @currentRow <= @totalRows
	BEGIN
		select 
			@creativeDetailsStgId = [CreativeDetailsStgId],
			@mediaPath = '\TV\'+SUBSTRING([OriginalPRCode],3,3)+'\'+SUBSTRING([OriginalPRCode],1,2)+'\',
			--@mediaPath = '\'+SUBSTRING([OriginalPRCode],1,1)+'\'+SUBSTRING([OriginalPRCode],1,3)+'_DIR\',
			@mediaFileName = SUBSTRING([OriginalPRCode],1,8)+'.MPG'
		from 
			@patternList 
		where 
			RowId = @currentRow

		print @currentRow 
		print '@creativeDetailsStgId - ' + convert(varchar(10),@creativeDetailsStgId)
		print '@mediaPath - ' + @mediaPath
		print '@mediaFileName - ' + @mediaFileName

		begin tran
		update [CreativeDetailStagingTV] set 
			MediaFormat = 'MPG',
			MediaFilepath = @mediaPath,
			MediaFileName = @mediaFileName
		where 
			[CreativeDetailStagingTVID] = @creativeDetailsStgId

		if @@ERROR = 0
			commit tran
		else
			rollback tran

		-- move to the next row
		select @currentRow = @currentRow + 1
	END

END