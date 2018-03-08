
-- ============================================= 
-- Author    : Arun Nair  
-- Create date  : 07/03/2015 
-- Description  : Get Session Data for Outdoor Work Queue  
-- Updated By  :   
-- Execute    :sp_OutdoorWorkQueueSessionSearch '-1' 
--         sp_OutdoorWorkQueueSessionSearch '1,2,3' 
-- Updated by  : suresh on 20/01/2016 -changed Nvarchar to Varchar 
--=================================================== 
CREATE PROCEDURE [dbo].[sp_OutdoorWorkQueueSessionSearch] (@MarketIdlist AS 
VARCHAR(max)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @MarketlistTemp AS VARCHAR(max)=' ' 

      --------Make Suitable Marketlist appending single quote------------------------------------- 
      SET @MarketIdlist=Replace(( @MarketIdlist ), ',', ''',''') 
      SET @MarketIdlist= '''' + @MarketIdlist + '''' 

      PRINT @MarketIdlist 

      ------------------------------------------------------------------- 
      SET @MarketlistTemp='''-1''' 

      PRINT @MarketlistTemp 

      BEGIN try 
          SET @SelectStmnt= 
          'SELECT WorkType,Market,Convert(varchar(12),CaptureDate,101) As CaptureDate,Count(ImageFileName) AS CreativeCount, TotalQScore,MarketId,  WorkTypeId from [dbo].[vw_OutdoorWorkQueueSessionData]  ' 
          SET @Where=' where (1=1) ' 
          SET @Groupby= 
' GROUP BY Market,WorkType,Convert(varchar(12),CaptureDate,101),TotalQScore,MarketId,WorkTypeId'
    SET @Orderby=' Order BY WorkType ASC,CaptureDate DESC ' 

    IF( @MarketIdlist = @MarketlistTemp ) 
      BEGIN 
          SET @Where= @Where 
                      + 
' AND [CreativeStgID] IS NOT NULL  AND (Query is null or Query<>1) AND (Exception is null or Exception<>1) AND Adid IS NULL'
END 
ELSE 
  BEGIN 
      SET @Where= @Where + ' AND MarketId in (' + @MarketIdlist 
                  + 
') AND [CreativeStgID] IS NOT NULL AND Query<>1 AND Exception<>1 AND Adid IS NULL'
END 

    SET @Stmnt=@SelectStmnt + @Where + @Groupby + @Orderby 

    PRINT @Stmnt 

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

        RAISERROR ('[sp_OutdoorWorkQueueSessionSearch]: %d: %s',16,1,@error, 
                   @message 
                   ,@lineNo); 
    END catch 
END