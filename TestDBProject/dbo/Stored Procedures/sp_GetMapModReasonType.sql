-- =============================================
-- Author:		Ashanie Cole
-- Create date:	March 2017
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetMapModReasonType]
	@Reason varchar(max),
	@Advertiser varchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReasonType varchar(20) = ''

    --SELECT LOWER(ltrim(rtrim(replace(replace(replace(item,char(9),''),char(10),''),char(13),''))))
    --FROM dbo.SplitString('Headline/Lead Audio Change(Map)^Title/Lead Text Change^Visual Change^Product/Offer Change^
    --Price or Rate Change^Location or Regional Reference Change^Date, Theme or Event Change^Coop Partner Change^URL or Phone Number Change^
    --Other Text or Audio Change^Headline/Lead Audio Change(Revision)^Format Difference','^')

    CREATE TABLE #SelectedReason (reason VARCHAR(255))

    INSERT INTO #SelectedReason(reason)
    SELECT LOWER(ltrim(rtrim(replace(replace(replace(item,char(9),''),char(10),''),char(13),''))))
    FROM dbo.SplitString(@Reason,'^')

    -- if multiple reasons are selected with both types, use revision
    IF EXISTS(SELECT TOP 1 1 FROM #SelectedReason 
		  WHERE reason in('headline/lead audio change(revision)','title/lead Text Change','visual change',
					   'product/offer change','product change','date, theme or event change','coop partner change',
					   'other text or audio change','Format Difference')
			 OR (reason = 'price or rate change' 
				AND EXISTS(SELECT a.AdvertiserID FROM Advertiser a INNER JOIN AdvertiserIndustryGroup b on a.Advertiserid = b.Advertiserid
				INNER JOIN RefIndustryGroup c ON c.RefIndustryGroupID = b.IndustryGroupID
				WHERE a.Descrip = @Advertiser and c.IndustryName in('Telecommunications', 'Automotive and Related', 'Airlines'
				,'Miscellaneous', 'Cruise Lines', 'Retailing', 'Security Services')) 
				)
			 OR (reason = 'location or regional reference change'
				AND EXISTS(SELECT a.AdvertiserID FROM Advertiser a INNER JOIN AdvertiserIndustryGroup b on a.Advertiserid = b.Advertiserid
				INNER JOIN RefIndustryGroup c ON c.RefIndustryGroupID = b.IndustryGroupID
				WHERE a.Descrip = @Advertiser and c.IndustryName in ('Automotive and Related', 'Airlines' ,'Telecommunications'))
				)
		  )
        SET @ReasonType = 'revision'

    ELSE IF LOWER(@Reason) ='price or rate change'
        
	   SET @ReasonType = 'edit'

    ELSE IF LOWER(@Reason) ='location or regional reference change'
        
	   SET @ReasonType = 'edit' 

    ELSE IF LOWER(@Reason) ='url or phone number change'
        SET @ReasonType = 'edit'
            
    ELSE IF LOWER(@Reason) ='headline/lead audio change(map)'
        SET @ReasonType = 'edit'


    SELECT @ReasonType AS ReasonType
END