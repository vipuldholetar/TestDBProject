
CREATE PROCEDURE [dbo].[Sp_radiogetoccurrencesadvertiserdata] 
--'',1,'06/12/2015',1,-1,-1  
(@pWorkType NVARCHAR(50)='',@pSessionDateID INT,@pSessionDate NVARCHAR(100), 
@pLanguageID INT,@pMarketID INT,@pRCSAccountID INT) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @SessionType VARCHAR(50) = '' 
      DECLARE @Stmnt AS NVARCHAR(4000) = '' 
      DECLARE @SelectStmnt AS NVARCHAR(max) = '' 
      DECLARE @Where AS NVARCHAR(max) = '' 
      DECLARE @Groupby AS NVARCHAR(max) = '' 
      DECLARE @Orderby AS NVARCHAR(max) = '' 

      BEGIN try 
          SELECT @SessionType = valuetitle 
          FROM   [Configuration] 
          WHERE  configurationid = @pSessionDateID 

          SET @SelectStmnt = 
'Select RCSAccount AS AccountName, COUNT(Distinct RCSCreativeID) AS CreativeSignatureCount, COUNT(RCSCreativeID) AS OccurrenceCount,                     TotalQScore, RCSAccountID  FROM vw_OccurencesBySessionDate'
    SET @Groupby = ' GROUP BY RCSAccount, TotalQScore, RCSAccountID, Advertiser' 
    SET @Orderby = 
    ' ORDER BY TotalQScore DESC, OccurrenceCount DESC, Advertiser DESC' 
    SET @Where = 
' WHERE (1 = 1)  AND (Isexception IS NULL OR Isexception <> 1) AND (IsQuery IS NULL OR IsQuery <> 1)'

    IF( @SessionType = 'Last Run Date' ) 
      BEGIN 
          SET @Where = @where + ' AND LastRunDate = ''' 
                       + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
      END 

    IF( @SessionType = 'Create Date' ) 
      BEGIN 
          SET @Where= @where + ' AND CreateDate = ''' 
                      + CONVERT(VARCHAR, @pSessionDate, 110) + '''' 
      END 

    IF( @pMarketID <>- 1 ) 
      BEGIN 
          SET @Where = @Where + ' AND MarketID = ' 
                       + Cast(@pMarketID AS VARCHAR) 
      END 

    IF( @pLanguageID <>- 1 ) 
      BEGIN 
          SET @Where = @Where + ' AND LanguageID = ' 
                       + Cast(@pLanguageID AS VARCHAR) 
      END 

    IF( @pRCSAccountID <>- 1 ) 
      BEGIN 
          SET @Where = @Where + ' AND RCSAccountID = ' 
                       + Cast(@pRCSAccountID AS VARCHAR) 
      END 

    SET @Stmnt = @SelectStmnt + @Where + @Groupby + @Orderby 

    EXECUTE Sp_executesql 
      @Stmnt 
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(),@message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('sp_RadioGetOccurrencesAdvertiserData: %d: %s',16,1,@error, 
                   @message,@lineNo); 
    END catch 
END
