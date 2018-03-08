
CREATE PROCEDURE [dbo].[mt_proc_Email_ImportOccurrence] 

@datereceived as datetime, --BreakDt
@fromemail as varchar(200), --Get from Site (SiteId to Vehicle)
@fromname as varchar(200), --Get from Site(SiteId to Vehicle)
@htmlbody  as varchar(max), --BodyHTML
@subject as varchar(200), -- Subject
@textbody as varchar(max), -- BodyText
@recipient as varchar(200), -- Find in Sender
@imageName as varchar(50), -- Page.ImageName
@OccurrenceID as Int output, -- output
@Dir as varchar(15) output, -- output
@CreativeId as int output

AS
BEGIN
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
declare @OverrideMktId int
set @OccurrenceID=0

Declare @AdID int
declare @AdvertiserEmailID int
declare @senderPersonaId int

Set @MktId = 0

set @senderPersonaId = 0
set @AdvertiserEmailID = 0

--Clean @recipient 

set @recipient = replace(replace(@recipient, ';', ''), '"','')

--START Get V)

	Set @RetId = 0
	--Get Recipient from Sender, if not there then Add
	--"Hidden" location: 2077 (CodeId)
	--575 is generic "Email" market

	Select @senderpersonaId = [SenderPersonaID], @MktId =isnull(AssignedMarketCode, 1009) from SenderPersona where Email = @recipient
	


	If @RetId = 0
	Begin
		Select @RetId = [AdvertiserID], @AdvertiserEmailID=[AdvertiserEmailID] from AdvertiserEmail where 
			right(Email, len(Email) - CHARINDEX('@', Email) + 1)
			like right(@fromemail, len(@fromemail) - CHARINDEX('@', @fromemail) + 1)
		and Email is not null 
		--Dont want to auto-assign our dummy placeholder rets
		If @RetId = 0
		Begin
			Select @RetId=AdvertiserID from [Advertiser] where Descrip = 'Email-TBD'
		End
	end

	--insert into Ad(AdvId, BreakDate, CommonAdDate, CreateDate, FK_MarketId)
	--Values(@RetId, @datereceived, @datereceived, getdate(), @MktId)
	--set @AdID=SCOPE_IDENTITY()
	set @AdID=null

	insert into [OccurrenceDetailEM]
	([AdvertiserID], [MediaTypeID], [MarketID], [AdvertiserEmailID], [SenderPersonaID], [AdID], [DistributionDT], [AdDT], Priority, SubjectLine, 
		MAPStatusID, IndexStatusID, ScanStatusID, QCStatusID, RouteStatusID, OccurrenceStatusID, [CreatedDT], [CreatedByID], AssignedtoOffice)
	values
	(@RetId, 13, @MktId, @AdvertiserEmailID, @SenderPersonaId, @AdID, Cast(@datereceived as varchar(12)), cast(@datereceived as varchar(12)), 1, @subject, 
	2, 1, 1, 2, 2, 2,
	getdate(), 29712180, 'NY')
	set @OccurrenceID=SCOPE_IDENTITY()



	--splitting out to seperate table for space management
	insert into OccurrenceEmail([OccurrenceID], BodyText, BodyHTML)
	values (@OccurrenceID, @textbody, @htmlbody)

	--Select @Dir = dbo.ImageMonth(CreateDt) From Vehicle where OccurrenceID = @OccurrenceID
	Select @Dir = 'EML'
	
	declare @PatternMasterID int
	exec [mt_proc_Email_ImportCreative] @AdId, @OccurrenceID, 1, @CreativeId output, @PatternMasterID output

	Update [OccurrenceDetailEM]  set [PatternID]= @PatternMasterID where [OccurrenceDetailEMID]=@OccurrenceID

END