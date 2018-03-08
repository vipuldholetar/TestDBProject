CREATE PROCEDURE [dbo].[sp_UpdateAdvertiser] (
    @Descrip varchar(100),--name
    @ShortName varchar(50), --new?
    @LanguageID int,
    @ParentAdvertiserID int,
    @TradeClassID int,
    @WWTIndustryID int,
    @StartDT datetime, --new? mentioned in Slack
    @EndDT datetime,
    @Comments varchar(250),
    @AdvertiserID int, 
	@ModifiedByID int,
	@CTLegacyINSTCOD varchar(50),
	@state varchar(2)
)
AS
begin
  begin transaction

    -- note that the insert/delete of WWTIndustryAdvertiser is to work around that SQL server doesn't appear to defer constraint checking during a transaction
	IF NOT EXISTS(SELECT TOP 1 * FROM WWTIndustryAdvertiser WHERE AdvertiserID=@AdvertiserID AND  WWTIndustryID=@WWTIndustryId) --6.15.17 LE 
	BEGIN 
		insert into WWTIndustryAdvertiser
		values (
		@WWTIndustryId,
		@AdvertiserID
		) 
		update AdvertiserTakeCount
		set WWTIndustryID = @WWTIndustryID
		where AdvertiserId = @AdvertiserID
		and WWTIndustryId = (select IndustryID from Advertiser where AdvertiserID = @AdvertiserID)

	   delete WWTIndustryAdvertiser
	   where AdvertiserId = @AdvertiserID
	   and WWTIndustryId = (select IndustryID from Advertiser where AdvertiserID = @AdvertiserID)
	END
		Update Advertiser 
		SET 
		Descrip = @Descrip, 
		ShortName = @ShortName, 
		LanguageID = @LanguageID,
		ParentAdvertiserID = @ParentAdvertiserID,
		TradeClassID = @TradeClassID,
		IndustryID = @WWTIndustryID,
		StartDT = @StartDT,
		EndDT = @EndDT,
		AdvertiserComments = @Comments,
		ModifiedByID=@ModifiedByID,
		ModifiedDT=getdate(), 
		CTLegacyINSTCOD=NULLIF(@CTLegacyINSTCOD, ''), 
		[State]= NULLIF(UPPER(@state),'')
		WHERE 
		AdvertiserID = @AdvertiserID

	 
	commit transaction
end



