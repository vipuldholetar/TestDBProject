
-- ==============================================================================================================
-- Author		: Arun Nair  
-- Create date  : 04/02/2015 
-- Description  : This stored procedure is used to fill the Data in Radio Work Queue CreativeSignatureList
-- Execution	: [sp_RadioGetOccurrencesCSData] 337939,1,'08/18/2015',1,-1 
-- Updated By	: Arun Nair on 08/21/2015 for Occurrence Count,Creative list 
-- Updated By	: Arun Nair on 01/20/2016 - Changed NVARCHAR to VARCHAR 
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_RadioGetOccurrencesCSData] (@pRCSAccountID  INT, 
                                                      @pSessionDateID INT, 
                                                      @pSessionDate   AS VARCHAR 
(30), 
                                                      @pLanguageID    INT, 
                                                      @pMarketID      INT) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @SessionType VARCHAR(50)='' 
      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @DateWhere AS VARCHAR(max)='' 
      DECLARE @SelectedDate AS VARCHAR(max)='' 

      BEGIN try 
          SELECT @SessionType = valuetitle 
          FROM   [Configuration] 
          WHERE  configurationid = @pSessionDateID 

          SET @Where= 
' where (1=1) and (Isexception IS NULL OR Isexception <>1) and (IsQuery IS NULL OR IsQuery <>1)'
    SET @DateWhere= 
'(select COUNT(RCSCreativeID) cnt from vw_OccurencesBySessionDate a where b.RCSCreativeID = a.RCSCreativeID     and a.marketid=b.marketid and (Isexception IS NULL OR Isexception <>1) and (IsQuery IS NULL OR IsQuery <>1) '
    SET @Orderby=' Order By OccurrenceCount DESC' 

    IF( @pRCSAccountID <> -1 ) 
      BEGIN 
          SET @Where=@Where + ' and RCSAccountID=' 
                     + Cast(@pRCSAccountID AS VARCHAR) 
      END 

    IF( @SessionType = 'Last Run Date' ) 
      BEGIN 
          SET @Where= @where + ' AND LastRunDate=''' 
                      + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
          SET @DateWhere= @DateWhere + ' AND LastRunDate=''' 
                          + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
          SET @SelectedDate=' AND LastRunDate=''' 
                            + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
      END 

    IF( @SessionType = 'Create Date' ) 
      BEGIN 
          SET @Where= @where + ' AND CreateDate=''' 
                      + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
          SET @DateWhere= @DateWhere + ' AND CreateDate=''' 
                          + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
          SET @SelectedDate=' AND CreateDate=''' 
                            + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
      END 

    IF( @pMarketID <>- 1 ) 
      BEGIN 
          SET @Where=@Where + ' and MarketID=' 
                     + Cast(@pMarketID AS VARCHAR) 
      END 

    IF( @pLanguageID <>- 1 ) 
      BEGIN 
          SET @Where=@Where + ' and LanguageID=' 
                     + Cast(@pLanguageID AS VARCHAR) 
      END 

    SET @SelectStmnt= 'SELECT RCSCreativeID AS CreativeSignature,market as MediaOutlet ,''NA'' as ScoreQ,'
	                  -- comment the following two lines as the OccurrenceList logic has been moved to stored procedure sp_RadioGetOccurrenceList for performance improvements.
					  -- + 'STUFF((SELECT  '',''+ cast(a.occurrenceid as varchar), IsException as IsException FROM vw_OccurencesBySessionDate a WHERE b.RCSCreativeID = a.RCSCreativeID and a.marketid=b.marketid    AND (Isexception IS NULL OR Isexception <>1) ' 
                      -- + @SelectedDate  + ' FOR XML PATH(''''), TYPE).value(''.'',''VARCHAR(max)''), 1, 1, '''') as Occurrencelist,' 
                      -- + @DateWhere 
                  + ' count(*) OccurrenceCount,  Market AS DMA, MarketID  FROM vw_OccurencesBySessionDate b' 

    SET @Groupby = ' group by RCSCreativeID, MarketID, Market '
    SET @Stmnt=@SelectStmnt + @Where + @Groupby + @Orderby 

    --PRINT @Stmnt  
    EXECUTE Sp_executesql 
      @Stmnt 
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('sp_RadioGetOccurrencesCSData: %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END