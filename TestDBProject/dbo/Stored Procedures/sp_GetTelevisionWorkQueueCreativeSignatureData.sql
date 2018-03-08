CREATE Procedure [dbo].[sp_GetTelevisionWorkQueueCreativeSignatureData]( 
@Marketcode As VARCHAR(50),@Worktypeid As INTEGER,@Languageid As INTEGER, 
@Industryid As INTEGER,@Firstairdate As VARCHAR(30),@Priority As BIT, 
@Pethinicity As INT) 
As 
  Begin 
      Declare @Stmnt As NVARCHAR(4000)='' 
      Declare @Selectstmnt As VARCHAR(Max)='' 
      Declare @Countcsstmnt As VARCHAR(Max)='' 
      Declare @Where As VARCHAR(Max)='' 
      Declare @Groupby As VARCHAR(Max)='' 
      Declare @Orderby As VARCHAR(Max)='' 
      Declare @Checkexqueryqna As VARCHAR(Max)='' 
      Declare @Marketid As INT=0 

      Begin Try 
          -- Below statementTo be removed and optimized. Market ID should be passed as parameter from code
          Select @Marketid = [MarketID] 
          From   [Market] 
          Where  [Descrip] = @Marketcode 

          Set @Firstairdate=Convert(DATE, @Firstairdate) 
          Set @Checkexqueryqna = 
  ' AND (IsException is null or isexception=0) and (QAndA is null or QAndA=0)' 
  --Check for Exception,Query,QandA  
  Set @Countcsstmnt='COUNT(b.OccurrenceDetailTVID) AS OccurrenceCount'
 --Get Count of Occurrence fora Creative  
Set @Where=' where (1=1) ' 

If( @Firstairdate <> '' ) -- Filter for Firstairdate   
  Begin 
      Set @Where=@Where + ' AND FirstAirDate =''' 
                 + @Firstairdate + '''' 
      End 

Set @Selectstmnt='SELECT ScoreQ,PRCODE,' + @Countcsstmnt 
                 + 
', min(b.OccurrenceDetailTVID) as Occurrencelist, MediaOutlet,MarketId,WorkTypeId from [dbo].[vw_TelevisionWorkQueueSessionData] b ' 

--Append the OccurrenceCount Statement with Main Statement       
If( @Marketid <> 0 ) -- Filter for market code   
  Begin 
      Set @Where= @Where + ' AND  MarketId=' 
                  + Convert(VARCHAR, @Marketid) + '' 
  End 

If( @Worktypeid <> 0 ) -- Filter for Work Type   
  Begin 
      Set @Where= @Where + ' AND  WorkTypeId=' 
                  + Convert(VARCHAR, @Worktypeid) + '' 
  End 
/*
If( @Languageid <>- 1 ) -- Filter for Language   
  Begin 
      Set @Where=@Where + ' AND LanguageID = ' 
                 + Convert(VARCHAR, @Languageid) 
  End 
Else 
  Begin 
      Set @Where=@Where 
                 + 
' AND LanguageID IN (sELECT LanguageID FROM Language where EthnicGroupID = ''' 
       + Cast(@Pethinicity As VARCHAR) + ''')' 
End 
*/
If( @Priority = 1 ) 
  Begin 
      Set @Where= @Where + ' and  Priority=4 ' 
  End 
Else 
  Begin 
      Set @Where= @Where + ' and  Priority <> 4 ' 
  End 

Set @Where=@Where + @Checkexqueryqna -- Append for Exception and Query  
Set @Groupby =' GROUP BY ScoreQ,PRCODE,Mediaoutlet,MarketId,WorkTypeId' 
--Group By Columns  
Set @Stmnt=@Selectstmnt + @Where + @Groupby 

Print @Stmnt 

Execute Sp_executesql 
  @Stmnt 
End Try 

    Begin Catch 
        Declare @Error   INT, 
                @Message VARCHAR(4000), 
                @Lineno  INT 

        Select @Error = Error_number(),@Message = Error_message(), 
               @Lineno = Error_line() 

        Raiserror ( 
        '[dbo].[sp_GetTelevisionWorkQueueCreativeSignatureData]: %d: %s' 
        ,16,1,@Error, 
        @Message,@Lineno); 
    End Catch 
End