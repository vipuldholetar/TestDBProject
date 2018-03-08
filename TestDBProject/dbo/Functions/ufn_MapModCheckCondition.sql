
-- =========================================================================

-- Author		: Arun Nair

-- Create date	: 01/13/2016

-- Description	: Get MapModCOndition Value

-- Updated By	: select [dbo].[ufn_MapModCheckCondition](27737,'COND1')

--===========================================================================



CREATE FUNCTION [dbo].[ufn_MapModCheckCondition](@Adid  INT,@ConditionCode NVARCHAR(10))

RETURNS bit

AS

BEGIN

		DECLARE @Result AS BIT=0
		DECLARE @AdResult AS BIT=0
		DECLARE @IndustryResult AS BIT=0
		DECLARE @Codelevel AS nvarchar(max)=''
		DECLARE @RowCount AS INT=0
		DECLARE @Counter AS INT=1

		DECLARE  @tempType 	 TABLE
		( 
		  RowId INT IDENTITY(1, 1), 
		  MapType NVARCHAR(MAX)
		) 

		INSERT INTO @tempType SELECT DISTINCT TYPE FROM [dbo].[MapMODCondition] WHERE [ConditionCODE]=@ConditionCode
		SELECT @RowCount = COUNT(*) FROM   @tempType 

		 WHILE (@Counter <= @RowCount)
			BEGIN
		
					SELECT @codelevel=MapType  FROM   @tempType WHERE  RowId = @Counter
					
					IF @Codelevel='Advertiser'
					  BEGIN
						IF EXISTS(SELECT 1 FROM Ad WHERE [AdID]=@adid and [AdvertiserID] IN(SELECT [EntityID] FROM [dbo].[MapMODCondition] WHERE [ConditionCODE]=@ConditionCode and Type=@Codelevel))
							BEGIN
								SET @AdResult=1
								set @Result=1
							END
					  END

					IF @Codelevel='Industry' 
					 BEGIN
						
						IF EXISTS(SELECT 1 FROM ad WHERE [AdID]=@adid and [ClassificationGroupID] IN
						(SELECT [ClassificationGroupID] FROM refindustrygroup where [RefIndustryGroupID] in (select [EntityID] FROM [dbo].[MapMODCondition]
						 WHERE [ConditionCODE]=@ConditionCode and Type=@Codelevel)))
							BEGIN
							   SET @IndustryResult = 1
							   set @Result=1
							END

					  END
				SET @Counter=@Counter+1
			END

			if (@RowCount>1)
			begin
			if (@AdResult=1) and (@IndustryResult=1)
			begin
			set @Result=1
			end
			else
			begin
			set @Result=0
			end
			end
		


			RETURN @Result



END