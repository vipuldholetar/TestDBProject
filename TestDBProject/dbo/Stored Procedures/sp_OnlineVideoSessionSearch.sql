
-- ====================================================================================  
-- Author            : Ramesh Bangi   
-- Create date       : 9/18/2015  
-- Description       : Get Session Data for Online Video Work Queue   
-- Execute           : [sp_OnlineVideoSessionSearch] 1,'','',''  
-- Updated By        :                                  
--=====================================================================================  
CREATE PROCEDURE [dbo].[sp_OnlineVideoSessionSearch] (@LanguageId  AS INT, 
                                                     @MediaOutlet AS VARCHAR( 
max), 
                                                     @CaptureFrom AS VARCHAR( 
max), 
                                                     @CaptureTo   AS VARCHAR( 
max)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @MediaStream AS VARCHAR(max) 

      --DECLARE @CSCountStmnt AS NVARCHAR(MAX)  
      BEGIN try 
          SELECT @MediaStream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'ALL' 
                 AND componentname = 'Media Stream' 
                 AND valuetitle = 'Online Video' 

          SET @SelectStmnt= 
' SELECT    WorkType,CaptureDate,Count(distinct CreativeSignature) AS CreativeSignatureCount,TotalQScore,LanguageId FROM [dbo].[vw_OnlineVideoWorkQueueSessionData] ' 
    SET @Where=' WHERE (1=1) AND  MediaStream=''' 
               + @MediaStream + '''' 

    IF( @LanguageId IS NOT NULL ) 
      BEGIN 
          SET @Where=@where + ' AND [LanguageId]=' 
                     + CONVERT(VARCHAR, @LanguageId) + '' 
      END 

    IF( @MediaOutlet <> '' ) 
      BEGIN 
          SET @Where=@where + ' AND MediaOutlet=' 
                     + CONVERT(VARCHAR, @MediaOutlet) + '' 
      END 

    IF( @CaptureFrom <> '' 
        AND @CaptureTo <> '' ) 
      BEGIN 
          SET @Where= @where 
                      + ' AND Convert(DATE,CaptureDate) Between  ''' 
                      + CONVERT(VARCHAR, Cast(@CaptureFrom AS DATE), 101) 
                      + ''' AND  ''' 
                      + CONVERT(VARCHAR, Cast(@CaptureTo AS DATE), 101) 
                      + '''' 
      END 

    SET @Groupby=' GROUP BY WorkType,CaptureDate,TotalQScore,LanguageId' 
    SET @Orderby=' Order BY WorkType ASC, CaptureDate DESC ' 
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

        RAISERROR ('[sp_OnlineVideoSessionSearch]: %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END
