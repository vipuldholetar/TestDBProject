
CREATE PROCEDURE [dbo].[mt_proc_InsertCreativeDetailEM] 

@AdId as int=0,
@OccurenceId  as Int, 
@PageNumber as int,
@CreativeID as int output,
@PatternMasterID as int output

AS
BEGIN

declare @FileLocation int
--Clean @recipient
--Declare @CreativeID as int
	
	If @AdID=0
		begin
			select @AdID=[AdId], @FileLocation=PK_Id from [Creative] where [SourceOccurrenceId] = @OccurenceId
			set @CreativeID=@FileLocation
		end
		Else
		begin
			if @CreativeID IS NULL
			begin
				insert into [Creative]([AdId], [SourceOccurrenceId], CheckInOccrncs)
				Values (@AdID, @OccurenceId, 1)
				set @CreativeID=SCOPE_IDENTITY()

				insert into [Pattern]([CreativeID], [AdID], MediaStream, Priority, Status, CreateDate)
				values(@CreativeId, @AdId, 13, 1, 'Valid', getdate())
				set @PatternMasterID=SCOPE_IDENTITY()
			end
			else
			begin
				select @PatternMasterID = p.PatternID from [Pattern] p where [CreativeID] = @CreativeID
			end
			
			set @FileLocation=@CreativeID
		End

	insert into CreativeDetailEM (CreativeMasterId, Deleted, PageNumber, PageTypeId, PageName, 
		CreativeAssetName, CreativeRepository,
		CreativeFileType, [SizeID])
	Values (@CreativeId, 0, @PageNumber, 'B', @PageNumber, 
		right('00' + cast(@PageNumber as varchar), 3) + '.jpg', '\EML\' + cast(@FileLocation as varchar) + '\Original\',
		'jpg', 1)
END
