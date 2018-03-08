-- ============================================================================================
-- Author			:	Govardhan.R on 10/01/2015
-- Description		:	This view is to retrieve Ad Details For Display in Ad Classification Form
-- ==============================================================================================

CREATE VIEW [dbo].[vw_ClassifyPromoAdClassificationWorkQueue]

AS

--FOR NON PRINTS

SELECT DISTINCT VW.PRIORITY,VW.MEDIASTREAM,
A.FirstRunDate as FirstRunDate,
A.[AdID] as AdID,
A.CreateDate as CreateDTM,
LM.Description as Language,
MM.[Descrip] as PubMarket,
RG.ClassificationGroupName as ClassificationGroup,
A.[LanguageID] as LanguageID,	
A.[PrimaryOccurrenceID] as PrimaryOccurrenceID, 
RG.[RefClassificationGroupID] as ClassificationGroupID,
VW.MEDIASTREAMID,
CM.CONFIGURATIONID
FROM vw_ClassifyPromoAdClassficationData VW
INNER JOIN AD A ON VW.[AdID]=A.[AdID]
--INNER JOIN PATTERNMASTER PM ON PM.FK_AdId=A.PK_Id
INNER JOIN [Language] LM ON LM.LanguageID=A.[LanguageID]
LEFT OUTER JOIN [Market] MM ON A.[TargetMarketId]=MM.[MarketID]
INNER JOIN ADVERTISERINDUSTRYGROUP AI ON AI.[AdvertiserID]=A.[AdvertiserID]
INNER JOIN REFINDUSTRYGROUP RI ON RI.[RefIndustryGroupID]=AI.[IndustryGroupID]
INNER JOIN REFCLASSIFICATIONGROUP RG ON RG.[RefClassificationGroupID]=
(CASE 
WHEN A.[ClassificationGroupID] != NULL THEN A.[ClassificationGroupID] 
ELSE RI.[ClassificationGroupID] 
END)
INNER JOIN [Configuration] CM ON CM.VALUE=VW.MEDIASTREAMID AND CM.COMPONENTNAME='Media Stream'
WHERE ISNULL(A.[Query],0)!=1
AND a.CLASSIFIEDBY is NULL
AND A.NOTAKEADREASON is NULL
AND VW.MEDIASTREAM NOT IN ('CIR','PUB')

UNION ALL

--FOR PRINTS
SELECT DISTINCT VW.PRIORITY,VW.MEDIASTREAM,
A.FirstRunDate as FirstRunDate,
A.[AdID] as AdID,
OCR.[CreatedDT] as CreateDTM,
LM.Description as Language,
MM.[Descrip] as PubMarket,
RG.ClassificationGroupName as ClassificationGroup,
A.[LanguageID] as LanguageID,	
A.[PrimaryOccurrenceID] as PrimaryOccurrenceID, 
RG.[RefClassificationGroupID] as ClassificationGroupID,
VW.MEDIASTREAMID,
CM.CONFIGURATIONID
FROM vw_ClassifyPromoAdClassficationData VW
INNER JOIN AD A ON VW.[AdID]=A.[AdID]
--INNER JOIN PATTERNMASTER PM ON PM.FK_AdId=A.PK_Id
INNER JOIN [OccurrenceDetailCIR] OCR ON OCR.[OccurrenceDetailCIRID]=A.[PrimaryOccurrenceID]
INNER JOIN [Language] LM ON LM.LanguageID=A.[LanguageID]
INNER JOIN PUBEDITION PE ON PE.[PubEditionID]=OCR.[PubEditionID]
INNER JOIN PUBLICATION PC ON PC.[PublicationID]=PE.[PublicationID]
INNER JOIN [Market] MM ON PE.[MarketID]=MM.[MarketID]
INNER JOIN ADVERTISERINDUSTRYGROUP AI ON AI.[AdvertiserID]=A.[AdvertiserID]
INNER JOIN REFINDUSTRYGROUP RI ON RI.[RefIndustryGroupID]=AI.[IndustryGroupID]
INNER JOIN REFCLASSIFICATIONGROUP RG ON RG.[RefClassificationGroupID]=
(CASE 
WHEN A.[ClassificationGroupID] != NULL THEN A.[ClassificationGroupID] 
ELSE RI.[ClassificationGroupID] 
END)
INNER JOIN [Configuration] CM ON CM.VALUE=VW.MEDIASTREAMID AND CM.COMPONENTNAME='Media Stream'
WHERE ISNULL(A.[Query],0)!=1
AND a.CLASSIFIEDBY is NULL
AND A.NOTAKEADREASON is NULL
AND VW.MEDIASTREAM IN ('CIR')

UNION ALL

----FOR PRINTS
SELECT DISTINCT VW.PRIORITY,VW.MEDIASTREAM,
A.FirstRunDate as FirstRunDate,
A.[AdID] as AdID,
OCR.[CreatedDT] as CreateDTM,
LM.Description as Language,
MM.[Descrip] as PubMarket,
RG.ClassificationGroupName as ClassificationGroup,
A.[LanguageID] as LanguageID,	
A.[PrimaryOccurrenceID] as PrimaryOccurrenceID, 
RG.[RefClassificationGroupID] as ClassificationGroupID,
VW.MEDIASTREAMID,
CM.CONFIGURATIONID
FROM vw_ClassifyPromoAdClassficationData VW
INNER JOIN AD A ON VW.[AdID]=A.[AdID]
--INNER JOIN PATTERNMASTER PM ON PM.FK_AdId=A.PK_Id
INNER JOIN [OccurrenceDetailPUB] OCR ON OCR.[OccurrenceDetailPUBID]=A.[PrimaryOccurrenceID]
INNER JOIN [Language] LM ON LM.LanguageID=A.[LanguageID]
INNER JOIN PUBISSUE PUI ON PUI.[PubIssueID]=OCR.[PubIssueID]
INNER JOIN PUBEDITION PE ON PE.[PubEditionID]=PUI.[PubEditionID]
INNER JOIN [Market] MM ON PE.[MarketID]=MM.[MarketID]
INNER JOIN ADVERTISERINDUSTRYGROUP AI ON AI.[AdvertiserID]=A.[AdvertiserID]
INNER JOIN REFINDUSTRYGROUP RI ON RI.[RefIndustryGroupID]=AI.[IndustryGroupID]
INNER JOIN REFCLASSIFICATIONGROUP RG ON RG.[RefClassificationGroupID]=
(CASE 
WHEN A.[ClassificationGroupID] != NULL THEN A.[ClassificationGroupID] 
ELSE RI.[ClassificationGroupID] 
END)
INNER JOIN [Configuration] CM ON CM.VALUE=VW.MEDIASTREAMID AND CM.COMPONENTNAME='Media Stream'
WHERE ISNULL(A.[Query],0)!=1
AND a.CLASSIFIEDBY is NULL
AND A.NOTAKEADREASON is NULL
AND VW.MEDIASTREAM IN ('PUB')