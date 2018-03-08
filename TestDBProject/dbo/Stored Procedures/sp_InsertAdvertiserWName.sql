CREATE procedure [dbo].[sp_InsertAdvertiserWName] (
	@MediaStream varchar(50),
	@PubUniverse varchar(50),
	@LanguageID int,
	@TakeCountLimit int,
	@Descrip varchar(100),
	@WWTIndustryId int,
	@AdvertiserID int out
)
as
begin
	--set xact_abort on
	--set nocount on	
	--set ansi_nulls on
	--set ansi_padding off
	--set ansi_warnings on
	--set arithabort off
	--set concat_null_yields_null on 
	--set numeric_roundabort off
	--set quoted_identifier on
	begin try
		begin transaction
			--insert new advertiser
			insert into Advertiser (
				Descrip, --Name,
				IndustryID
			)
			values (
				@Descrip,
				@WWTIndustryId
			)

			--capture and out the new ID
			select @AdvertiserID = SCOPE_IDENTITY()

			--insert WWT join record
			insert into WWTIndustryAdvertiser
			values (
				@WWTIndustryId,
				@AdvertiserID
			)

			--insert take count
			if @LanguageID = 0 begin
				select @LanguageID = LanguageID from [Language] where [Description] = 'English'
			end
			insert into AdvertiserTakeCount
			values (
				@wwtIndustryID,
				@AdvertiserID,
				@MediaStream,
				@PubUniverse,
				@LanguageID,
				@TakeCountLimit
			)
		commit transaction
	end try
	begin catch
		--if xact_state() <> 0 begin
		--	rollback transaction
		--end
		rollback transaction
		declare @error int,
				@message varchar(4000),
				@lineNo int
		select @error = Error_number(), @message = Error_message(), @lineNo = Error_line()
		print('ERROR: @error = ' + cast(@error as varchar(10)) + ', @message = ' + @message + ', @lineNo = ' + cast(@lineNo as varchar(10))) 
		raiserror('[sp_InsertAdvertiserWName]: %d: %s', 16, 1, @error, @message, @lineNo)
		select @AdvertiserID = 0
	end catch
end