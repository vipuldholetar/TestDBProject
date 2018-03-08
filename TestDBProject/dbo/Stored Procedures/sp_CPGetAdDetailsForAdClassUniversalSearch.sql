-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/26/2015
-- Description	: This stored procedure is used to get the Ad details.
-- Execution	: [sp_CPGetAdDetailsForAdClassUniversalSearch] 0,0,0,0,'Radio','5252','',''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetAdDetailsForAdClassUniversalSearch]  
(
@ClearMax as int,
@IncludeNoTake as int,
@IncludeArchieve as int,
@IncludeUnclassified as int,
@MediaStream AS NVARCHAR(MAX),
@AdID AS INT,
@OccrId as INT,
@CreativeSign as varchar(250)    
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
							--SELECT  DISTINCT A.PK_Id,A.LeadAvHeadline[LeadAudioHeadline],A.LeadText,ADV.Advertiser[AdvsertiserName],
							--A.AdVisual,RP.ProductName,RSC.SubCategoryName,RC.CategoryName,ADV.Advertiser[Competitor],
							--LM.Description
							SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailRA] OCCR ON A.[AdID]=OCCR.[AdID] -- AND OCCR.PK_OccrncId=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailRAID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
 
                     END
              IF(@MediaStreamValue='TV')
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailTV] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailTVID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                           END
         IF(@MediaStreamValue='OD')
                     BEGIN
					 		SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailODR] OCCR ON A.[AdID]=OCCR.[AdID]  --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailODRID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END           
            IF(@MediaStreamValue='CIN')
                     BEGIN  
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailCIN] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_Id=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailCINID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
              IF(@MediaStreamValue='OND')             --Online Display
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad A 
							INNER JOIN [OccurrenceDetailOND] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailONDID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
              IF(@MediaStreamValue='ONV')             --Online Video
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailONV] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailONVID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END    
               IF(@MediaStreamValue='MOB')             --Mobile
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailMOB] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccurrenceDetailID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailMOBID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END 
					   IF(@MediaStreamValue='CIR')             --Mobile
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailCIR] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailCIRID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END     
					   IF(@MediaStreamValue='PUB')             --Mobile
                     BEGIN
					        SELECT DISTINCT AdID,OccurrenceId,Advertiser,MediaStream,LastRunDate,CreateDate,LeadAudioHeadline,AdLength
							RecutType,ProductName,LeadText,RecutDetail  FROM (
							SELECT DISTINCT A.[AdID][AdID],A.[PrimaryOccurrenceID][OccurrenceId],Adv.Advertiser,cm.ValueTitle[MediaStream],
							a.LastRunDate,a.CreateDate,A.LeadAvHeadline[LeadAudioHeadline],a.AdLength,
							''[RecutType],RP.ProductName,A.LeadText,a.RecutDetail,row_number() over(order by a.[AdID])[RNo]
							FROM Ad a 
							INNER JOIN [OccurrenceDetailPUB] OCCR ON A.[AdID]=OCCR.[AdID] --AND OCCR.PK_OccurrenceID=A.PrimaryOccrncId
							INNER JOIN [Pattern] PTR ON OCCR.[PatternID]=PTR.[PatternID]
							INNER JOIN [Configuration] CM ON CM.ConfigurationID=PTR.MediaStream
							LEFT OUTER JOIN [AdvertiserOld] ADV ON A.[AdvertiserID]=ADV.[AdvertiserID]
							LEFT OUTER JOIN REFPRODUCT RP ON A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFSUBCATEGORY  RSC ON RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND A.ProductId=RP.[RefProductID]
							LEFT OUTER JOIN REFCATEGORY RC ON A.ProductId=RP.[RefProductID] AND RP.[SubCategoryID]=RSC.[RefSubCategoryID] AND RSC.[CategoryID]=RC.[RefCategoryID]
							LEFT OUTER JOIN ADCOOPCOMP ACC ON A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]
							LEFT OUTER JOIN [Language] LM ON A.[LanguageID]=LM.LanguageID
							LEFT OUTER JOIN REFTAGLINE TG ON A.TaglineId=TG.[RefTaglineID]
							WHERE ((A.[AdID]=@AdID) OR (OCCR.[OccurrenceDetailPUBID]=@OccrId) OR (PTR.CreativeSignature=@CreativeSign))
							AND ISNULL(A.NoTakeAdReason,9)=(CASE WHEN @IncludeNoTake=0 THEN 9 ELSE A.NoTakeAdReason END)
							AND A.Unclassified<>(CASE WHEN @IncludeUnclassified=0 THEN 1 ELSE 2 END)
							) SUB 
							WHERE RNo <(CASE WHEN @IncludeArchieve=0 AND @ClearMax=0 THEN @MaxRows ELSE @TotRows END )
                     END          
              END TRY
              BEGIN CATCH
                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                                  RAISERROR ('sp_CPGetAdDetailsForAdClassUniversalSearch: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH
END