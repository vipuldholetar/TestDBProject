-- =============================================
-- Author			:	Asit Kumar Bihari
-- Create date		:	10/30/2015
-- Description		:	Save Key Elements
-- Execution Process: sp_InsertKeyElements 5253,7,'ww','',0,'11/12/2015 12:40:30 PM','True','','False',1,'aa,bb', 1, 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertKeyElements]
(
	@AdID AS INT
	,@KeyElementID AS INT
	,@AnsVarchar AS NVARCHAR(max)
	,@AnsMemo AS NVARCHAR(max)
	,@AnsNumeric AS DECIMAL
	,@AnsTimestamp AS DATETIME
	,@AnsBoolean AS BIT
	,@AnsConfigValue AS VARCHAR(50)
	,@ActiveIndicator AS BIT
	,@KETemplateID AS INT
	,@AnsListValue As NVARCHAR(max)
	,@TarketMarketID AS INT
	,@ProductID AS INT
)
AS
BEGIN
	 BEGIN TRY
	 BEGIN TRANSACTION
	 DECLARE @tblMultiValues AS TABLE
		   (
			itemValue VARCHAR(MAX)
		   )
		   IF EXISTS(SELECT 1 FROM RefKeyElement WHERE [RefKeyElementID]=@KeyElementID AND [MultiInd]=1 AND KElementDataType IN ('ListofValues','Varchar')) 
		   BEGIN
		    DELETE FROM AdKeyElement WHERE [AdID]=@AdID AND [KeyElementID] = @KeyElementID AND [KETemplateID]=@KETemplateID
		   END

	 IF NOT EXISTS(SELECT 1 FROM AdKeyElement WHERE [AdID]=@AdID AND [KeyElementID] = @KeyElementID AND [KETemplateID]=@KETemplateID)
	  BEGIN
	  print @AnsConfigValue
	   if LEN(@AnsConfigValue) > 0
	   BEGIN
		   
		   INSERT INTO @tblMultiValues(itemValue) SELECT itemText FROM dbo.[fn_CSVStringToTable](@AnsConfigValue)

		   INSERT INTO AdKeyElement([AdID],[KeyElementID],AnsVarchar,AnsMemo,AnsNumeric,AnsTimestamp,AnsBoolean,AnsConfigValue,[Active],[KETemplateID]) 
		   SELECT  @AdID,@KeyElementID,@AnsVarchar,@AnsMemo,@AnsNumeric,@AnsTimestamp,@AnsBoolean,itemValue,@ActiveIndicator,@KETemplateID FROM @tblMultiValues
		   
	   END

	   ELSE if LEN(@AnsListValue) > 0
	   BEGIN
		   
		   INSERT INTO @tblMultiValues(itemValue) SELECT itemText FROM dbo.[fn_CSVStringToTable](@AnsListValue)
		   select * from @tblMultiValues
		   INSERT INTO AdKeyElement([AdID],[KeyElementID],AnsVarchar,AnsMemo,AnsNumeric,AnsTimestamp,AnsBoolean,AnsConfigValue,[Active],[KETemplateID]) 
		   SELECT  @AdID,@KeyElementID,itemValue,@AnsMemo,@AnsNumeric,@AnsTimestamp,@AnsBoolean,@AnsConfigValue,@ActiveIndicator,@KETemplateID FROM @tblMultiValues

	   END

	   ELSE
	   BEGIN
			INSERT INTO AdKeyElement([AdID],[KeyElementID],AnsVarchar,AnsMemo,AnsNumeric,AnsTimestamp,AnsBoolean,AnsConfigValue,[Active],[KETemplateID]) 
			VALUES(@AdID,@KeyElementID,@AnsVarchar,@AnsMemo,@AnsNumeric,@AnsTimestamp,@AnsBoolean,@AnsConfigValue,@ActiveIndicator,@KETemplateID)
	   END
		
	  END
	 ELSE
	 BEGIN	 
		UPDATE AdKeyElement 
		SET [AdID]=@AdID,[KeyElementID]=@KeyElementID,AnsVarchar=@AnsVarchar,AnsMemo=@AnsMemo,
			AnsNumeric=@AnsNumeric,AnsTimestamp=@AnsTimestamp,AnsBoolean=@AnsBoolean,AnsConfigValue=@AnsConfigValue,
			[Active]=@ActiveIndicator,[KETemplateID]=@KETemplateID
		WHERE [AdID]=@AdID AND [KeyElementID] = @KeyElementID AND [KETemplateID]=@KETemplateID
	 END

	 --UPDATE AD SET MarketID = @TarketMarketID, ProductID = @ProductID WHERE AdID = @AdID

	COMMIT TRANSACTION	
		
	END TRY

	BEGIN CATCH
	ROLLBACK TRANSACTION
		 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		  RAISERROR ('sp_InsertKeyElements: %d: %s',16,1,@error,@message,@lineNo); 		
	END CATCH
		
END