
-- ====================================================================================   
-- Author            : Ramesh Bangi    
-- Create date       : 09/30/2015   
-- Description       : Get Session Data for Mobile Work Queue    
-- Execute           : [sp_MobileSessionSearch] 1,'','Ingestion','01/31/2015','03/6/2016'    
-- Updated By        :  CAPTURE DATE UPDATED                                 
--=====================================================================================   
CREATE PROCEDURE [dbo].[Sp_mobilesessionsearch] (@LanguageId AS INT,@MediaOutlet 
AS VARCHAR(max),@WorkType AS VARCHAR(max),@CaptureFrom AS VARCHAR(30),@CaptureTo 
AS VARCHAR(30)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @MediaStream AS VARCHAR(3) 

      IF( @WorkType <> 'Both' ) 
        BEGIN 
            SET @WorkType=Replace(( @WorkType ), ',', ''',''') 
            SET @WorkType= '''' + @WorkType + '''' 

            PRINT @WorkType 
        END 

      BEGIN try 
          SELECT @MediaStream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'ALL' 
                 AND componentname = 'Media Stream' 
                 AND valuetitle = 'Mobile' 

          SET @SelectStmnt= 
' SELECT    WorkType,CONVERT(VARCHAR,CAST(CaptureDate AS DATE),101) AS CaptureDate,Count(distinct CreativeSignature) AS CreativeSignatureCount,TotalQScore,LanguageId FROM [dbo].[vw_MobileWorkQueueSessionData] ' 
    SET @Where=' WHERE (1=1) AND  MediaStream=''' 
               + @MediaStream + '''' 

    IF( @LanguageId IS NOT NULL ) 
      BEGIN 
          SET @Where=@where + ' AND [LanguageId]=' 
                     + CONVERT(VARCHAR, @LanguageId) + '' 
      END 

    IF( @MediaOutlet <> 'ALL' AND @MediaOutlet <> '' ) 
      BEGIN 
          SET @Where=@where + ' AND MediaOutlet=''' + CONVERT(VARCHAR, @MediaOutlet) + '''' 
      END 

    IF( @WorkType <> 'Both' ) 
      BEGIN 
          SET @Where= @Where + ' AND WorkType in (' + @WorkType + ')' 
      END 

    IF( @CaptureFrom <> '' 
        AND @CaptureTo <> '' ) 
      BEGIN 
          SET @Where= @where 
                      + ' AND CAST(CaptureDate AS DATE) Between  ''' 
                      + CONVERT(VARCHAR, Cast(@CaptureFrom AS DATE), 110) 
                      + ''' AND  ''' 
                      + CONVERT(VARCHAR, Cast(@CaptureTo AS DATE), 110) 
                      + '''' 
      --  SET @Where= @where + ' AND castCaptureDate as date) Between  ''' + CAST(@CaptureFrom AS DATE) + ''' AND  '''   + CAST(@CaptureTo AS DATE) + '''' 
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

        SELECT @error = Error_number(),@message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('[sp_MobileSessionSearch]: %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END