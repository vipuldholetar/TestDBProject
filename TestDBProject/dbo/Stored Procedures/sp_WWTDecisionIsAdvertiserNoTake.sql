-- =============================================
-- Author:		<Lisa East>
-- Create date: <8/10/2017>
-- Description:	<Check if an advertiser was marked as no take for a mediastream>
-- =============================================
CREATE PROCEDURE [dbo].[sp_WWTDecisionIsAdvertiserNoTake]

	@IndustryID int = null,
	@AdvertiserID int = null,
	@MediaStreamID varchar(50) = null,
	@PublicationID int = null
	
AS
BEGIN
	DeCLARE @WhatWeTake WhatWeTakeData
	DeCLARE @PubGroupList PubGroupListData
	DeCLARE @RESULTS VARCHAR(10)='Take'
	DECLARE @RECCOUT AS INT=0


	IF (@AdvertiserID is not null and @MediaStreamID is not null and (@PublicationID is null OR @PublicationID=0 )  )
	BEGIN 
		PRINT 'Adv-Media No Take check'
		SELECT @RECCOUT=count(1)
		FROM WhatWeTake W
		INNER JOIN WWTRule WR ON W.WWTRuleID=WR.WWTRuleID
		INNER JOIN [RuleType] R ON WR.RuleTypeID=R.RuleTypeID
		WHERE W.AdvertiserID=@AdvertiserID
		AND W.MediaStream= @MediaStreamID
		and R.RuleType='No Take'
			IF @RECCOUT > 0
			set @RESULTS='No Take'
			
			-- CHECK MEDIASTREAMGROUPING HERE 

		select @RECCOUT=count(1)
		FROM WhatWeTake W
		INNER JOIN WWTRule WR ON W.WWTRuleID=WR.WWTRuleID
		INNER JOIN [RuleType] R ON WR.RuleTypeID=R.RuleTypeID
		INNER JOIN MediaStreamAssociation M on W.MediaStreamGroupID=M.MediaStreamGroupID
		INNER JOIN MediaStream S ON S.mediastreamid=M.MediaStreamID
		WHERE W.AdvertiserID=@AdvertiserID
		AND S.mediastreamid= @MediaStreamID
		and R.RuleType='No Take'
		and (EffectiveDT >= current_timestamp or EffectiveDT is null)
		and (EndDT <= current_timestamp or EndDT is null)
		IF @RECCOUT > 0 
		set @RESULTS='No Take'
	
	END 

	
	IF @AdvertiserID is not null 
	BEGIN
		PRINT 'Adv-Pub/pubgrp/mrkt No Take check'
		DECLARE @advCount int
		SELECT @advCount = count(1) 
		FROM WhatWeTake
		WHERE AdvertiserID = @AdvertiserID
		and (EffectiveDT >= current_timestamp or EffectiveDT is null)
		and (EndDT <= current_timestamp or EndDT is null)
		PRINT '@advCount: ' + cast(@advCount as varchar(10))

		if @advCount > 0 
		BEGIN 
			IF (@PublicationID is not null AND  @PublicationID >0)
			BEGIN
			--check for publication first 
				SELECT @RECCOUT=COUNT(1)
				FROM WhatWeTake W
				INNER JOIN WWTRule WR ON W.WWTRuleID=WR.WWTRuleID
				INNER JOIN [RuleType] R ON WR.RuleTypeID=R.RuleTypeID
				WHERE W.AdvertiserID=@AdvertiserID
				AND W.MediaStream= @MediaStreamID
				AND W.PublicationID=@PublicationID
				and R.RuleType='No Take'
					IF @RECCOUT > 0 
					set @RESULTS='No Take'

				INSERT INTO  @PubGroupList --Check if pub grouping
				SELECT pg.PubGroupID, pe.MarketID
				FROM PublicationGrouping pg
				inner join PubEdition pe on pg.PublicationID = pe.PublicationID
				WHERE pg.PublicationID = @PublicationID
				--select * from @PubGroupList

				INSERT INTO @WhatWeTake -- CHECK BASED ON PUB /PUBGROUP/ MARKET
				SELECT 
					wwt.WWTIndustryID,
					wwt.AdvertiserID,
					pgl.PubGroupID,
					pgl.MarketID,
					wwt.PublicationID,
					wwt.WWTRuleID
				FROM WhatWeTake wwt, @PubGroupList pgl
				WHERE wwt.AdvertiserID = @AdvertiserID
				and wwt.PublicationID = @PublicationID
				or (wwt.MarketID = pgl.MarketID
				and wwt.PubGroupID = pgl.PubGroupID
				and wwt.PublicationID is null
				)
				and (wwt.EffectiveDT >= current_timestamp or wwt.EffectiveDT is null)
				and (wwt.EndDT <= current_timestamp or wwt.EndDT is null)
				--select * from @WhatWeTake

					IF @@rowcount > 0 
					BEGIN
						print 'Advertiser Match! FOR PUB GROUPING/ check for no take'
						select @RECCOUT=COUNT(1)
						from @WhatWeTake wwt
						join Advertiser a on wwt.AdvertiserID = a.AdvertiserID
						join WWTRule r on wwt.RuleID = r.WWTRuleID
						join RuleType rt on r.RuleTypeID = rt.RuleTypeID
						where
						a.AdvertiserID =@AdvertiserID
						AND RT.RuleType='No Take'
						IF @RECCOUT > 0 
						set @RESULTS='No Take'
					END
				
				END
		END
	END

Select @RESULTS as RuleType
END
--GO
