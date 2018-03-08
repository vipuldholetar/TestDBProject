	-- ===========================================================================================
	-- Author                         :      Asit
	-- Create date                    :      16/10/2015
	-- Description                    :      This stored procedure is used for getting Key elements data
	-- Execution Process              :      [dbo].[sp_GetKeyElements_CriteriaList]'0','0','5','',0,'0','0',''
	-- Updated By                     :      
	-- ============================================================================================

	---Advertiserid,advertisername,categoryid,subcategory,mediastream,firstrundate,industry group,maarket 

	CREATE PROCEDURE [dbo].[sp_GetKeyElements_CriteriaList] 
		@MediaStreamID INT,
		@IndustryGroupID INT,
		@AdvertiserID INT,	
		@AdvertiserName VARCHAR(50),
		@CategoryID INT,
		@SubCategoryID INT,
		@MarketID INT,
		@FirstRunDate DATETIME
	AS 
	  BEGIN 
		  BEGIN TRY 

		  -- Variable declaration
			DECLARE @RowCountCriteria INT,
				  @Condition BIT,
				  @Value VARCHAR(20),
				  @ConditionOperator VARCHAR(10),
				  @Query NVARCHAR(MAX),
				  @listStr VARCHAR(MAX),
				  @CountCriteriaConditionID INT,
				  @CountConditionsForCriteria INT,
				  @FK_CriteriaID INT,
				  @PK_ConditionID INT,
				  @PK_CriteriaID INT,
				  @CriteriaTitle VARCHAR(50),
				  @RowCountConditionsForCriteria INT,
				  @ConditionID ConditionIdListData,
				  @ConditionTitle VARCHAR(50),
				  @RowCount INT

		  -- Default value assignment to variables
			SELECT @RowCountCriteria = 0,
				 @Condition=0,
				 @Value = '',
				 @ConditionOperator = '',
				 @Query = '',
				 @listStr=NULL,
				 @CountCriteriaConditionID= 0,
				 @CountConditionsForCriteria= 0,
				 @FK_CriteriaID = 0,
				 @PK_ConditionID = 0,
				 @PK_CriteriaID = 0,
				 @CriteriaTitle = '',
				 @RowCountConditionsForCriteria =0,
				 @ConditionTitle = ''

			-- This  table variable will hold Element  conditions during condition  check
			DECLARE @ElementCondition TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,		  
				[PK_ConditionID] INT,
				[ConditionTitle] VARCHAR(MAX),
				[AdLevelVariable] VARCHAR(MAX),
				[ConditionOperator] VARCHAR(MAX),
				[ConditionVariable] VARCHAR(MAX),
				[ExpireDT] DATETIME	 
			);

			-- This  table variable will hold Criteria with overall result of TRUE based on identified Conditions.
			DECLARE @CriteriaResultTrue TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,		  
				[PK_CriteriaID] INT, 
				[NoOfCriteriaConditionID] INT
			);

			-- This table variable will hold ConditionID in the list of met conditions for the Ad
			DECLARE @ConditionIdList TABLE
			(
				[ConditionID] VARCHAR(10)
			);

			DECLARE @ConditionIdsToTest TABLE
			(
			   [RowId] [INT] IDENTITY(1,1) NOT NULL,
			   [ConditionId] INT
			);

			-- This table variable will hold KeyElementIds based on Criteria with overall result of TRUE based on identified Conditions.
			DECLARE @ListOfKeyElementID TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,
				[KeyElementID] INT
			);

			-- This table variable will hold the condition variable for the condition.
			DECLARE @ConditionVariable  TABLE
			(
				[ConditionVariable] VARCHAR(MAX)
			);

			-- Store all the CriteriaIDs matched with all the conditions.
			DECLARE @ConditionsForCriteria TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,
				[CriteriaID] INT
			);
	
			-- Get all condition lists.
			INSERT INTO @ElementCondition
			(
				[PK_ConditionID],
				[ConditionTitle],
				[AdLevelVariable],
				[ConditionOperator],
				[ConditionVariable],
				[ExpireDT]
			)
			SELECT DISTINCT 
				[RefElementConditionID],
				[ConditionTitle],
				[AdLevelVariable],
				[ConditionOperator],
				[ConditionVariable],
				[ExpireDT]
			FROM RefElementCondition WHERE ISNULL(ExpireDT,0) = 0 OR ExpireDT > GETDATE()

			-- Checking for Media Stream.
			IF @MediaStreamID > 0
			BEGIN		
				SELECT @Condition=0
				SET @ConditionTitle = 'All Media Stream'
				SET @Value = CONVERT(VARCHAR(10),@MediaStreamID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' +  @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'	
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END

				-- Checking for TV Media Stream
				SELECT @Condition=0
				SET @ConditionTitle = 'TV Media Stream'
				SET @Value = CONVERT(VARCHAR(10),@MediaStreamID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'		
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)
			
				END
			END

			-- Checking for Industry Group.
			IF @IndustryGroupID > 0
			BEGIN
				SELECT @Condition=0
				SET @ConditionTitle = 'Industry Group'
				SET @Value = CONVERT(VARCHAR(10),@IndustryGroupID)
				-- Begin Alan's changes 20160802
				DELETE FROM @ConditionIdsToTest
				INSERT INTO @ConditionIdsToTest
				SELECT PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%' 

				SELECT @RowCount = count(*) FROM @ConditionIdsToTest
				WHILE @RowCount > 0
				BEGIN
				    SET @Value = CONVERT(VARCHAR(10),@IndustryGroupID)
					-- Get Condition Operator
					--SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE @ConditionTitle + '%')
					--SET @ConditionOperator = (SELECT ConditionOperator FROM @ElementCondition join @ConditionIdsToTest c on ConditionID = PK_ConditionID WHERE c.RowId = @RowCount)

					-- Get Condition Variables
					--DELETE FROM @ConditionVariable
					--INSERT INTO @ConditionVariable(ConditionVariable)
					--SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE @ConditionTitle + '%'
		
					-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
					SET @listStr=NULL
					--SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
					--FROM @ConditionVariable
					--SET @listStr=REPLACE(@listStr,',',''',''')
					--SET @listStr=''''+@listStr+''''
					select @PK_ConditionID = PK_ConditionID, @ConditionOperator = ConditionOperator, @listStr = '''' + REPLACE(ConditionVariable,',',''',''') + ''''
					from @ElementCondition join @ConditionIdsToTest c on ConditionID = PK_ConditionID 
					WHERE c.RowId = @RowCount

					IF @Value<>''
					BEGIN
					SET @Value=''''+@Value+''''
					SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'

					--Executes dynamic query to check the condition
					
					EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
					END		

					--add this ConditionID in the list of met conditions for the Ad

					IF @Condition = 1
					BEGIN
						--SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE @ConditionTitle + '%'
						INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
					END
					SET @RowCount = @RowCount - 1
				END -- Alan's while loop
			END
		
			-- Checking for Advertiser.
			IF @AdvertiserID > 0
			BEGIN
				SELECT @Condition=0
				SET @ConditionTitle = 'Advertiser for Senior Citizen'
				SET @Value = CONVERT(VARCHAR(10),@AdvertiserID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE @ConditionTitle + '%')
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''
				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'
				--Executes dynamic query to check the condition

				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END

				-- Checking for Theme Advertiser1
				SELECT @Condition=0
				SET @ConditionTitle = 'Theme Advertiser 1'
				SET @Value = CONVERT(VARCHAR(10),@AdvertiserID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		
				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END

				-- Checking for Theme Advertiser2
				SELECT @Condition=0
				SET @ConditionTitle = 'Theme Advertiser 2'
				SET @Value = CONVERT(VARCHAR(10),@AdvertiserID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' +  @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'	
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)
			
				END
			END
		
			-- Checking for Category.
			IF @CategoryID > 0
			BEGIN		
				SELECT @Condition=0
				SET @ConditionTitle = 'Prod Category for Senior Citizen'
				SET @Value = CONVERT(VARCHAR(10),@CategoryID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'		
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END	

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END

				-- Checking for Prod Category For Theme
				SELECT @Condition=0
				SET @ConditionTitle = 'Prod Category for Theme'
				SET @Value = CONVERT(VARCHAR(10),@CategoryID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'		
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		
				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)
			
				END
			END		

			-- Checking for BCBS Advertiser
			IF @AdvertiserName <> ''
			BEGIN		
				SELECT @Condition=0
				SET @ConditionTitle = 'BCBS Advertiser'
				SET @Value = CONVERT(VARCHAR(10),@AdvertiserName)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'		
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END
			END

			-- Checking for Theme Target Market
			IF @MarketID > 0
			BEGIN		
				SELECT @Condition=0
				SET @ConditionTitle = 'Theme Target Market'
				SET @Value = CONVERT(VARCHAR(10),@MarketID)
				-- Get Condition Operator
				SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%')
		
				-- Get Condition Variables
				DELETE FROM @ConditionVariable
				INSERT INTO @ConditionVariable(ConditionVariable)
				SELECT ConditionVariable FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
		
				-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
				SET @listStr=NULL
				SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
				FROM @ConditionVariable
				SET @listStr=REPLACE(@listStr,',',''',''')
				SET @listStr=''''+@listStr+''''

				IF @Value<>''
				BEGIN
				SET @Value=''''+@Value+''''
				SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(varchar(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'		
				EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
				END		

				--add this ConditionID in the list of met conditions for the Ad

				IF @Condition = 1
				BEGIN
					SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE ConditionTitle LIKE '%' + @ConditionTitle + '%'
					INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)			
				END
			END

		
			--Get all Criteria with overall result of TRUE based on identified Conditions.

			INSERT INTO @ConditionID SELECT * FROM @ConditionIdList
		
			INSERT INTO @CriteriaResultTrue
			(
				[PK_CriteriaID], 
				[NoOfCriteriaConditionID]
			)
			SELECT a.[CriteriaID], COUNT(b.[ElementCriteriaConditionID]) 
			FROM ElementCriteria a, [RefElementCriteriaCondition] b 
			WHERE b.[ElementCriteriaID] = a.[CriteriaID] 
			AND ( (b.[CompoundORInd] = 0 AND b.[ConditionID] IN (SELECT [ConditionID] FROM @ConditionID) 
			OR  (b.[CompoundORInd] = 1 AND 1=(select dbo.[fn_CheckConditionList](b.ConditionIDList,@ConditionID))))) 
			GROUP BY a.[CriteriaID]
		
			-- Get all Criteria for met conditions
			SELECT @RowCountCriteria = COUNT(*) FROM @CriteriaResultTrue

			WHILE @RowCountCriteria > 0
			BEGIN
			SELECT @FK_CriteriaID = PK_CriteriaID, @CountCriteriaConditionID = NoOfCriteriaConditionID FROM @CriteriaResultTrue WHERE RowId = @RowCountCriteria

			IF @CountCriteriaConditionID = (SELECT COUNT(*) FROM [RefElementCriteriaCondition] WHERE [ElementCriteriaID] = @FK_CriteriaID)  -- this means all conditions for the criteria were met.
		
			BEGIN
			-- <add this CriteriaID in the list of met Criteria for the Ad>
			INSERT INTO @ConditionsForCriteria(CriteriaID) VALUES(@FK_CriteriaID)

			END
			SELECT @RowCountCriteria = @RowCountCriteria - 1
			END
		
			-- Get all Key Elements Ids based on Criteria with overall result of TRUE based on identified Conditions..
			SELECT @CountConditionsForCriteria = COUNT(*) FROM @ConditionsForCriteria
			WHILE @CountConditionsForCriteria > 0
			BEGIN
			DELETE FROM @ListOfKeyElementID
			INSERT INTO @ListOfKeyElementID(KeyElementID)
			SELECT DISTINCT b.[KeyElementID]
			FROM ElementCriteria a, [RefTemplateElement] b
			WHERE b.[KETemplateID] = a.[KETemplateID]
			AND a.[CriteriaID] IN (SELECT CriteriaID FROM @ConditionsForCriteria WHERE RowId=@CountConditionsForCriteria)
		
			-- Get Corresponding Key Elements for DPF.
			--SELECT KE.KeyElementName,KE.KElementDataType,KE.ComponentName,TE.DefaultValue,TE.DisplayOrder,TE.groupcode FROM RefKeyElement_Test KE 
			--INNER JOIN RefTemplateElements_test TE ON KE.PK_KeyElementID = TE.FK_KeyElementID 
			--WHERE KE.PK_KeyElementID IN (SELECT KeyElementID FROM @ListOfKeyElementID) ORDER BY TE.DisplayOrder

			SELECT KE.KeyElementName,KE.KElementDataType,KE.ComponentName,TE.DefaultValue,TE.DisplayOrder,TE.groupcode FROM RefKeyElement KE 
			INNER JOIN [RefTemplateElement] TE ON KE.[RefKeyElementID] = TE.[KeyElementID] 
			WHERE KE.[RefKeyElementID] IN (SELECT KeyElementID FROM @ListOfKeyElementID) ORDER BY TE.DisplayOrder

			SELECT @CountConditionsForCriteria = @CountConditionsForCriteria - 1
			END

		  END TRY  --select * from RefKeyElement_Test    select * from RefKeyElement     select * from RefTemplateElements_test   select * from RefTemplateElements

		  BEGIN CATCH 

			  DECLARE @error   INT,
					  @message VARCHAR(4000), 
					  @lineNo  INT 

			  SELECT @error = Error_number(), 
					 @message = Error_message(), 
					 @lineNo = Error_line() 

			  RAISERROR ('sp_GetKeyElements_CriteriaList: %d: %s',16,1,@error,@message,@lineNo); 
		  
		  END catch; 

	  END;