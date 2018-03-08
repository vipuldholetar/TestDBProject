CREATE PROCEDURE [dbo].[sp_RadioGetOccurrenceList] (@pCreativeId VARCHAR(50), @pSessionDateID int, @pSessionDate varchar(30), @pMarketID int, @pRCSAccountID int, @pLanguageID int) 
AS 
  BEGIN 
      DECLARE @SessionType VARCHAR(50)='' 
      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @Where AS VARCHAR(max)='' 
	  DECLARE @SelectedDate AS VARCHAR(max)='' 

      SET nocount ON; 

      BEGIN try 
	      SET @Where = 'where 1=1 '
		  IF( @pRCSAccountID <> -1 ) 
			SET @Where=@Where + ' and RCSAccountID=' + Cast(@pRCSAccountID AS VARCHAR) 

		  IF( @pMarketID <>- 1 ) 
			SET @Where=@Where + ' and MarketID=' + Cast(@pMarketID AS VARCHAR) 

		  IF( @pLanguageID <>- 1 ) 
		    SET @Where=@Where + ' and LanguageID=' + Cast(@pLanguageID AS VARCHAR) 

		  set @where = @where + ' and RCSCreativeID=''' + @pCreativeID + ''''
      

	      SELECT @SessionType = valuetitle 
          FROM   [Configuration] 
          WHERE  configurationid = @pSessionDateID 

		  IF( @SessionType = 'Last Run Date' ) 
		  BEGIN
			  SET @Where= @where + ' AND LastRunDate='''  + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
			  SET @SelectedDate= ' AND LastRunDate='''      + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
          END

		  IF( @SessionType = 'Create Date' ) 
		  BEGIN
			  SET @Where= @where + ' AND CreateDate='''   + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
			  SET @SelectedDate= ' AND CreateDate='''      + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
		  END	

          SET @Stmnt = 'SELECT STUFF((SELECT  '',''+ cast(occurrenceid as varchar) FROM vw_OccurencesBySessionDate '
		              + @where +' FOR XML PATH(''''), TYPE).value(''.'',''VARCHAR(max)''), 1, 1, '''') as Occurrencelist'

		   PRINT @Stmnt  
		   EXECUTE Sp_executesql  @Stmnt 

	  END try
      BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('sp_RadioGetOccurrenceList: %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END 

