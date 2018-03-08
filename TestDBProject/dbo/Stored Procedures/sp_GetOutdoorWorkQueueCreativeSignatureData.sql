-- ========================================================================

-- Author		: Arun Nair 
-- Create date	: 07/06/2015
-- Description	: Get Creative Signature Data for Outdoor Work Queue 
-- Updated By	: sp_GetOutdoorWorkQueueCreativeSignatureData 110,'7/29/2015',1
--=========================================================================



CREATE PROCEDURE  [dbo].[sp_GetOutdoorWorkQueueCreativeSignatureData] 
(

@MarketId AS INTEGER ,
@Capturedate  AS VARCHAR(50)='',
@WorkTypeId AS INTEGER
)
AS
BEGIN

		DECLARE @Stmnt AS NVARCHAR(4000)='' 
		DECLARE @SelectStmnt AS NVARCHAR(max)='' 
		DECLARE @Where AS NVARCHAR(max)='' 
		DECLARE @Groupby AS NVARCHAR(max)=''
		DECLARE @Orderby AS NVARCHAR(max)='' 
		
		BEGIN TRY
		
			SET @SelectStmnt='SELECT ScoreQ,ImageFileName As CreativeFileName,Market AS MediaOutlet,
			STUFF((SELECT  '',''+ cast(a.OccurrenceId as varchar)
		    FROM vw_OutdoorWorkQueueSessionData a  WHERE b.OccurrenceId = a.OccurrenceId  FOR XML PATH(''''), TYPE).value(''.'',''VARCHAR(max)''), 1, 1, '''') as Occurrencelist
			 from [dbo].[vw_OutdoorWorkQueueSessionData] b'
			SET @Where=' where (1=1) '

			SET @Where=  @Where + ' AND	MarketId in ('+Convert(VARCHAR,@MarketId)+') 
			AND ( [CreativeStgID] IS NOT NULL) AND (Query is null or Query<>1) AND (Exception is null or Exception<>1) AND (Adid IS NULL)  
			AND ( convert(varchar,cast(Capturedate as date),110)='''+ convert(varchar,cast(@Capturedate as date),110) + ''')
			AND (WorkTypeId='+Convert(Varchar,@WorkTypeId)+')' 

			SET @Orderby= ' Order By ScoreQ Desc'

			SET @Stmnt=@SelectStmnt + @Where +@Orderby
			PRINT @Stmnt 
			EXECUTE SP_EXECUTESQL @Stmnt 

		END TRY
		 BEGIN CATCH 

			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[dbo].[sp_GetOutdoorWorkQueueCreativeSignatureData]: %d: %s',16,1,@error,@message,@lineNo); 
		  END CATCH 



END