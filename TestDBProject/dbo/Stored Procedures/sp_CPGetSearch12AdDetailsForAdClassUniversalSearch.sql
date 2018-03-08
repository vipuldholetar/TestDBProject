-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/26/2015
-- Description	: This stored procedure is used to get the add details for Ad Classfication Universal Search Screen.
-- Execution	: [sp_CPGetSearch12AdDetailsForAdClassUniversalSearch] '0','0','0','0','Television','New','New','New','','','','','','1','','','','',''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetSearch12AdDetailsForAdClassUniversalSearch]  
(
@ClearMax as int,
@IncludeNoTake as int,
@IncludeArchieve as int,
@IncludeUnclassified as int,
@MediaStream AS NVARCHAR(MAX),
@LeadAvHeadLine AS NVARCHAR(250),
@LeadText AS NVARCHAR(250),
@AdVisual AS NVARCHAR(250),
@AdvId as varchar(250),
@ProdId as varchar(250),  
@CatId as varchar(250),
@SubCatId as varchar(250), 
@CoopId as varchar(250),
@LanguageId as Int,
@LastRunDate as varchar(250),
@CreateDate as varchar(250),
@Description as varchar(250),
@TagLine as varchar(250),
@RecutDetails as varchar(250)
)
AS
BEGIN

     DECLARE @MediaStreamValue As Nvarchar(max)=''
			   DECLARE @MediaStreamBasePath As Nvarchar(max)=''
			     DECLARE @MaxRows as int;
				DECLARE @TotRows as int;
				select @TotRows=convert(int,999999999);
              SELECT @MediaStreamValue=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaStream
			  select @MediaStreamBasePath=VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository';
			    select  @MaxRows=CONVERT(int, Value) FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'MAX_RECORDS'
              BEGIN TRY
              IF(@MediaStreamValue='RAD')
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailRA] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccrncId=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)

							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailRA] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccrncId=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
 
                     END
              IF(@MediaStreamValue='TV')
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
                            SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailTV] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)

							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailTV] OCCR ON A.[AdID]=OCCR.[AdID]   --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
							END

         IF(@MediaStreamValue='OD')
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
                            SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailODR] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)

							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailODR] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END           
            IF(@MediaStreamValue='CIN')
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
					        SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailCIN] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)


							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailCIN] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
              IF(@MediaStreamValue='OND')             --Online Display
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
					        SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailOND] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)

							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailOND] OCCR ON A.[AdID]=OCCR.[AdID] -- AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
              IF(@MediaStreamValue='ONV')             --Online Video
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
					        SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailONV] OCCR ON A.[AdID]=OCCR.[AdID] -- AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)


							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailONV] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
               IF(@MediaStreamValue='MOB')             --Mobile
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
                            SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailMOB] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)


							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailMOB] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END 
					   IF(@MediaStreamValue='CIR')             --Mobile
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (
                            SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailCIR] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)


							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailCIR] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END     
					   IF(@MediaStreamValue='PUB')             --Mobile
                     BEGIN
					        SELECT * FROM (
							SELECT *,row_number() over(order by FILTER.AdID)[RNo] FROM (			 
                            SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailPUB] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							WHERE a.LeadAvHeadline LIKE '%'+@LeadAvHeadLine+'%'
							AND A.LeadText LIKE '%'+@LeadText+'%'
							AND A.AdVisual LIKE '%'+@AdVisual+'%'
							AND ((A.[AdvertiserID]=@AdvId) OR (A.[AdvertiserID] IN (SELECT [AdvertiserID] FROM [AdvertiserOld] WHERE Advertiser LIKE  '%'+@AdvId+'%')))
							AND ((A.ProductId=@ProdId) OR (A.ProductId IN (SELECT [RefProductID] FROM REFPRODUCT WHERE [SubCategoryID]=@SubCatId
							))
							OR (A.ProductId IN (SELECT b.[RefProductID] FROM RefSubCategory a, RefProduct b 
							WHERE b.[SubCategoryID] = a.[RefSubCategoryID]
							AND a.[CategoryID] = @CatId
							))
							)
							AND ACC.CoopCompCode LIKE '%'+@CoopId+'%'
							--AND CONVERT(int, '') IN (SELECT CoopCompCode 
							--FROM AdCoopComp,AD 
							--WHERE FK_AdID = aD.PK_Id)
							AND A.[LanguageID]=@LanguageId
							AND A.LastRunDate=@LastRunDate
							AND A.CreateDate=@CreateDate
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)


							UNION

							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail
							FROM
							AD A INNER JOIN [OccurrenceDetailPUB] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							where ((TG.Tagline  LIKE '%'+@TagLine+'%') OR (A.Description  LIKE '%'+@Description+'%') OR(A.RecutDetail  LIKE '%'+@RecutDetails+'%')) 
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) FILTER
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END          
              END TRY

              BEGIN CATCH
                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                                  RAISERROR ('sp_CPGetSearch12AdDetailsForAdClassUniversalSearch: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH
END