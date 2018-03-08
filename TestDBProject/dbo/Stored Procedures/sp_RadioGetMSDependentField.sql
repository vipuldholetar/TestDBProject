-- =========================================================================
-- Author			: 
-- Create date		:
-- Description		: 
-- Execution Process: [sp_RadioGetMSDependentField] "444"
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMT DB 
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_RadioGetMSDependentField]--'M2005705-20440997'
@creativesignature varchar(max),
@MarketOutletValue Varchar(Max)
AS
BEGIN	
	SET NOCOUNT ON;
		DECLARE @SQL AS VARCHAR(MAX) 
		BEGIN TRY	
					
			SET @SQL=' SELECT [occurrenceid],[CreateDate] AS FirstRundate,[LastRunDate] As LastRundate,[AirStartDT],[AirEndDT],[Length],[Market]As FirstRunDMA
				 FROM [dbo].[vw_OccurencesBySessionDate] a 
				 where occurrenceid=(select min(occurrenceid) from [vw_OccurencesBySessionDate] where [RCSCreativeID]= '''+ @creativesignature+ ''')'
			 
			IF (@MarketOutletValue <>'' OR @MarketOutletValue <> NULL)
			Begin
			SET @SQL=@SQL + ' AND A.Market= '''+ @MarketOutletValue + ''''
			End

			EXECUTE (@SQl)
  
		END TRY

		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_RadioGetMSDependentField: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
	
END