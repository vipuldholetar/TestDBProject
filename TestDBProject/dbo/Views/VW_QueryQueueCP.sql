





-- =============================================================================



-- Author		: Govardhan.R



-- =============================================================================







-- Author		: Govardhan.R







-- Create date	: 12/21/2015







-- Description	: Gets the data as View for the query queue form.







-- Updated By	: 







-- Execution	: Select * from [dbo].[VW_QueryQueueCP]







--===============================================================================







CREATE VIEW [dbo].[VW_QueryQueueCP]







AS







--For Ads







--Outdoor







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailTV] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailTVID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL











UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailRA] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailRAID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







 QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailCIN] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailCINID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







 QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailODR] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailODRID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







  A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailONV] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailONVID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







 QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailOND] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailONDID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailMOB] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailMOBID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailCIR] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailCIRID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailPUB] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailPUBID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailEM] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailEMID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailSOC] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailSOCID]





 

INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







A.[AdID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







A.[AdID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'AD'[KeyIDMode],







A.[Query]







FROM [QueryDetail] QD







INNER JOIN AD A ON QD.[AdID]=A.[AdID]







INNER JOIN [dbo].[OccurrenceDetailWEB] OCR ON A.[PrimaryOccurrenceID]=OCR.[OccurrenceDetailWEBID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] AND A.[AdID]=PM.[AdID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='AD'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND A.IsQuery IS NOT NULL











UNION ALL







--For Occurrences







SELECT DISTINCT







PM.MediaStream[MediaStream],







OCR.[OccurrenceDetailPUBID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







OCR.[OccurrenceDetailPUBID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'occurrence'[KeyIDMode],







OCR.[Query]







FROM [QueryDetail] QD







INNER JOIN [dbo].[OccurrenceDetailPUB] OCR ON QD.[OccurrenceID]=OCR.[OccurrenceDetailPUBID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] 







INNER JOIN AD A ON OCR.[AdID]=A.[AdID]







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







QD.System='C&P'







AND QD.EntityLevel='OCC'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND OCR.IsQuery IS NOT NULL







UNION ALL







SELECT DISTINCT







PM.MediaStream[MediaStream],







OCR.[OccurrenceDetailCIRID][RecordID],







''[Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







OCR.[OccurrenceDetailCIRID] [KeyID],







NULL as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'occurrence'[KeyIDMode],







OCR.[Query]







FROM [QueryDetail] QD







INNER JOIN [dbo].[OccurrenceDetailCIR] OCR ON QD.[OccurrenceID]=OCR.[OccurrenceDetailCIRID]







INNER JOIN [Pattern] PM ON PM.[PatternID]=OCR.[PatternID] 







INNER JOIN AD A ON OCR.[AdID]=A.[AdID]







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=A.[AdvertiserID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE --QD.QueryAnswer IS NULL AND 







 QD.System='C&P'







AND QD.EntityLevel='OCC'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'







--AND OCR.IsQuery IS NOT NULL











UNION ALL















--For Promotion Records







SELECT DISTINCT







--'TBD'[MediaStream],







(SELECT CONFIGURATIONID FROM [Configuration] WHERE VALUE=QD.[MediaStreamID] AND COMPONENTNAME='Media Stream' AND SYSTEMNAME='All') [MediaStream],







pm.[CropID][RecordID],







RC.CategoryName [Category],







CM.ValueTitle[QueryCategory],







CM.ConfigurationID[QueryCategoryID],







QD.QueryText[Question],







QD.QryRaisedBy [RaisedBy],







QD.QryRaisedOn[RaisedOn],







QD.[QryAnswer][Answer],







QD.QryAnsweredBy[AnsweredBy],







QD.QryAnsweredOn[AnsweredOn],







--IFNULL(QD.QryAnsweredOn,(GETDATE()-QD.QryRaisedOn),(QD.QryAnsweredOn-QD.QryRaisedOn))[Age],







PM.[PromotionID] [KeyID],







[CategoryID] as [CATEGORYID],







ADG.[IndustryGroupID] [INDUSTRYGROUP],







QD.[QueryID] [QueryID],







'promotion'[KeyIDMode],







PM.[Query]







FROM [QueryDetail] QD







INNER JOIN [Promotion] PM ON QD.[PromoID]=PM.[PromotionID]







INNER JOIN [Configuration] CM ON CM.VALUE=QD.QueryCategory







INNER JOIN REFCATEGORY RC ON RC.[RefCategoryID]=PM.[CategoryID]







INNER JOIN [Advertiser] AM ON AM.AdvertiserID=PM.[AdvertiserID]







INNER JOIN ADVERTISERINDUSTRYGROUP ADG ON ADG.[AdvertiserID]=AM.AdvertiserID







WHERE 







--PM.IsQuery IS NOT NULL







--AND QD.QueryAnswer IS  NULL







--AND 







QD.System='C&P'







AND QD.EntityLevel='PRO'







AND CM.SystemName='All'







AND CM.ComponentName='Query Category'