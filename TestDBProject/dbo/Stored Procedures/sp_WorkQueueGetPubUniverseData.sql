-- =============================================
-- Author:		<Lisa East>
-- Create date: <2.23.17>
-- Description:	<Load the Pub Universe and what we take details in the publication preeview>
-- =============================================
CREATE PROCEDURE [dbo].[sp_WorkQueueGetPubUniverseData]
(
@publication AS VARCHAR(MAX)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DNTLISTLOCATION AS VARCHAR(100)
	DECLARE @PUBUNIVERSE AS VARCHAR(40)
	DECLARE @PUBUNIVERSEID AS INT
	SELECT @DNTLISTLOCATION= [Value] +'\DNTlist.xlsx'
	FROM Configuration 
	WHERE ComponentName='DoNotTake Repository' 


	BEGIN TRY

		SELECT @PUBUNIVERSE =C.ValueTitle, @PUBUNIVERSEID=C.ConfigurationID
		FROM Publication P 
		INNER JOIN CONFIGURATION C ON C.ConfigurationID=P.PubUniverseType
		INNER JOIN WHATWETAKE W ON W.PublicationID=P.PublicationID
		WHERE  P.Descrip=@publication

		IF @PUBUNIVERSE='Rule-Based'
		BEGIN
		---SELECT RULE  commented out 4.12.17 L.E.
			--SELECT DISTINCT C.ValueTitle AS PubUniverseType, A.Descrip as Advertiser,[RULETYPE].ruletype as RuleType, [WWTRULENOTE].RuleNote as [Rule], [PubGroup].GroupType, '' as DNTLIST
			--FROM [PUBLICATION] P
			--INNER JOIN [CONFIGURATION] C ON P.PubUniverseType=C.ConfigurationID
			--Left JOIN [WHATWETAKE] W ON P.PublicationID=W.PublicationID
			--INNER JOIN [ADVERTISER] A ON W.AdvertiserID=A.AdvertiserID
			--LEFT JOIN [WWTRULE] ON [WWTRULE].WWTRuleID=W.WWTRuleID
			--LEFT JOIN [RULETYPE] ON [WWTRULE].RuleTypeID =[RULETYPE].RuleTypeID
			--LEFT JOIN [WWTRULENOTE] ON [WWTRULE].WWTRuleNoteID= [WWTRULENOTE].WWTRuleNoteID
			--LEFT JOIN [PubGroup] ON W.PubGroupID=  [PubGroup].PubGroupID
			--Where p.PubUniverseType=@PUBUNIVERSEID

			--List of retailers to look for in pubs with specific rules like “only take Recreational Vehicle advertisers”, MI-972
			Select distinct @PUBUNIVERSE AS PubUniverseType, A.descrip As Advertiser, G.GroupType AS PubGroup,'' as DNTLIST
			from Publication P 
			join PublicationGrouping PG on P.publicationID =PG.PublicationID
			join PubGroup G on G.PubGroupID=PG.PubGroupID
			join WhatWeTake W on W.PubGroupID=PG.PubGroupID
			join advertiser A on W.AdvertiserID=A.advertiserID
			order by G.GroupType, A.descrip

		END 
		ELSE 
		BEGIN
		--SELECT DNT LIST
		SELECT @PUBUNIVERSE AS PubUniverseType,'' As Advertiser,'' AS PubGroup, @DNTLISTLOCATION AS DNTLIST
		END 

	END TRY

	BEGIN CATCH
	DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
	SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
	RAISERROR ('[sp_WorkQueueGetPubUniverseData]: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH
END