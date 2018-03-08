CREATE PROCEDURE QualifyPhotoboardAds
AS 
BEGIN 

	DECLARE @MediaStream varchar(50)
	DECLARE @IndustryGroupID int 
	DECLARE @AdvertiserID int 
	DECLARE @AdvertiserName varchar(50)
	DECLARE @CategoryID int 
	DECLARE @SubCategoryID int 
	DECLARE @MarketID int 
	DECLARE @RunDate date
	DECLARE @LanguageID int
	DECLARE @CriteriaID int 
	DECLARE @ConditionList NVARCHAR(MAX)		
	DECLARE @Result INT = 0
	DECLARE @Count INT = 1
	DECLARE @AdID INT
	DECLARE @Date DATE = GETDATE() -1
	DECLARE @Ad TABLE
	(
		RCount INT,
		AdID INT
	)

	INSERT INTO @Ad
	SELECT ROW_NUMBER() OVER (ORDER BY AdID),AdId from Ad where cast(CreateDate as date) = @Date


	WHILE @Count <= (Select COUNT(*) from @Ad)
	begin

		SELECT @AdID = AdID from @Ad WHERE RCount = @Count

		SELECT @MediaStream = p.MediaStream ,@IndustryGroupID = aig.IndustryGroupID,@AdvertiserID = a.AdvertiserID, @CategoryID = rc.RefCategoryID,
		@SubCategoryID = rsc.RefSubCategoryID,@MarketID = a.[TargetMarketId],@RunDate = a.FirstRunDate, @LanguageID = a.LanguageID, @CriteriaID = ec.CriteriaID, @AdvertiserName = av.Descrip, @AdID = a.ADId
		FROM	Ad a join AdKeyElement ak on a.AdId = ak.AdId join ElementCriteria ec on ak.KETemplateID = ec.KETemplateID join Pattern p on a.AdId = p.AdId join AdvertiserIndustryGroup aig on 
		aig.AdvertiserID = a.AdvertiserId join RefCategory rc on ak.KETemplateID = rc.KETemplateID join RefSubCategory rsc on rc.RefCategoryID = rsc.CategoryID join Advertiser av on a.AdvertiserID = av.AdvertiserID
		where a.adid = @AdID

		SET @Result = (select dbo.CriteriaResultToTRUE(@MediaStream, @IndustryGroupID, @AdvertiserID, @AdvertiserName, @CategoryID, @SubCategoryID, @MarketID, @RunDate, @LanguageID, @CriteriaID, @AdId))

		if(@Result = 1)
		begin	
			IF NOT EXISTS (SELECT * FROM Photoboard WHERE AdID = @AdId AND Deleted = 0)
			begin	
				INSERT INTO Photoboard (AdID,MediaStream,Deleted)
				VALUES (@AdId,@MediaStream,0)
				select @AdId
			END 
		end

		SET @Count = @Count + 1

	end

END