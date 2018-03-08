-- ======================================================================================================================================



-- Author		: Arun Nair

-- Create date	: 06/14/2015

-- Description	: Get Ad Data for Universal Search  

-- Updated By	: Arun Nair on 06/30/2015 - LastRunDate,CreateDate 

--				: Karunakar on 07/06/2015 - Adding Outdoor Media Stream to Universal Search Data

--				: Murali	on 07/09/2015 - Adding Tv Media Stream to Universal Search Data

--				: Karunakar on 07/16/2015 - Adding Cinema Media Stream to Universal Search Data

-- 				: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 

--				: Karunakar on 09/11/2015 

--				: Arun Nair on 09/21/2015,09/23/2015 - Added OnlineDisplay to Universal Search,Correct MediastreamValue

--				: Karunakar on 09/28/2015 - Adding Online Video Media Stream to Universal Search Data

--				: Arun Nair on 09/28/2015 - Added Format 

--				: Arun Nair on 10/05/2015 - Added Mobile to UniversalSearch  

--				: Karunakar on 10/09/2015 - Removing Full text for Advertiser and Lead Audio/Headline and Changing into Like Search

--				: Arun Nair on 10/19/2015 - Added Email to UniversalSearch

--				: Arun Nair on 11/20/2015 - Added Social to UniversalSearch

--=========================================================================================================================================



--[dbo].[sp_UniversalSearchClassifyPro]'<UniversalSearch>

--  <Language>English</Language>

--  <MediaStreamID>154</MediaStreamID>

--  <ClearMax>false</ClearMax>

--  <ClearMaxRecordValue>50</ClearMaxRecordValue>

--  <IncludeNoTake>false</IncludeNoTake>

--  <IncludeArchive>false</IncludeArchive>

--  <IncludeArchiveRecordValue>25</IncludeArchiveRecordValue>

--  <IncludeUnclassified>false</IncludeUnclassified>

--  <OrderBySQLStatement>ORDER BY AdID ASC,OccurrenceID ASC,Advertiser ASC</OrderBySQLStatement>

--  <MediaStreamVal>Email</MediaStreamVal>

--</UniversalSearch>'



CREATE PROCEDURE [dbo].[sp_UniversalSearchClassifyPro] 

(

 @XMLDOC AS XML

) 

