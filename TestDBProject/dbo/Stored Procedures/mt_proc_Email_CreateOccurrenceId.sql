








CREATE PROCEDURE [dbo].[mt_proc_Email_CreateOccurrenceId] 

@datereceived as datetime, --DateTimeReceived
@fromemail as varchar(200), --From.Address
@fromname as varchar(200), --From.Name
@htmlbody  as varchar(max), --Body.Text
@subject as varchar(200), -- Subject
@textbody as varchar(max), -- Text
@recipient as varchar(200), -- ToRecipients
@imageName as varchar(50), --imagename for email image
@urlName as varchar(max) = null, -- largest link area url
@linkImageName as varchar(50), --imagename from link area url image
@OccurrenceID as Int output, -- output
@Dir as varchar(15) output, -- output
@CreativeId as int output, -- output
@CreativeStagingId as int output -- output

AS
BEGIN
set @CreativeStagingId = @CreativeId
declare @AutomaticUser as int
declare @Curdate as varchar(12)
declare @MktId as int
declare @defaultLang as int
declare @media as int
declare @Publication as int
declare @status as int
declare @theme int
declare @event int
declare @sp int
declare @familyid int
declare @SenderId int
declare @SiteId int
declare @RetId int
declare @envelopeId Int
declare @LandingPageID int
declare @OverrideMktId int
set @OccurrenceID=0

Declare @AdID int
declare @AdvertiserEmailID int
declare @senderPersonaId int
Declare @RepMktId int
Declare @EmailMedia int
Declare @ImportUser int


select @RepMktId = MarketId from Market where Descrip = 'Representative-Email'
Select @EmailMedia = MediaTypeId from MediaType where Descrip = 'Email'
select @ImportUser = UserId from [User] where Username = 'mt3\MCAP_AutoImport'


select @MktId = 0

set @senderPersonaId = 0
set @AdvertiserEmailID = 0

--Clean @recipient 

set @recipient = replace(replace(@recipient, ';', ''), '"','')

--START Get V)

	Set @RetId = 0
	--Get Recipient from Sender, if not there then Add
	--"Hidden" location: 2077 (CodeId)
	--575 is generic "Email" market

	Select @senderpersonaId = [SenderPersonaID], @MktId =isnull(AssignedMarketCode, @RepMktId) from SenderPersona where Email = @recipient
	

	--insert into Jay_EmailLog values(@recipient, getdate())

	if @MktId =0
		Set @MktId = @RepMktId

	--Check For exact Match; if no exact match create AdvertiserEmail
	Select @RetId = [AdvertiserID], @AdvertiserEmailID=[AdvertiserEmailID]
			from AdvertiserEmail 
			where Email=@fromemail
		and Email is not null 
	if @AdvertiserEmailID = 0
	begin
			insert into AdvertiserEmail(AdvertiserID, Email, CreatedDT, CreatedById) Values(@RetId, @fromemail, getdate(), @ImportUser)
			set @AdvertiserEmailID=SCOPE_IDENTITY()
	end

	--Check for similar match; use retailer from similar Email
	If @RetId = 0
	Begin
		Select @RetId = [AdvertiserID], @AdvertiserEmailID=[AdvertiserEmailID]
			from AdvertiserEmail 
			where 
			right(Email, len(Email) - CHARINDEX('@', Email) + 1) like 
			right(@fromemail, len(@fromemail) - CHARINDEX('@', @fromemail) + 1)
			and Email is not null 
			and [AdvertiserID] is not null
		--USE TBD if no similar match
		If @RetId = 0
		Begin
			Select @RetId=AdvertiserID from [Advertiser] where Descrip = 'Email-TBD'

		End
	end

	--No Add ID yet for import
	set @AdID=null
	
	--Insert landing page link into LandingPage table and set LandingPageID to the identity value, or get existing landing page value if already in the table
	IF(@urlName is not null AND LEN(@urlName) > 0)
	BEGIN
		IF NOT EXISTS(SELECT * FROM LandingPage WHERE LandingURL = @urlName)
		BEGIN
			INSERT INTO LandingPage(LandingURL)
			VALUES (@urlName)
			SET @LandingPageID = SCOPE_IDENTITY()
		END
		ELSE 
		BEGIN
			SELECT @LandingPageID = LandingPageID FROM LandingPage WHERE LandingURL = @urlName
		END
	END
	
	insert into [OccurrenceDetailEM]
	([AdvertiserID], [MediaTypeID], [MarketID], [AdvertiserEmailID], [SenderPersonaID], [AdID], [DistributionDT], [AdDT], Priority, SubjectLine, LandingPageID, 
		MAPStatusID, IndexStatusID, ScanStatusID, QCStatusID, RouteStatusID, OccurrenceStatusID, [CreatedDT], [CreatedByID], AssignedtoOffice)
	values
	(@RetId, @EmailMedia, @MktId, @AdvertiserEmailID, @SenderPersonaId, @AdID, Cast(@datereceived as varchar(12)), cast(@datereceived as varchar(12)), 1, @subject, @LandingPageID,
	2, 1, 1, 2, 2, 2,
	getdate(), @ImportUser, 'NY')
	set @OccurrenceID=SCOPE_IDENTITY()

	--splitting out to seperate table for space management
	insert into OccurrenceEmail([OccurrenceID], BodyText, BodyHTML)
	values (@OccurrenceID, @textbody, @htmlbody)

	--Select @Dir = dbo.ImageMonth(CreateDt) From Vehicle where OccurrenceID = @OccurrenceID
	Select @Dir = 'EML'
	
	declare @PatternStagingID int
	exec [mt_proc_InsertCreativeDetailEM_Staging] @AdId, @OccurrenceID, 1, @CreativeStagingId output, @PatternStagingID output

	IF(@urlName IS NOT NULL)
	BEGIN
		exec [mt_proc_InsertCreativeDetailEM_Staging] @AdId, @OccurrenceID, 2, @CreativeStagingId output, @PatternStagingID output
	END

	Update [OccurrenceDetailEM]  set [PatternID]= @PatternStagingID where [OccurrenceDetailEMID]=@OccurrenceID

	--issue creating pattern, remove and try again
	If @PatternStagingID is null
		delete [OccurrenceDetailEM] where [OccurrenceDetailEMID]=@OccurrenceID
END



