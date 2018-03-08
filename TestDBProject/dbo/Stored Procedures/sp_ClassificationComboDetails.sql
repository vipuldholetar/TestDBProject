-- =============================================
-- Author:		Monika. J
-- Create date: 10/01/2015
-- Description:	Procedure to get Combobox Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_ClassificationComboDetails] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
		-- SELECT statements for procedure here	
		--Table 0
		SELECT DISTINCT Campaign FROM Ad where Campaign IS NOT NULL and Campaign <> ''
		--Table 1
		SELECT [RefCelebrityID],CelebrityName FROM [dbo].[RefCelebrity]

		--SELECT AdvertiserName as CoopPartner FROM Advertiser,AdCoopComp
		--WHERE PK_AdvertiserID = AdCoopComp.FK_AdvertiserID and AdCoopComp.CoopCompCode = 'C'
		
		--SELECT AdvertiserName as Competitor FROM Advertiser,AdCoopComp
		--WHERE PK_AdvertiserID = AdCoopComp.FK_AdvertiserID and AdCoopComp.CoopCompCode = 'X'

		--Table 2
		SELECT [RefIndustryGroupID],IndustryName FROM [dbo].[RefIndustryGroup]

		--Table 3
		SELECT DISTINCT a.[RefClassificationGroupID],a.ClassificationGroupName FROM RefClassificationGroup a,Ad b
			WHERE a.[RefClassificationGroupID] = b.[ClassificationGroupID]

		--Table 4
		SELECT [RefCategoryGroupID],CategoryGroupName from [dbo].[RefCategoryGroup]
		--Table 5
		SELECT DISTINCT EntryEligible FROM Ad where EntryEligible IS NOT NULL and EntryEligible <> ''
		--Table 6
		SELECT DISTINCT AdType FROM Ad where AdType IS NOT NULL and AdType <> ''
		--Table 7
		SELECT DISTINCT AdDistribution FROM Ad where AdDistribution IS NOT NULL and AdDistribution <> ''
		--Table 8
		SELECT DISTINCT a.[RefTaglineID],a.Tagline FROM RefTagLine a,Ad WHERE a.[AdvertiserID] = Ad.[AdvertiserID]
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_ClassificationComboDetails]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH
    
END