-- ========================================================================================
-- Author            : Rajkumar Yadav
-- Create date       : 02/11/2016
-- Description       : Get Backup Data for Circular Work Queue 
-- Execution		 : [dbo].[sp_CircularLoadBackupOccurrenceData]  '12/18/2014','02/11/2016','','','',''
-- Updated By		 : 
--===========================================================================================
CREATE PROCEDURE [dbo].[sp_CircularLoadBackupOccurrenceData]
(
@FromDate AS VARCHAR(50)='', 
@ToDate AS VARCHAR(50)='',
@EnvelopeID AS INT,
@MarketID AS INT,
@AdvertiserID AS INT,
@Type AS BIT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @Stmnt AS NVARCHAR(max)='' 
	DECLARE @SelectStmnt AS NVARCHAR(max)='' 
	DECLARE @Where AS NVARCHAR(max)=''	
	
	declare @var1 AS NVARCHAR(100), @var2 AS NVARCHAR(100), @var3 AS NVARCHAR(100), @var4 AS NVARCHAR(100) ,@var5 AS NVARCHAR(100),@var6 AS NVARCHAR(100),@var7 AS NVARCHAR(100)
	
	SELECT @var1 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='NAR'
	SELECT @var2 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='NMAR'
	SELECT @var3 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='NMTMAR'
	SELECT @var4 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='BS'
	SELECT @var5 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='D'
	SELECT @var6 = valuetitle from [Configuration] where systemname='ALL' and  componentname = 'No Take Occurrence' and value='WV'
	SELECT @var7 = b.[Status] 
	from [OccurrenceDetailCIR] a
	inner join OccurrenceStatus b on a.OccurrenceStatusID = b.OccurrenceStatusID
	where a.OccurrenceStatusID = 3 or  a.OccurrenceStatusID = 1 or a.OccurrenceStatusID = 2
	
	
	--	--COALESCE(F.Advertiser,A.NewAdvertiserText) as Advertiser,	--TODO: Belongs in query below but not certain what "Advertiser" maps to.  
	--    set @SelectStmnt='SELECT 
	--	A.OccurrenceDetailCIRID as OccurrenceID,
	--	B.Descrip as MediaType,
	--	C.Descrip as Market,
	--	E.Descrip as Publication,
	--	A.AdDate,
	--	'' as Advertiser,	  
	--	A.[PageCount],
	--	A.EnvelopeID as EnvelopeID,
	--	H.Name as Sender,
	--	A.[Priority], 
	--	CASE
 --       WHEN A.MTIndicator = ''Yes'' AND A.CTIndicator = ''Yes'' THEN   ''Both''
 --       WHEN A.MTIndicator = ''Yes'' AND (A.CTIndicator = ''NULL'' OR A.CTIndicator = ''No'') THEN  ''MT''
 --       WHEN (A.MTIndicator = ''NULL'' OR A.MTIndicator = ''No'') AND A.CTIndicator = ''Yes'' THEN  ''CT''
	--    ELSE ''''
	--	END as BU,
	--	A.NoTakeReason, 
	--	A.CreateBy  as CheckINUser, 
	--	A.CreateDTM as CheckInOn, 
	--	A.ReviewStatus,
	--	A.Headline,
	--	D.EditionName,
	--	A.InternalRefenceNotes   
	--	FROM OccurrenceDetailCIR A 
	--	INNER JOIN MediaType B ON B.PK_MediaTypeID = A.FK_MediaTypeID 
	--	INNER JOIN Market C ON C.MarketID = A.MarketID
	--	INNER JOIN PubEdition D ON D.PK_PubEditionID = A.FK_PubEditionID
	--    INNER JOIN Publication E ON E.PK_PublicationId = D.FK_PublicationId 
	--	INNER JOIN Advertiser F ON F.PK_AdvertiserID = A.FK_AdvertiserID
	--	INNER JOIN ENVELOPE G ON G.PK_EnvelopeId = A.FK_EnvelopeID
	--	INNER JOIN Sender H	ON H.PK_SenderID = G.SenderId'
      
	--	SET @Where=' WHERE (1=1) AND IsQuery <> 1'		   
		  
	--	IF( @FromDate <> '' AND @ToDate <> '' ) 
	--	BEGIN 
	--		SET @Where= @where + ' AND  A.AdDate BETWEEN  '''  + convert(varchar,cast(@FromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@ToDate as date),110) + '''' 	 																		
	--	END 
	--	IF(@MarketID <> -1)
	--	BEGIN
	--		SET @Where =@Where + ' AND A.FK_MarketID ='''+Convert(VARCHAR,@MarketID)+''' AND A.FK_MarketID IS NOT NULL '
	--	END	
	--	IF(@EnvelopeID <> -1)
	--	BEGIN
	--		SET @Where =@Where + ' AND A.FK_EnvelopeID ='''+Convert(VARCHAR,@EnvelopeID)+''' AND A.FK_EnvelopeID IS NOT NULL '
	--	END	
	--	IF(@AdvertiserID <> -1)
	--	BEGIN
	--		SET @Where =@Where + ' AND A.FK_AdvertiserID ='''+Convert(VARCHAR,@AdvertiserID)+''' AND A.FK_AdvertiserID IS NOT NULL '
	--	END			
	--	IF(@Type = 1)
	--	BEGIN
	--		SET @Where =@Where + ' AND  A.NoTakeReason IN ('''+@var1+''','''+@var2+''','''+@var3+''' ) AND  A.NoTakeReason IS NOT NULL '
	--	END			
	--ELSE
	--	BEGIN
	--		SET @Where =@Where + ' AND A.NoTakeReason  IN ('''+@var4+''','''+@var5+''','''+@var6+''' ) AND A.NoTakeReason IS NOT NULL '
	--	END	
						
	--	BEGIN
	--		SET @Where =@Where + ' AND A.OccurrenceStatus ='''+Convert(VARCHAR,@var7)+''' AND A.OccurrenceStatus IS NOT NULL '
	--	END			
	--	SET @Stmnt=@SelectStmnt + @Where 
	--	PRINT @Stmnt 
	--	EXECUTE Sp_executesql @Stmnt 
	END TRY
		BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CircularLoadBackupOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 
END