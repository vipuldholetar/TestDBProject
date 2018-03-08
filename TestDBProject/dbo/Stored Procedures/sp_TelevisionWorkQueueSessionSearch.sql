-- ================================================================================================================
-- Author      : Arun Nair    
-- Create date    : 07/08/2015  
-- Description    : Get Creative Signature Data,OccurrenceCount for Television Work Queue   
--Execution      : [dbo].[sp_TelevisionWorkQueueSessionSearch]  'ALL','-1',-1,0,1,'5/31/2015','12/7/2015',4 
-- Updated By    : Karunakar on 11th September 2015,Removing Priority in Selection  
--          : Karunakar on 14th Sep 2015 
--            Arun Nair on 12/02/2015 - Added Ethnicity filter  
--          : Karunakar on 7th December 2015,Adding Ethnicity Filter Selection Check 
--          : Arun Nair on 01/20/2016 - Changed NVARCHAR to VARCHAR 
--=================================================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueSessionSearch] 
--'ALL','-1',-1,0,1,'5/31/2015','12/7/2015',2 
(@CityUniverse     AS VARCHAR(max), 
 @Industry         AS VARCHAR(max), 
 @pLanguageID      AS INT, 
 @Infomercial      AS BIT, 
 @Threshold        AS BIT, 
 @pSessionFromDate AS VARCHAR(30), 
 @pSessionToDate   AS VARCHAR(30), 
 @pEthnicity      AS INT) 
AS 
  BEGIN 
      SET nocount ON; 
      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @CityUniverseTemp AS VARCHAR(max)='' 
      DECLARE @IndustryTemp AS VARCHAR(max)='' 
      IF( @CityUniverse <> 'ALL' ) 
        BEGIN 
            SET @CityUniverse=Replace(( @CityUniverse ), ',', ''',''') 
            SET @CityUniverse= '''' + @CityUniverse + '''' 
            PRINT @CityUniverse 
        END 
      SET @Industry=Replace(( @Industry ), ',', ''',''') 
      SET @Industry= '''' + @Industry + '''' 
      --PRINT @Industry 
      ------------------------------------------------------------------- 
      SET @CityUniverseTemp='''-1''' 
      --PRINT @CityUniverseTemp 
      SET @IndustryTemp='''-1''' 
      --PRINT @IndustryTemp 
      BEGIN try 
          SET @SelectStmnt= 
'SELECT  WorkType,City,convert(varchar(10),FirstAirDate,101) AS FirstAirDate , Count(distinct CreativeSignatureCount) AS CreativeSignatureCount ,
Count(OccurrenceDetailTVID) AS OccurrenceCount,TVOccurrenceThreshold, TotalQScore,MarketID,WorkTypeId from [dbo].[vw_TelevisionWorkQueueSessionData] ' 
    SET @Where= 
' WHERE (1=1) and (IsException is  null or IsException=0) and   (QAndA is  null or QAndA=0)  '
    SET @Groupby= 
' GROUP BY WorkType,City,convert(varchar(10),FirstAirDate,101),TotalQScore,MarketID,WorkTypeId,TVOccurrenceThreshold'
    IF( @CityUniverse = 'ALL' ) 
      BEGIN 
          SET @Where= @Where + ' AND [PRCODE] IS NOT NULL' 
      END 
    ELSE 
      BEGIN 
          SET @Where= @Where + ' AND CITY in (' + @CityUniverse 
                      + ') AND [PRCODE] IS NOT NULL' 
      END 
/*
    IF( @pLanguageID <>- 1 ) 
      BEGIN 
          SET @Where=@Where + ' AND LanguageID = ' 
                     + Cast(@pLanguageID AS VARCHAR) 
      END 
    ELSE 
      BEGIN 
          SET @Where=@Where 
                     + 
' AND LanguageID IN (SELECT LanguageID FROM Language where EthnicGroupID = ''' 
           + Cast(@pEthnicity AS VARCHAR) + ''')' 
END
*/ 
    IF( @pSessionFromDate <> '' 
AND @pSessionToDate <> '' ) 
      BEGIN 
          SET @Where= @where 
                      + ' AND cast(FirstAirDate as date) BETWEEN  ''' 
                      + CONVERT(VARCHAR, Cast(@pSessionFromDate AS DATE), 101) 
					  --+  Cast(@pSessionFromDate AS DATE )
                      + ''' AND  ''' 
               + CONVERT(VARCHAR, Cast(@pSessionToDate AS DATE), 101) 
					  --+ Cast(@pSessionToDate AS DATE)
                      + '''' 
      END 
    IF( @Infomercial = 1 ) 
      BEGIN 
          SET @Where= @where + ' AND  Priority=4 ' 
      END 
   ELSE 
      BEGIN 
          SET @Where= @where + ' AND  Priority <> 4 ' 
      END 
    SET @Orderby = @Orderby + ' ORDER  BY FirstAirDate desc' 
    SET @Stmnt=@SelectStmnt + @Where + @Groupby 
    IF( @Threshold = 0 ) 
      BEGIN 
          SET @Stmnt= 'SELECT * FROM (' + @Stmnt 
                      + ') a where occurrencecount <=tvoccurrencethreshold' 
                      + @Orderby 
          EXECUTE Sp_executesql 
            @Stmnt 
          PRINT @Stmnt 
      END 
    ELSE 
      BEGIN 
          SET @Stmnt = @Stmnt + @Orderby 
          EXECUTE Sp_executesql 
            @Stmnt 
          PRINT @Stmnt 
      END 
END try 
    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 
        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 
        RAISERROR ('[sp_TelevisionWorkQueueSessionSearch]: %d: %s',16,1,@error, 
                   @message,@lineNo); 
    END catch 
END