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
--				: Ashanie	on 04/01/2017 - Allow search across media stream and fill in code for product and coop/Competitor search
--				: Letesha	on 02/05/2018 - Replace (emoji) with wild card
--=========================================================================================================================================

--[dbo].[sp_UniversalSearch]'<UniversalSearch>
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

CREATE PROCEDURE [dbo].[sp_UniversalSearch] 
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
      --BEGIN TRY 

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
				  DECLARE @From AS NVARCHAR(max) 
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
						 @Product = Product,
						 @ProductCategory = ProductCategory,
						 @ProductSubCategory = ProductSubCategory,
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
						 @CreateDate=CreateDate
				  FROM   #searchtempval 
				  
				  SET @LastRunDate=CONVERT(VARCHAR(10),@LastRunDate,101)

				  --PRINT @LastRunDate

				  SELECT @MediaStreamValue = value FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND valuetitle= @mediastreamval
				  --PRINT @mediastreamval 
				  --PRINT @MediaStreamValue


				  SET @SelectStmnt=' SELECT DISTINCT us.AdID,OriginalAdID,Advertiser, MediaStream,MediaStreamId,Visual,LastRunDate,

								CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,p.ProductName AS Product,LeadText,RecutDetail,Language,Description,TaglineID,No TakeAdReason,us.AdvertiserID ' 

					IF( @IncludeArchive = 'true' OR @IncludeArchive = 'True' )  --------------IncludeArchive Checked---------------------------------------------------- 
						  BEGIN 

							  SET @SelectStmnt=' SELECT DISTINCT TOP '+ CONVERT(VARCHAR, @IncludeArchiveRecordValue) + ' us.AdID,OriginalAdID,Advertiser, MediaStream,MediaStreamId,Visual,
							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,p.ProductName AS Product, LeadText,RecutDetail,Language,Description,TaglineID,NoTakeAdReason,us.AdvertiserID  ' 
						  END 
					ELSE IF( @ClearMax = 'true' OR @ClearMax = 'True' ) ----------------------Clear Max Checked------------------------------------------------- 
						  BEGIN 
							  SET @SelectStmnt=' SELECT DISTINCT us.AdID,OriginalAdID,Advertiser, MediaStream,MediaStreamId,Visual,
							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,p.ProductName AS Product,LeadText,RecutDetail,Language,Description,TaglineID, NoTakeAdReason,us.AdvertiserID  ' 
						  END 
					ELSE 
						  BEGIN 
							  SET @SelectStmnt=' SELECT DISTINCT TOP '+ CONVERT(VARCHAR, @ClearMaxRecordValue)+ '  us.AdID,OriginalAdID,Advertiser, MediaStream,MediaStreamId,Visual,
							  LastRunDate,CreateDate,LeadAudio,Len AS Length,case  when originaladid is null then ''N'' else ''R'' end   AS RecutType,p.ProductName AS Product,LeadText,RecutDetail,Language,Description,TaglineID,NoTakeAdReason,us.AdvertiserID  ' 
						  END 

				    SET @SelectStmnt= @SelectStmnt+ ', dbo.ufn_GetCSfromAdId(us.adid) AS CreativeSignature
				    , dbo.ufn_GetPrimaryOccurrencefromAdId (us.AdId) as OccurrenceID '

				    SET @OrderBy = REPLACE(@OrderBy,'OccurrenceID asc,','')
					
					IF @MediaStreamValue='RAD' -------------------Change View According to MediaStream-------------------------------------
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchRadio] us '
						END
					ELSE IF @MediaStreamValue='CIR'
						BEGIN
							SET @from=', ''NA'' AS Format, pi.pubissueId,pi.IssueDate 
							FROM [dbo].[vw_UniversalSearchPrint] us LEFT JOIN 
							[OccurrenceDetailPUB] oc ON [oc].[OccurrenceDetailPUBID]=us.[OccurrenceID] 
							LEFT JOIN PubIssue pi on pi.PubIssueId = oc.PubIssueId'
						END
					ELSE IF @MediaStreamValue='PUB'
						BEGIN
							SET @from=', ''NA'' AS Format, pi.pubissueId,pi.IssueDate 
							FROM [dbo].[vw_UniversalSearchPrint] us LEFT JOIN 
							[OccurrenceDetailPUB] oc ON [oc].[OccurrenceDetailPUBID]=us.[OccurrenceID]
							LEFT JOIN PubIssue pi on pi.PubIssueId = oc.PubIssueId'
						END														 -- Adding on 06th July 2015 for Outdoor
					ELSE IF @MediaStreamValue='OD'
						BEGIN
							SET @from=',Format FROM [dbo].[vw_UniversalSearchOutdoor] us '
						END
					ELSE IF @MediaStreamValue='TV'                               -- Adding on 09th July 2015 for TV
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchAV] us '
						END
					ELSE IF @MediaStreamValue='CIN'								 -- Adding on 16th July 2015 for Cinema
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchAV] us '
						END
					ELSE IF @MediaStreamValue='OND'								 -- Adding on 14th Sep 2015 for Online Display
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchDigital] us '
						END
					ELSE IF @MediaStreamValue='ONV'								 -- Adding on 28th Sep 2015 for Online Video
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchAV] us '
						END
					ELSE IF @MediaStreamValue='MOB'								 -- Added On 10/05/2015 For Mobile 
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchDigital] us '
						END
					ELSE IF @MediaStreamValue='EM'								 -- Added On 10/19/2015 For Email 
						BEGIN
							SET @from=', ''NA'' AS Format FROM [dbo].[vw_UniversalSearchEmail] us '
						END
					ELSE IF @MediaStreamValue='SOC'								 -- Added On 11/20/2015 For Social 
						BEGIN
							SET @from =', ''NA'' AS Format,SocialType FROM [dbo].[vw_UniversalSearchSocial] us '
						END

				    -- Product
				    SET @From = @From + ' LEFT JOIN RefProduct p on p.RefProductId = us.ProductId '

						
					IF( @IncludeNoTake = 'false' OR @IncludeNoTake = 'False' ) ----------------IncludeNoTake Checked-------------------------------------------------------
						BEGIN 
							SET @NOTAKE= ' AND NoTakeAdReason IS NULL '
						END 

					IF( @IncludeUnclassified = 'false' OR @IncludeUnclassified = 'False' ) 
						BEGIN 
							SET @IncludeChkUnclassified= ' AND Unclassified=0 ' 
						END 


					SET @OnlyWhere=' WHERE (1=1) ' 

					IF @MediaStreamValue IN('PUB','CIR')
					   SET @OnlyWhere = @OnlyWhere + ' AND ((MediaStream=''Publication'' and pi.pubissueId is not null) OR (MediaStream=''Circular'')) '
						  
						-------Option3----------------------------------If values are provided here then values provided in Option 1 & Option 2 will be ignored. 

						IF( @AdID <> '' OR @OccurrenceID <> '' OR @CreativeSignature <> '' ) 

						  BEGIN
							  --PRINT 'option3' 
							  SET @Option3Enabled=1
							  IF( @AdID <> '' ) 
								BEGIN 
									SET @Where=@Where + ' AND us.AdID like ''' + @AdID + '%''' 
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
										  declare @ORTitleLeadText as varchar(max) = null;
											SET @TitleLeadText = LTRIM(RTRIM(@TitleLeadText))
											If (Select LOWER(LEFT(@TitleLeadText,7)))= '(emoji)' OR (Select LOWER(RIGHT(@TitleLeadText,7)))= '(emoji)'
											begin
												SET @TitleLeadText = REPLACE(@TitleLeadText,'(emoji)','')
												SET @TitleLeadText = LTRIM(RTRIM(@TitleLeadText))
											end 
											Else
											begin
												SET @TitleLeadText = REPLACE(@TitleLeadText,'(emoji)',' [A-Z0-9]% ')
												SET @TitleLeadText = REPLACE(@TitleLeadText,'  ',' ')
												SET @ORTitleLeadText =  REPLACE(@TitleLeadText,' [A-Z0-9]% ','[^A-Z0-9]%')
											end 
											If (@ORTitleLeadText <>'' and @ORTitleLeadText is not null)
											Begin
												SET @Where=@Where + ' AND (LeadText like ''%'+@TitleLeadText + '%'' OR LeadText like ''%'+@ORTitleLeadText + '%'')' 	 
											End
											Else
											Begin
												SET @Where=@Where + ' AND LeadText like ''%'+@TitleLeadText + '%'''
											End 											
									  END 
									 IF(@LeadAudioHeadLine <> '')  --Updated on 09th Oct 2015,Removing Full text for Lead Audio Head Line
									  BEGIN
										 declare @ORLeadAudio as varchar(max) = null;
											SET @LeadAudioHeadLine = LTRIM(RTRIM(@LeadAudioHeadLine))
											If (Select LOWER(LEFT(@LeadAudioHeadLine,7)))= '(emoji)' OR (Select LOWER(RIGHT(@LeadAudioHeadLine,7)))= '(emoji)'
											begin
												SET @LeadAudioHeadLine = REPLACE(@LeadAudioHeadLine,'(emoji)','')
												SET @LeadAudioHeadLine = LTRIM(RTRIM(@LeadAudioHeadLine))
											end 
											Else
											begin
												SET @LeadAudioHeadLine = REPLACE(@LeadAudioHeadLine,'(emoji)',' [A-Z0-9]% ')
												SET @LeadAudioHeadLine = REPLACE(@LeadAudioHeadLine,'  ',' ')
												SET @ORTitleLeadText =  REPLACE(@LeadAudioHeadLine,' [A-Z0-9]% ','[^A-Z0-9]%')
											end 
											If (@ORLeadAudio <>'' and @ORLeadAudio is not null)
											Begin
												SET @Where=@Where + ' AND (LeadAudio like ''%'+@LeadAudioHeadLine + '%'' OR LeadText like ''%'+@ORLeadAudio + '%'')' 	 
											End
											Else
											Begin
												SET @Where=@Where + ' AND LeadAudio like ''%'+@LeadAudioHeadLine + '%'''
											End 
										  --SET @Where=@Where + ' AND LeadAudio   like ''%' + @LeadAudioHeadLine + '%'''
									  END 
									IF(@Advertiser <> '') --Updated on 09th Oct 2015,Removing Full text for Advertiser
									  BEGIN 
										  --SET @Where=@Where + ' and Contains(Advertiser,'''+ '"'+ @Advertiser + '*"'') '
										  SET @Where=@Where + ' AND Advertiser  like ''%' + @Advertiser + '%''' 
									  END 
									 IF(@Visual <> '')
									  BEGIN 
										  SET @Where=@Where + ' AND Visual like ''%'+ @Visual+ '%'''
									  END 
									 --IF(@Language <> '') 
									 -- BEGIN 
										--  SET @Where=@Where + ' AND FREETEXT(Language,'''+ @Language + ''') ' 
									 -- END
								END 

						 END 


						  IF @Product <> '' 
						  BEGIN
							 SET @Where = @Where + ' AND p.ProductName LIKE ''%' + @Product + '%'''
						  END
						  IF @CompetitorCooperative <> ''
						  BEGIN
							 DECLARE @COOPId AS varchar(20)
							 SELECT @COOPId = AdvertiserId FROM Advertiser WHERE Descrip=@CompetitorCooperative
							 
							 IF @COOPId > 0
								SET @Where = @Where + ' AND (Coop1AdvId = ' + @COOPId + '
												    OR Coop2AdvId = ' + @COOPId + '
												    OR Coop3AdvId = ' + @COOPId + '
												    OR Comp1AdvId = ' + @COOPId + '
												    OR Comp2AdvId = ' + @COOPId + ')'
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
						--IF( @MediaStreamID <> 0 )
						--	BEGIN 
						--		SET @Where=@Where + ' AND (MediaStreamID=' + CONVERT(VARCHAR, @MediaStreamID) + ') '
						--	END 
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
					--END TRY 

					--BEGIN CATCH
					--	DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
					--	SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
					--	RAISERROR ('sp_UniversalSearch: %d: %s',16,1,@error,@message,@lineNo);
					--END CATCH 

END