AS 

    IF 1 = 0 

      BEGIN 

          SET FMTONLY OFF 

      END 

  BEGIN 

      SET NOCOUNT ON ;

      BEGIN TRY 



				  DECLARE @Stmnt AS NVARCHAR(4000)=''

				  DECLARE @SelectStmnt AS NVARCHAR(3000)=''

				  DECLARE @Where AS NVARCHAR(3000)='' 

				  DECLARE @LeadAudioHeadLine AS NVARCHAR(250)=''

				  DECLARE @TitleLeadText AS NVARCHAR(250)=''

				  DECLARE @Visual AS NVARCHAR(250)=''

				  DECLARE @Advertiser AS NVARCHAR(250)=''

				  DECLARE @FullText AS NVARCHAR(500)=''

				  DECLARE @AdID AS NVARCHAR(250)='' 

				  DECLARE @OccurrenceID AS NVARCHAR(250)='' 

				  DECLARE @CreativeSignature AS NVARCHAR(250)=''

				  DECLARE @Product AS NVARCHAR(250)='' 

				  DECLARE @ProductSubCategory AS NVARCHAR(250)=''

				  DECLARE @ProductCategory AS NVARCHAR(250)=''

				  DECLARE @CompetitorCooperative AS NVARCHAR(250)='' 

				  DECLARE @Language AS NVARCHAR(250)='' 

				  DECLARE @Len AS NVARCHAR(250)=''

				  DECLARE @ClearMax AS NVARCHAR(10)='' 

				  DECLARE @IncludeNoTake AS NVARCHAR(10)='' 

				  DECLARE @IncludeArchive AS NVARCHAR(10)=''

				  DECLARE @IncludeUnclassified AS NVARCHAR(10)=''

				  DECLARE @Option3Enabled AS INT=0 

				  DECLARE @ClearMaxRecordValue AS INT=0 

				  DECLARE @IncludeArchiveRecordValue AS INT=0 

				  DECLARE @ArchiveOrderBy AS NVARCHAR(100)=''

				  DECLARE @NOTAKE AS NVARCHAR(150)='' 

				  DECLARE @OrderBy AS NVARCHAR(250)='' 

				  DECLARE @MediaStreamID AS INTEGER=0 

				  DECLARE @MediaStreamVal AS NVARCHAR(50)='' 

				  DECLARE @IncludeChkUnclassified AS NVARCHAR(150)='' 

				  DECLARE @MediaStreamValue AS NVARCHAR(50)

				  DECLARE @From AS NVARCHAR(250) 

				  DECLARE @OnlyWhere AS NVARCHAR(MAX)

				  DECLARE @LastRunDate AS NVARCHAR(50)

				  DECLARE @CreateDate AS NVARCHAR(50)





				  SET @Option3Enabled=0 --Intially Set to 0  



				  SELECT universalsearchdetails.value('(LeadAudioHeadLine)[1]','NVARCHAR(250)') AS 'LeadAudioHeadLine', 

						 universalsearchdetails.value('(TitleLeadText)[1]','NVARCHAR(250)') AS 'TitleLeadText', 

						 universalsearchdetails.value('(Visual)[1]', 'NVARCHAR(50)') AS 'Visual',

						 universalsearchdetails.value('(Advertiser)[1]', 'NVARCHAR(50)') AS 'Advertiser',

						 universalsearchdetails.value('(FullText)[1]', 'NVARCHAR(50)') AS 'FullText', 

						 universalsearchdetails.value('(AdID)[1]', 'NVARCHAR(50)') AS 'AdID', 

						 universalsearchdetails.value('(OccurrenceID)[1]','NVARCHAR(50)') AS 'OccurrenceID',

						 universalsearchdetails.value('(CreativeSignature)[1]', 'NVARCHAR(50)')  AS 'CreativeSignature', 

						 universalsearchdetails.value('(Product)[1]', 'NVARCHAR(50)') AS 'Product',

						 universalsearchdetails.value('(ProductSubCategory)[1]', 'NVARCHAR(50)') AS 'ProductSubCategory', 

						 universalsearchdetails.value('(ProductCategory)[1]', 'NVARCHAR(50)') AS  'ProductCategory',

						 universalsearchdetails.value('(CompetitorCooperative)[1]', 'NVARCHAR(50)' ) AS 'CompetitorCooperative', 

						 universalsearchdetails.value('(Language)[1]', 'NVARCHAR(50)') AS 'Language', 

						 universalsearchdetails.value('(Length)[1]', 'NVARCHAR(10)') AS 'Length', 

						 universalsearchdetails.value('(ClearMax)[1]', 'NVARCHAR(10)') AS 'ClearMax',

						 universalsearchdetails.value('(IncludeNoTake)[1]', 'NVARCHAR(10)')  AS 'IncludeNotake',

						 universalsearchdetails.value('(IncludeArchive)[1]', 'NVARCHAR(10)') AS 'IncludeArchive',

						 universalsearchdetails.value('(IncludeUnclassified)[1]', 'NVARCHAR(10)')AS 'IncludeUnclassified',

						 universalsearchdetails.value('(ClearMaxRecordValue)[1]','INTEGER') AS 'ClearMaxRecordValue',

						 universalsearchdetails.value('(IncludeArchiveRecordValue)[1]','INTEGER') AS 'IncludeArchiveRecordValue',

						 universalsearchdetails.value('(OrderBySQLStatement)[1]','NVARCHAR(250)') AS 'OrderBy',

						 universalsearchdetails.value('(MediaStreamVal)[1]','NVARCHAR(50)') AS 'MediaStreamVal',

						 universalsearchdetails.value('(MediaStreamID)[1]', 'INTEGER') AS 'MediaStream' ,

						 universalsearchdetails.value('(LastRunDate)[1]', 'NVARCHAR(50)') AS 'LastRunDate' ,

						 universalsearchdetails.value('(CreateDate)[1]', 'NVARCHAR(50)') AS 'CreateDate' 

				  INTO   #searchtempval

				  FROM   @XMLDOC.nodes('UniversalSearch') AS UniversalSearchProc(universalsearchdetails) 



				   SELECT @LeadAudioHeadLine = leadaudioheadline, 

						 @TitleLeadText = titleleadtext,

						 @Visual = visual,

						 @Advertiser = advertiser, 

						 @FullText = fulltext,

						 @AdID = adid,

						 @OccurrenceID = occurrenceid, 

						 @CreativeSignature = creativesignature, 

						 @CompetitorCooperative = competitorcooperative,

						 @Language = language,

						 @Len = length, 

						 @ClearMax = clearmax, 

						 @IncludeNoTake = includenotake,

						 @IncludeArchive = includearchive,

						 @IncludeUnclassified = includeunclassified,

						 @ClearMaxRecordValue = clearmaxrecordvalue,

						 @IncludeArchiveRecordValue = includearchiverecordvalue,

						 @OrderBy = orderby,

						 @MediaStreamVal = mediastreamval,

						 @MediaStreamID = mediastream,

						 @LastRunDate=LastRunDate,

						 @CreateDate=CreateDate,

						 @Product=product,

						 @ProductSubCategory=ProductSubCategory,

						 @ProductCategory=ProductCategory,

						 @CompetitorCooperative=CompetitorCooperative

				  FROM   #searchtempval 

				  

				  SET @LastRunDate=CONVERT(VARCHAR(10),@LastRunDate,101)



				  --PRINT @LastRunDate



				  SELECT @MediaStreamValue = value FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND valuetitle= @mediastreamval

				  --PRINT @mediastreamval 

				  --PRINT @MediaStreamValue





				  SET @SelectStmnt=' SELECT AdID,OriginalAdID,OccurrenceID,Advertiser,'''+ @MediaStreamVal + ''' AS MediaStream,Visual,LastRunDate,



								CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,'''' AS Product,LeadText,RecutDetail,Language,Description,TaglineID,No TakeAdReason,AdvertiserID,Format ' 



					IF( @IncludeArchive = 'true' OR @IncludeArchive = 'True' )  --------------IncludeArchive Checked---------------------------------------------------- 

						  BEGIN 



							  SET @SelectStmnt=' SELECT TOP '+ CONVERT(VARCHAR, @IncludeArchiveRecordValue) + ' AdID,OriginalAdID,OccurrenceID,Advertiser,'''+ @MediaStreamVal+ ''' AS MediaStream,Visual,

							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,'''' AS Product, LeadText,RecutDetail,Language,Description,TaglineID,NoTakeAdReason,AdvertiserID,Format  ' 

						  END 

					ELSE IF( @ClearMax = 'true' OR @ClearMax = 'True' ) ----------------------Clear Max Checked------------------------------------------------- 

						  BEGIN 

							  SET @SelectStmnt=' SELECT AdID,OriginalAdID,OccurrenceID,Advertiser,'''+ @MediaStreamVal+ ''' AS MediaStream,Visual,

							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,'''' AS Product,LeadText,RecutDetail,Language,Description,TaglineID, NoTakeAdReason,AdvertiserID,Format  ' 

						  END 

					ELSE 

						  BEGIN 

							  SET @SelectStmnt=' SELECT TOP '+ CONVERT(VARCHAR, @ClearMaxRecordValue)+ '  AdID,OriginalAdID,OccurrenceID,Advertiser,'''+ @MediaStreamVal+''' AS MediaStream,Visual,

							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,'''' AS Product,LeadText,RecutDetail,Language,Description,TaglineID,NoTakeAdReason,AdvertiserID,Format  ' 

						  END 



					IF @MediaStreamValue='RAD' -------------------Change View According to MediaStream-------------------------------------

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchRadioClassifyPromo]'

						END

					ELSE IF @MediaStreamValue='CIR'

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchCircular]'

						END

					ELSE IF @MediaStreamValue='PUB'

						BEGIN

							SET @from='FROM  [dbo].[vw_UniversalSearchPublication]'

						END														 -- Adding on 06th July 2015 for Outdoor

					ELSE IF @MediaStreamValue='OD'

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchOutdoor]'

						END

					ELSE IF @MediaStreamValue='TV'                               -- Adding on 09th July 2015 for TV

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchTelevision]'

						END

					ELSE IF @MediaStreamValue='CIN'								 -- Adding on 16th July 2015 for Cinema

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchCinema]'

						END

					ELSE IF @MediaStreamValue='OND'								 -- Adding on 14th Sep 2015 for Online Display

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchOnlineDisplay]'

						END

					ELSE IF @MediaStreamValue='ONV'								 -- Adding on 28th Sep 2015 for Online Video

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchOnlineVideo]'

						END

					ELSE IF @MediaStreamValue='MOB'								 -- Added On 10/05/2015 For Mobile 

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchMobile]'

						END

					ELSE IF @MediaStreamValue='EM'								 -- Added On 10/19/2015 For Email 

						BEGIN

							SET @from='FROM [dbo].[vw_UniversalSearchEmail]'

						END

					ELSE IF @MediaStreamValue='SOC'								 -- Added On 11/20/2015 For Social 

						BEGIN

							SET @from ='FROM [dbo].[vw_UniversalSearchSocial]'

						END





						

					IF( @IncludeNoTake = 'false' OR @IncludeNoTake = 'False' ) ----------------IncludeNoTake Checked-------------------------------------------------------

						BEGIN 

							SET @NOTAKE= ' AND NoTakeAdReason IS NULL '

						END 



					IF( @IncludeUnclassified = 'false' OR @IncludeUnclassified = 'False' ) 

						BEGIN 

							SET @IncludeChkUnclassified= ' AND Unclassified=0 ' 

						END 





					SET @OnlyWhere=' WHERE (1=1) ' 





						-------Option3----------------------------------If values are provided here then values provided in Option 1 & Option 2 will be ignored. 



						IF( @AdID <> '' OR @OccurrenceID <> '' OR @CreativeSignature <> '' ) 



						  BEGIN

							  --PRINT 'option3' 

							  SET @Option3Enabled=1

							  IF( @AdID <> '' ) 

								BEGIN 

									SET @Where=@Where + ' AND AdID like ''' + @AdID + '%''' 

								END 

							  ELSE IF( @OccurrenceID <> '' ) 

								BEGIN 

									SET @Where=@Where + ' AND OccurrenceID like  '''+ @OccurrenceID + '%''' 

								END 

							  ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'RAD' ) 

								BEGIN 

									SET @SelectStmnt= @SelectStmnt + @From + ' inner join PatternDetailRA on [dbo].[vw_UniversalSearchRadio].patternmasterid=PatternDetailRA.FK_PatternId '

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'')' 

						        END

							  ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'OD' )  -- Adding on 06th July 2015 for Outdoor 

								BEGIN 	

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'')' 

						        END 

							   ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'TV' )  -- Adding on 09th July 2015 for TV 

								BEGIN 

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'') ' 

						        END 

							  ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'CIN' )  -- Adding on 16th July 2015 for Cinema 

								BEGIN 

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'') ' 

						        END  

							  ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'OND' )  -- Adding on 14th Sep 2015 for Online Display 

								BEGIN 

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'') ' 

						        END 

							 ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'ONV' )  -- Adding on 28th Sep 2015 for Online Video 

								BEGIN 

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'') ' 

						        END  

							 ELSE IF( @CreativeSignature <> '' AND @MediaStreamValue = 'MOB' )  -- Added On 10/05/2015 for Mobile

								BEGIN 

									SET @Where=@Where   + '  AND Contains(CreativeSignature,'''+ '"'+ @CreativeSignature +  '*"'') ' 

						        END   

						  ELSE 



								SET @Option3Enabled=0 



						  END 



						-------------------Option2 & Option3----------------------------------------------------------------------- 

						IF( @Option3Enabled = 0 )

						  BEGIN 

							  IF( @FullText <> '' ) --If FullText Has Values 

								BEGIN

									SET @Where= @where + ' AND FREETEXT(*,''' + @FullText+ ''')  OR Contains(Description,'''+ '"'+ @FullText +  '*"'')

														   OR Contains(TaglineID,''' + '"'+ @FullText  + '*"'') OR Contains(RecutDetail,'''+ '"' + @FullText+ '*"'') '

								END 

							  ELSE IF(@Option3Enabled = 0) 

								BEGIN 

									IF(@TitleLeadText <> '') 

									  BEGIN

										  SET @Where=@Where + ' AND Contains(LeadText,''' + '"'+@TitleLeadText + '*"'') ' 	

									  END 

									 IF(@LeadAudioHeadLine <> '')  --Updated on 09th Oct 2015,Removing Full text for Lead Audio Head Line

									  BEGIN

										  SET @Where=@Where + ' AND LeadAudio   like ''%' + @LeadAudioHeadLine + '%'''

									  END 

									IF(@Advertiser <> '') --Updated on 09th Oct 2015,Removing Full text for Advertiser

									  BEGIN 

										  --SET @Where=@Where + ' and Contains(Advertiser,'''+ '"'+ @Advertiser + '*"'') '

										  SET @Where=@Where + ' AND Advertiser  like ''%' + @Advertiser + '%''' 

									  END 

									 IF(@Visual <> '')

									  BEGIN 

										  SET @Where=@Where + ' AND Contains(Visual,'''+'"'+ + @Visual+ '*"'') '

									  END 

									 IF(@Language <> '') 

									  BEGIN 

										  SET @Where=@Where + ' AND FREETEXT(Language,'''+ @Language + ''') ' 

									  END

									  IF((@Product <> 0 and @Product<>'') or (@ProductSubCategory <> '' and @ProductSubCategory<>'---Select---') or (@ProductCategory <> '' and @ProductCategory<>'---Select---') )

									  BEGIN 

										  SET @Where=@Where + ' AND ((productid = '''+ @Product + ''') or (productid in ( SELECT PK_Id FROM RefProduct WHERE FK_SubCategoryId ='''+ @ProductSubCategory + ''')) 
										  or ( productid in (SELECT b.PK_Id FROM RefSubCategory a, RefProduct b WHERE b.FK_SubCategoryId = a.PK_Id AND a.FK_CategoryId = '''+ @ProductCategory + ''')) ) ' 

									  END

									   IF(@CompetitorCooperative<>'' and @CompetitorCooperative<>0) 

									  BEGIN 

										  SET @Where=@Where + ' AND '''+@CompetitorCooperative+''' in (select fk_advertiserid from adcoopcomp where FK_AdID=adid) ' 

									  END


								END 



						 END 
						 
						IF(@Language <> '') 

							BEGIN 

								SET @Where=@Where + ' AND FREETEXT(Language,'''+ @Language + ''') ' 

							END

						IF(@LastRunDate <> '') 

							BEGIN

								SET @Where=@Where + ' AND LastRunDate='''+Convert(VARCHAR, @LastRunDate) + '''' 

							END

						IF(@CreateDate <> '') 

							BEGIN 

								SET @Where=@Where + ' AND CreateDate='''+ Convert(VARCHAR,@CreateDate) + '''' 

							END

						IF( @MediaStreamID <> 0 )

							BEGIN 

								SET @Where=@Where + ' AND (MediaStreamID=' + CONVERT(VARCHAR, @MediaStreamID) + ') '

							END 

						IF( @IncludeArchive = 'true' OR @IncludeArchive = 'True' ) 

							BEGIN 

								SET @ArchiveOrderBy=',LastRunDate DESC' 

							END 









						  -----Concatenate All to Make Select Statement-----------------------------------------------------

						  

						  IF (@MediaStreamValue = 'RAD' and @CreativeSignature <> '' ) ---If Mediastream is Radio

								BEGIN

									SET @Stmnt=@SelectStmnt + @OnlyWhere+ @Where+ @NOTAKE + @IncludeChkUnclassified + @OrderBy + @ArchiveOrderBy 

								END		

								-- Add MediaStream for CreativeSignature

						  ELSE IF((@MediaStreamValue = 'OD' or @MediaStreamValue = 'TV' or @MediaStreamValue = 'CIN' OR   @MediaStreamValue = 'OND'

								  OR   @MediaStreamValue = 'ONV' OR @MediaStreamValue = 'MOB') AND (@CreativeSignature <> '')) 

								BEGIN

									SET @Stmnt=@SelectStmnt +@From+ @OnlyWhere+ @Where+ @NOTAKE + @IncludeChkUnclassified + @OrderBy + @ArchiveOrderBy 

								END 

						  ELSE

								BEGIN

									SET @Stmnt=@SelectStmnt + @From + @OnlyWhere+@Where + @NOTAKE + @IncludeChkUnclassified + @OrderBy + @ArchiveOrderBy 

								END



						DROP TABLE #searchtempval 

						PRINT @Stmnt 

						EXEC SP_EXECUTESQL @Stmnt  

					END TRY 



					BEGIN CATCH

						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT

						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()

						RAISERROR ('sp_UniversalSearch: %d: %s',16,1,@error,@message,@lineNo);

					END CATCH 



END
