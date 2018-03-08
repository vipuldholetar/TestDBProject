
-- =======================================================================================  
-- Author    : Ramesh Bangi    
-- Create date  :  9/30/2015   
-- Description  : Get Creative Signature Data for Mobile Work Queue    
-- Execution  : [dbo].[sp_MobileCSData]  1,'','Ingestion','10/25/2015'   
-- Updated By  :    
--        : Karunakar on 30th Nov 2015,Removing Selection of Minimum OccurrenceID.   
--========================================================================================== 
CREATE PROCEDURE [dbo].[Sp_mobilecsdata] (@LanguageId AS INTEGER,@MediaOutlet 
VARCHAR(max),@WorkType VARCHAR(200),@CaptureDate VARCHAR(30)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @CSOccCntStmnt AS VARCHAR(max)='' 

      IF( @WorkType <> 'Both' ) 
        BEGIN 
            SET @WorkType=Replace(( @WorkType ), ',', ''',''') 
            SET @WorkType= '''' + @WorkType + '''' 

            PRINT @WorkType 
        END 

      BEGIN try 
          --SET @CSOccCntStmnt='(SELECT COUNT(a.OccurrenceId) as OccurrenceCount From  [dbo].[vw_MobileWorkQueueSessionData] a Where a.CreativeSignature=b.CreativeSignature ' --AND a.MarketId=b.MarketId '     
          SET @Where=' where (1=1) ' 

          IF( @CaptureDate IS NOT NULL ) 
            BEGIN 
                SET @Where= @Where 
                            + ' AND	 CAST(CaptureDate AS DATE)=''' 
                            + CONVERT(VARCHAR, Cast(@CaptureDate AS DATE), 110) 
                            + '''' 
            --SET @CSOccCntStmnt=@CSOccCntStmnt + ' AND CaptureDate ='''+ Convert(varchar,@CaptureDate) + ''') AS OccurrenceCount' 
            END 

          SET @SelectStmnt= 
'SELECT ScoreQ,CreativeSignature,MediaOutlet,COUNT(b.OccurrenceId) as OccurrenceCount,''''  AS Occurrencelist   FROM [dbo].[vw_MobileWorkQueueSessionData] b' 

    IF( @LanguageId IS NOT NULL ) 
      BEGIN 
          SET @Where= @Where + ' AND	LanguageId= ' 
                      + CONVERT(VARCHAR, @LanguageId) + '' 
      END 

    IF( @MediaOutlet <> '' ) 
      BEGIN 
          SET @Where= @Where + ' AND	MediaOutlet= ''' 
                      + CONVERT(VARCHAR, @MediaOutlet) + '''' 
      --SET @CSOccCntStmnt=@CSOccCntStmnt+ ' AND MediaOutlet= '''+Convert(NVARCHAR,@MediaOutlet)+''''
      END 

    IF( @WorkType = 'Both' ) 
      BEGIN 
          SET @Where= @Where 
                      + ' AND WorkType=''Ingestion'' OR WorkType=''Adhoc''' 
      END 
    ELSE 
      BEGIN 
          SET @Where= @Where + ' AND WorkType in (' + @WorkType + ')' 
      END 

    SET @Groupby= ' GROUP BY CreativeSignature,ScoreQ,MediaOutlet ' 
    --,MediaOutlet'   
    SET @Orderby='Order By CreativeSignature ASC' 
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

        RAISERROR ('[dbo].[sp_MobileCSData] : %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END
