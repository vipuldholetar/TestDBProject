-- ==========================================================================================================
-- Author			: Arun Nair
-- Create date		: 08/03/2015
-- Description		: Get Query Queue Data
-- Execution Process: [sp_QueryQueueSearchData] 'CINEMA','','12/18/2015','01/22/2016',29712030,0
-- Updated BY		: Arun nair on 08/19/2015 for Location,Assignedto,Assignedby
--					: Suman on 01/25/2016 - Added PreFixedQueryId
-- ========================================================================================================



CREATE PROCEDURE [dbo].[sp_QueryQueueSearchData]
(
	@MediaStream			NVARCHAR(MAX),
	@CreativeSignature		NVARCHAR(MAX),
	@RaisedFrom				NVARCHAR(MAX),
	@RaisedTo				NVARCHAR(MAX),
	@UserId					BIGINT,
	@IncludeQueryAnswers	BIT
)
AS
BEGIN
	BEGIN TRY 
		DECLARE @Stmnt AS NVARCHAR(4000) = '', @SelectStmnt AS NVARCHAR(MAX) = '', @Where AS NVARCHAR(MAX) = '', 
			@Groupby AS NVARCHAR(MAX) = '', @Orderby AS NVARCHAR(MAX) = '' 
		IF(@MediaStream <> 'ALL')
		BEGIN
			SET @MediaStream = REPLACE((@MediaStream), ',', ''', ''')
			SET @MediaStream = ''''+@MediaStream+''''
		END 
		PRINT @MediaStream
		SET @Orderby = 'ORDER BY MediaStream, Age'
		SET @SelectStmnt = 'SELECT MediaStream, MediaStreamId, CreativeSignature, QueryCategory, QueryCategoryID, RaisedBy,
							 (Convert(VARCHAR(10),RaisedOn,101)) AS RaisedOn, Answer,
							CASE WHEN a.AnsweredBy IS NULL THEN a.AssignedTo ELSE a.AnsweredBy END AS AssignedTo,
							(Convert(VARCHAR(10),AnsweredOn,101)) AS AnsweredOn, Age, KeyID, LanguageId, Language, Advertiser, 
							AdvertiserId, (''Q'' + CONVERT(VARCHAR(10), QueryId)) AS PreFixedQueryId, 
							QueryId, OccurrenceId,QueryText,
							CASE WHEN AssignedTo IS NOT NULL THEN (SELECT dbo.GetLocationForUser(a.assignedtouserid))
							ELSE (SELECT dbo.GetLocationForUser(a.UserId)) END AS Location, UserID
							FROM vw_QueryQueue a'
		SET @Where=' where (1 = 1)'
		IF(@MediaStream <> NULL OR (@MediaStream <> 'ALL'))
		BEGIN
			IF @MediaStream LIKE '%Publication%'
			BEGIN
				DECLARE @PubMediastream AS NVARCHAR(MAX)
				SET @PubMediastream = 'ISS'
				SET @Where = @Where + ' AND Mediastream IN (' + @MediaStream + ') OR Mediastream IN (''' + @PubMediastream + ''')'
			END
			ELSE
			BEGIN
				SET @Where = @Where + ' AND Mediastream IN (' + @MediaStream + ') '
			END
		END	
		ELSE
		BEGIN
			SET @Where = @Where + ' AND Mediastreamid IN (select MediaStream from UserMediaStream where UserID = ' +  CONVERT(VARCHAR, @UserId) + ')'
		END	
		IF(@CreativeSignature <> '')
		BEGIN
			SET @Where = @Where + ' AND CreativeSignature=''' + CONVERT(NVARCHAR(MAX), @CreativeSignature) + ''''
		END
		IF( @RaisedFrom <> '' AND @RaisedTo <> '' )
			BEGIN
			--SET @Where= @where + ' AND CONVERT(VARCHAR,CAST(RaisedOn as date),110)
			SET @Where = @where + ' AND CAST(RaisedOn as DATE) BETWEEN  '''	+ CONVERT(VARCHAR, CAST(@RaisedFrom AS DATE), 110) + ''' AND  ''' 
						+ CONVERT(VARCHAR,CAST(@RaisedTo AS DATE), 110) + '''' 
			END 
		IF(@IncludeQueryAnswers = 0)
		BEGIN
			SET @Where = @Where + ' AND Answer Is Null '
		END
		SET @Stmnt = @SelectStmnt + @Where + @Orderby 
		PRINT @Stmnt 
		EXECUTE SP_EXECUTESQL @Stmnt 
	END TRY
	BEGIN CATCH
			DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_QueryQueueSearchData]: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH
END