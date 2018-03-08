




CREATE PROCEDURE [dbo].[mt_proc_InsertCreativeDetailEM_Staging] 

@AdId as int=0,
@OccurenceId  as Int, 
@PageNumber as int,
@CreativeStagingID as int output,
@PatternMasterID as int output

AS
BEGIN


Declare @MediaStream int =154
Declare @ImportUser int

select @ImportUser = UserId from [User] where Username = 'mt3\MCAP_AutoImport'
select @MediaStream=ConfigurationId from configuration where componentname = 'Media Stream'  and Value='EM'


declare @FileLocation int
--Clean @recipient
--Declare @CreativeStagingID as int
	
	If @AdID=0
		begin
			select @AdID=[AdId], @FileLocation=CreativeStagingID from [CreativeStaging] where OccurrenceID = @OccurenceId
			set @CreativeStagingID=@FileLocation
		end
		Else
		begin
			if @CreativeStagingID IS NULL
			begin
				insert into [CreativeStaging](OccurrenceID, CreatedDT)
				Values ( @OccurenceId, getdate())
				set @CreativeStagingID=SCOPE_IDENTITY()

				
				insert into [Pattern]([CreativeID], MediaStream, Priority, Status, CreateDate, CreateBy )
				values(@CreativeStagingID, @MediaStream, 1, 'Valid', getdate(), @ImportUser)
				set @PatternMasterID=SCOPE_IDENTITY()

				insert into [PatternStaging](CreativeStgID, PatternID, MediaStream, Priority, Status, CreatedDT, LanguageId, CreatedByID)
				values(@CreativeStagingID, @PatternMasterID, @MediaStream, 1, 'Valid', getdate(), 1, @ImportUser)
			end
			else
			begin
				select @PatternMasterID = p.PatternID from [PatternStaging] p where CreativeStgID = @CreativeStagingID
			end
			
			set @FileLocation=@CreativeStagingID
		End

	insert into CreativeDetailStagingEM (CreativeStagingID, Deleted, PageNumber, PageTypeId, PageName, 
		CreativeAssetName, CreativeRepository,
		CreativeFileType, [SizeID])
	Values (@CreativeStagingID, 0, @PageNumber, 'B', @PageNumber, 
		right('00' + cast(@PageNumber as varchar), 3) + '.jpg', '\EML\' + cast(@FileLocation as varchar) + '\Original\',
		'jpg', 1)
		
END




