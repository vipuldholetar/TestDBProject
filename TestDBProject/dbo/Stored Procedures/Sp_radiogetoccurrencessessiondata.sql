-- ================================================================================================================
-- Author      : Karunakar   
-- Create date    : 04/01/2015   
-- Description    : This stored procedure is used to fill the Data in Radio Work Queue SessionList Data  
-- Execution Process: [sp_RadioGetOccurrencesSessionData]  1,1,-1,'05/24/2015','01/24/2016',-1
-- Updated By    : Arun Nair on 01/20/2016 - Changed NVARCHAR to VARCHAR   
-- =================================================================================================================
CREATE PROCEDURE [dbo].[Sp_radiogetoccurrencessessiondata] (@pSessionDateID INT, 
@pLanguageID INT,@pMarketID INT,@pSessionFromDate VARCHAR(50) = '', 
@pSessionToDate VARCHAR(50) = '',@pRCSAccountID INT) 
AS 
  BEGIN 
      SET nocount ON; 
      DECLARE @Stmnt AS NVARCHAR(4000) = '' 
      DECLARE @SessionType VARCHAR(50) = '' 
      DECLARE @SelectStmnt AS VARCHAR(max) = '' 
      DECLARE @Where AS VARCHAR(max) = '' 
      DECLARE @Groupby AS VARCHAR(max) = '' 
      DECLARE @Orderby AS VARCHAR(max) = '' 
      BEGIN try 
          SELECT @SessionType = valuetitle 
          FROM   [Configuration] 
          WHERE  configurationid = @pSessionDateID 
          SET @Where = 
' where (1=1)  AND (Isexception IS NULL OR Isexception <>1) AND (IsQuery IS NULL OR IsQuery <>1)'
    IF( @SessionType = 'Last Run Date' ) 
      BEGIN 
          SET @SelectStmnt = 
'Select WorkType, LastRunDate AS SessionDate, Count(distinct RCSCreativeID) AS CreativeCount, Count(RCSCreativeID) AS OccurrenceCount, TotalQScore from vw_OccurencesBySessionDate'
    SET @Groupby = ' GROUP BY worktype, LastRunDate, TotalQScore' 
    IF( @pSessionFromDate <> '' 
        AND @pSessionToDate <> '' ) 
      BEGIN 
          SET @Where = @where 
                       + ' AND CAST(LastRunDate AS DATE) >= ''' 
                       + CONVERT(VARCHAR, Cast(@pSessionFromDate AS DATE), 101 ) 
                       + ''' AND CAST(LastRunDate AS DATE) <= ''' 
                       + CONVERT(VARCHAR, Cast(@pSessionToDate AS DATE), 101) 
                       + '''' 
      END 
	  SET @Orderby = ' ORDER BY WorkType DESC, LastRunDate DESC'
END 
ELSE IF( @SessionType = 'Create Date' ) 
  BEGIN 
      SET @SelectStmnt = 
'Select WorkType, CreateDate AS SessionDate, Count(distinct RCSCreativeID) AS CreativeCount, Count(occurrenceid) AS OccurrenceCount,TotalQScore from vw_OccurencesBySessionDate'
    SET @Groupby = ' GROUP BY worktype, CreateDate, TotalQScore' 
    IF( @pSessionFromDate <> '' 
        AND @pSessionToDate <> '' ) 
      BEGIN 
          SET @Where = @where 
                       + ' AND CAST(CreateDate AS DATE) >= ''' 
                       + CONVERT(VARCHAR, Cast(@pSessionFromDate AS DATE), 101) 
                       + ''' AND CAST(CreateDate AS DATE) <= ''' 
                       + CONVERT(VARCHAR, Cast(@pSessionToDate AS DATE), 101) 
                       + '''' 
      END 
    SET @Orderby=' Order By WorkType DESC, CreateDate DESC' 
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
--SET @Groupby = ' GROUP BY worktype, LastRunDate, TotalQScore' 
--SET @Orderby = ' ORDER BY WorkType DESC, LastRunDate DESC' 

SET @Stmnt = @SelectStmnt + @Where + @Groupby + @Orderby 
PRINT @Stmnt 
EXECUTE Sp_executesql @Stmnt 

END try 
    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 
        SELECT @error = Error_number(),@message = Error_message(), 
               @lineNo = Error_line() 
        RAISERROR ('sp_RadioGetOccurrencesSessionData: %d: %s',16,1,@error, 
                   @message, 
                   @lineNo); 
    END catch 
END