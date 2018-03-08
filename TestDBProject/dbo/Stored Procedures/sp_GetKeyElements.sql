-- ===========================================================================================
-- Author                         :      Asit
-- Create date                    :      16/10/2015
-- Description                    :      This stored procedure is used for getting Key elements data
-- Execution Process              :      [dbo].[sp_GetKeyElements] '5253'
-- Updated By                     :      
-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_GetKeyElements] 
	 @AdID INT
	--,@MarketID INT
	--,@ProductID INT
AS 
  BEGIN 
      BEGIN TRY 

	  -- Variable declaration
	  DECLARE @RowCount INT,
			  @RowCountCriteria INT,
			  @Condition BIT,
			  @Value NVARCHAR(MAX),
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
			  @ConditionTitle VARCHAR(50)

	  -- Default value assignment to variables
	  SELECT @RowCount = 0,
			 @RowCountCriteria = 0,
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

		-- This table variable will hold KeyElementIds based on Criteria with overall result of TRUE based on identified Conditions.
		DECLARE @ListOfKeyElementID TABLE
		(
			[RowId] [INT] IDENTITY(1,1) NOT NULL,
			[KeyElementID] INT,
			[FK_KETemplateID] INT
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
		FROM RefElementCondition 
		WHERE (ISNULL(ExpireDT,0) = 0 OR ExpireDT > GETDATE())
		and ConditionVariable not like '%TBD%'

		SELECT @RowCount = COUNT(*) FROM @ElementCondition	

		WHILE @RowCount > 0
		BEGIN
			SET @Condition = 0
			SET @Value = ''
			--- Get adlevelvariable 
			SELECT @ConditionTitle = AdLevelVariable FROM @ElementCondition WHERE RowId=@RowCount

			--Identify ALL conditions resulting to TRUE for the Ad
			SELECT @Value= dbo.[fn_GetAllConditionsResultingToTrue](@AdID,@ConditionTitle)
			
			-- Get Condition Operator
			SET @ConditionOperator=(SELECT ConditionOperator FROM @ElementCondition WHERE RowId = @RowCount)
		
			-- Get Condition Variables
			DELETE FROM @ConditionVariable
			INSERT INTO @ConditionVariable(ConditionVariable)
			SELECT ConditionVariable FROM @ElementCondition WHERE RowId = @RowCount
			
			-- Prepare Dynamic Query based on @Value, ConditionOperator and ConditionVariable
			SET @listStr=NULL
			SELECT @listStr = COALESCE(@listStr+',' ,'') + ConditionVariable
			FROM @ConditionVariable
			IF @Value<>''
			BEGIN
			  SET @Value=''''+@Value+''''
			  if @ConditionTitle = 'FirstRunDate'
			      SET @Query ='SELECT @Condition=1 WHERE convert(date,' + @Value + ') ' + @ConditionOperator +' ' + @listStr
			  else
			    begin
			      SET @listStr=REPLACE(@listStr,',',''',''')
			      SET @listStr=''''+@listStr+''''
			      SET @Query ='SELECT @Condition=1 WHERE ' + 'CONVERT(VARCHAR(30),'+CONVERT(VARCHAR(30),@Value)+')'+ ' ' + @ConditionOperator +' (' + @listStr +')'
                end
			  --print @listStr
              --Print @Query
			  EXECUTE sp_executesql  @Query,N'@Condition BIT OUTPUT',@Condition OUTPUT
			END
			--add this ConditionID in the list of met conditions for the Ad

			IF @Condition = 1
			BEGIN
				SELECT @PK_ConditionID=PK_ConditionID FROM @ElementCondition WHERE RowId = @RowCount
				INSERT INTO @ConditionIdList(ConditionID)VALUES(@PK_ConditionID)	
				--PRINT @PK_ConditionID		
			END
			SELECT @RowCount = @RowCount - 1
			
		END	
		
	    --Get all Criteria with overall result of TRUE based on identified Conditions.

		INSERT INTO @ConditionID SELECT * FROM @ConditionIdList
		
		INSERT INTO @CriteriaResultTrue
		(
			[PK_CriteriaID], 
			[NoOfCriteriaConditionID]
		)
		SELECT a.[RefElementCriteriaID], COUNT(b.[ElementCriteriaConditionID]) 
        FROM RefElementCriteria a, [RefElementCriteriaCondition] b 
        WHERE b.[ElementCriteriaID] = a.[RefElementCriteriaID] 
        AND ( (b.[CompoundORInd] = 0 AND b.[ConditionID] IN (SELECT [ConditionID] FROM @ConditionID) 
	    OR  (b.[CompoundORInd] = 1 AND 1=(SELECT dbo.[fn_CheckConditionList](b.ConditionIDList,@ConditionID))))) 
		GROUP BY a.[RefElementCriteriaID]
		
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

		-- Get all saved Key Elements.

		SELECT b.KeyElementName AS KeyElementName,
			b.KElementDataType AS KElementDataType,
			b.MaskFormat AS MaskFormat,
			b.[MultiInd] AS Multiple,
			c.[ReqdInd] AS Required,
			c.DefaultValue AS DefaultValue,
			c.GroupCode AS GroupCode,
			c.DisplayOrder AS DisplayOrder,
			b.SystemName AS SystemName,
			b.ComponentName AS ComponentName,
			a.AnsVarchar AS AnsVarchar,
			a.AnsMemo AS AnsMemo,
			a.AnsNumeric AS AnsNumeric,
			a.AnsTimestamp AS AnsTimestamp,
			a.AnsBoolean AS AnsBoolean,
			a.AnsConfigValue AS AnsConfigValue,
			a.[Active] AS Active,
			b.[RefKeyElementID],
			a.[KETemplateID]
		FROM AdKeyElement a, RefKeyElement b, [RefTemplateElement] c
		WHERE a.[AdID] = @AdID
		AND b.[RefKeyElementID] = a.[KeyElementID]
		AND c.[KETemplateID] = a.[KETemplateID]
		AND c.[KeyElementID] = a.[KeyElementID]
		ORDER BY Active DESC, GroupCode ASC, DisplayOrder ASC
		
		-- Get all Key Elements Ids based on Criteria with overall result of TRUE based on identified Conditions..
		SELECT @CountConditionsForCriteria = COUNT(*) FROM @ConditionsForCriteria
		IF @CountConditionsForCriteria > 0
		BEGIN
		DELETE FROM @ListOfKeyElementID
		INSERT INTO @ListOfKeyElementID(KeyElementID,FK_KETemplateID)
		SELECT DISTINCT b.[KeyElementID],b.[KETemplateID]
		FROM RefElementCriteria a, [RefTemplateElement] b
		WHERE b.[KETemplateID] = a.[KETemplateID]
		AND a.[RefElementCriteriaID] IN (SELECT CriteriaID FROM @ConditionsForCriteria) 
		
		-- Get Corresponding Key Elements for DPF.
		SELECT KE.KeyElementName,KE.KElementDataType,KE.SystemName,KE.[MultiInd] AS Multiple,KE.ComponentName,TE.DefaultValue,TE.DisplayOrder,TE.groupcode,KE.[RefKeyElementID],TE.[KETemplateID] 
		FROM RefKeyElement KE 
		INNER JOIN [RefTemplateElement] TE ON KE.[RefKeyElementID] = TE.[KeyElementID] 
		WHERE KE.[RefKeyElementID] IN (SELECT KeyElementID FROM @ListOfKeyElementID) AND TE.[KETemplateID] IN (SELECT FK_KETemplateID FROM @ListOfKeyElementID)
		AND KE.[RefKeyElementID] NOT IN(SELECT [KeyElementID] FROM AdKeyElement WHERE [AdID]=@AdID) ORDER BY TE.DisplayOrder
	    END
		
      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetKeyElements: %d: %s; %d',16,1,@error,@message,@lineNo); 
		  
      END catch; 

  END;