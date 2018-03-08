
CREATE procedure [dbo].[sp_GenerateEmailEmojiPath] (
	@OccurrenceId int	--1620409	--Input the OccurrenceId
)
as
BEGIN
	SET NOCOUNT ON;
	DECLARE 
	@BasePath as varchar(200),
	@Directory as varchar(50),
	@EmojiName as varchar(350),
	@FullPathandName as varchar(500);
	Begin Try
		Select @BasePath = [Value] From Configuration with (nolock)Where ComponentName ='Creative Repository';
		Select @Directory = [Value] From Configuration with (nolock)Where ComponentName ='Emoji Repository';

		Select @EmojiName = Convert(varchar(30),ce.CreativeStagingID) +'.jpg' From CreativeStaging cs with (nolock)
		inner join CreativeDetailStagingEM ce with (nolock) on cs.CreativeStagingID = ce.CreativeStagingID
		Where cs.OccurrenceId = @OccurrenceId And ce.PageNumber = 1

		SET @FullPathandName = @BasePath + @Directory + @EmojiName
		Select @FullPathandName
	End Try
	Begin Catch
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_GenerateEmailEmojiPath]: %d: %s',16,1,@error,@message,@lineNo);               
	End Catch
	   
END