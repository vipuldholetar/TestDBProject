CREATE PROCEDURE [dbo].[sp_TaglineMaintenanceSearch] 
 @SeachXML AS XML

AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 
	 
		  DECLARE @RefTaglineID AS INT
		  DECLARE @AdvertiserID AS INT
		  DECLARE @AdvertiserCode AS NVARCHAR(100)
		  DECLARE @AdvertiserName AS NVARCHAR(100)
		  DECLARE @Tagline AS NVARCHAR(1000)
		  DECLARE @Display  AS INT
		  DECLARE @SelectStmnt AS NVARCHAR(MAX)=''
		  DECLARE @Where AS NVARCHAR(MAX)
		  DECLARE @OrderBy AS NVARCHAR(250)='' 

		  SET @Where = ''
		  SET @OrderBy = ' ORDER BY Tagline ASC'

		  SELECT taglinesearchdetails.value('(RefTaglineID)[1]','INT') AS 'RefTaglineID', 
				taglinesearchdetails.value('(AdvertiserID)[1]','INT') AS 'AdvertiserID', 
				taglinesearchdetails.value('(AdvertiserCode)[1]','NVARCHAR(100)') AS 'AdvertiserCode', 
				taglinesearchdetails.value('(AdvertiserName)[1]','NVARCHAR(100)') AS 'AdvertiserName', 
				taglinesearchdetails.value('(Tagline)[1]','NVARCHAR(1000)') AS 'Tagline', 
				taglinesearchdetails.value('(Display)[1]', 'NVARCHAR(2)') AS 'Display'
		  INTO   #searchtempval
		  FROM   @SeachXML.nodes('TaglineMaintenanceSearch') AS TaglineSearchProc(taglinesearchdetails) 

		  SELECT @RefTaglineID = RefTaglineID, 
				@AdvertiserID = AdvertiserID,
				@AdvertiserCode = AdvertiserCode,
				@AdvertiserName = AdvertiserName,
				@Tagline = Tagline,
				@Display = CASE WHEN LTRIM(RTRIM(Display)) = 'Y' THEN 1 ELSE 0 END
		  FROM   #searchtempval 
		  
		  SET @SelectStmnt='SELECT RefTaglineID, t.AdvertiserID, a.CTLegacyINSTCOD as AdvertiserCode,
					    a.Descrip as AdvertiserName, Tagline, CASE WHEN t.Display = 1 THEN ''Y'' ELSE ''N'' END AS Display,
					   CONVERT(VARCHAR(15), T.CreatedDT, 101) AS CreatedDT, u.Username as CreatedBy, 
					   CONVERT(VARCHAR(15), T.ModifiedDT, 101) AS ModifiedDT, 
					   (SELECT CONVERT(VARCHAR(15), MAX(lastrundate), 101) AS MaxDate FROM Ad WHERE Taglineid = t.RefTaglineID)
					   FROM RefTagline t LEFT JOIN Advertiser a on t.AdvertiserID = a.AdvertiserID 
					   LEFT JOIN [user] u on t.CreateByID = u.UserID
					   WHERE 1=1 '

		  IF( @AdvertiserCode <> '') 
			 SET @SelectStmnt=@SelectStmnt + ' AND a.CTLegacyINSTCOD like ''%' + REPLACE(@AdvertiserCode,'''','''''') + '%''' 
		  IF( @AdvertiserName <> '') 
			 SET @SelectStmnt=@SelectStmnt + ' AND a.Descrip like  ''%'+ REPLACE(@AdvertiserName,'''','''''') + '%''' 
		  IF( @Tagline <> '')
			 SET @SelectStmnt=@SelectStmnt   + ' AND t.Tagline like  ''%'+ REPLACE(@Tagline,'''','''''') + '%''' 
		  
		  SET @SelectStmnt = @SelectStmnt + @OrderBy

		  DROP TABLE #searchtempval 
		  PRINT @SelectStmnt 
		  EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 

	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_TaglineMaintenanceSearch: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END