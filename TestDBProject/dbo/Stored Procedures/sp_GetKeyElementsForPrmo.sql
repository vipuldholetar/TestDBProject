CREATE PROCEDURE [dbo].[sp_GetKeyElementsForPrmo] 
	 @CatID INT
	-- @CorpID int
	--,@MarketID INT
	--,@ProductID INT
AS 
  BEGIN 
      BEGIN TRY 

	  -- Variable declaration
	  DECLARE @RowCount INT,
			  @RowCountCriteria INT,
			  @RowCountKeyElement INT,
			  @Condition BIT,
			  @Value NVARCHAR(MAX),
			  @ConditionOperator VARCHAR(10),
			  @Query NVARCHAR(MAX),
			  @listStr VARCHAR(MAX),
			  @CountCriteriaConditionID INT,
			  @CountConditionsForCriteria INT,
			  @FK_KeyTemplateID INT,
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
			
			 @PK_ConditionID = 0,
			 @PK_CriteriaID = 0,
			 @CriteriaTitle = '',
			 @RowCountConditionsForCriteria =0,
			 @ConditionTitle = ''

		-- This  table variable will hold Element  conditions during condition  check

		DECLARE @ElementCategory TABLE
		(
			[RowId] [INT] IDENTITY(1,1) NOT NULL,		  
			[FK_CategoryGroupId] INT,
			[FK_KETemplateID] VARCHAR(MAX),
			[CategoryName] VARCHAR(MAX)
			
		);


	

		-- This table variable will hold KeyElementIds based on Criteria with overall result of TRUE based on identified Conditions.
		DECLARE @ListOfKeyElementID TABLE
		(
			[RowId] [INT] IDENTITY(1,1) NOT NULL,
			[KeyElementID] INT,
			[FK_KETemplateID] INT
		);
		-- Get all condition lists.
	    INSERT INTO @ElementCategory
		(
			[FK_CategoryGroupId] ,
			[FK_KETemplateID] ,
			[CategoryName] 
		)
		SELECT DISTINCT 
			[CategoryGroupID],
			[KETemplateID],
			[CategoryName]
		FROM RefCategory where [RefCategoryID] = @CatID

		SELECT @RowCount = COUNT(*) FROM @ElementCategory	

		WHILE @RowCount > 0
		BEGIN
			SET @Condition = 0
			SET @Value = ''
			--- Get Templateid
			SELECT @FK_KeyTemplateID = [FK_KETemplateId] FROM @ElementCategory WHERE RowId=@RowCount
			
			INSERT INTO @ListOfKeyElementID
			(
			[KeyElementID],
			[FK_KETemplateID] 
			)
			select [KETemplateID] as TemplateId,[KeyElementID] from [RefTemplateElement] WHERE [KETemplateID]=@FK_KeyTemplateID
			
			SELECT @RowCount = @RowCount - 1
			
		END	

		SELECT [KeyElementName],[KElementDataType],[RefKeyElementID],[MultiInd],[MaskFormat],[SystemName],[ComponentName],PromoDetail.*,@FK_KeyTemplateID as TemplateId
		FROM RefKeyElement KE left join (SELECT pd1.* FROM PromotionDetail pd1 LEFT JOIN PromotionDetail pd2
		ON (pd1.KeyElementID = pd2.KeyElementID AND pd1.PromotionDetailID < pd2.PromotionDetailID) WHERE pd2.PromotionDetailID IS NULL ) AS PromoDetail ON
		KE.RefKeyElementID = PromoDetail.KeyElementID
		WHERE KE.[RefKeyElementID] IN (SELECT distinct [FK_KETemplateID] FROM @ListOfKeyElementID)

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_GetKeyElementsForPrmo: %d: %s',16,1,@error,@message,@lineNo); 
		  
      END catch; 

  END;