-- =================================================================================================================================
-- Author               : Ramesh Bangi
-- Create date          : 07/15/2015
-- Description          : Get Exception Queue Data
-- Execution Process    : [sp_ExceptionQueueSearchData] 'ALL','','9/14/2015','3/6/2016',0,29712030
-- Updated By           : Karunakar on 7th Sep 2015
--                      : Arun Nair on 10/14/2015 - MI-229 On Reset Exception Change Status to "Resolved w/o Further Action"
--                      : Suman  on 01/25/2016 - Added PreFixedExceptionId 
-- Execute				: EXEC [dbo].[sp_ExceptionQueueSearchData] 'Radio','','12/1/2015','1/5/2016',0,29712221
-- =================================================================================================================================
CREATE PROCEDURE [dbo].[sp_ExceptionQueueSearchData] --'Radio','','12/1/2015','1/5/2016',0,29712221
(
	@MediaStream NVARCHAR(MAX),
	@CreativeSignature NVARCHAR(MAX),
	@RaisedFrom DATE,
	@RaisedTo DATE,
	@IncludeResolved Bit,
    @UserId As Integer
) 
AS
BEGIN                                             
	BEGIN TRY 
		DECLARE @Stmnt AS NVARCHAR(4000) = '', @SelectStmnt AS NVARCHAR(max) = '', @Where AS NVARCHAR(max) = '', 
			@Groupby AS NVARCHAR(max) = '', @Orderby AS NVARCHAR(max) = ''
		IF(@MediaStream <> 'ALL')
		BEGIN
			SET @MediaStream = REPLACE((@MediaStream), ',' , ''',''')
			SET @MediaStream = '''' + @MediaStream + ''''
		END
		SET @SelectStmnt = 'SELECT Mediastream, MediaStreamId, [CreativeSignature], [AdId], [OccurrenceId], [ExceptionType], [ExceptionStatus], [RaisedBy], 
							CONVERT(NVARCHAR(10), [RaisedOn], 101) AS [RaisedOn], AssignedTo, CONVERT(NVARCHAR(10), [Age]) AS Age, ExceptionId, languageid,
							(''E'' + CONVERT(VARCHAR(10), ExceptionId)) AS PreFixedExceptionId, advertiserid, LanguageName, KeyId,
							CASE WHEN a.AssignedTo IS NOT NULL THEN (SELECT dbo.GetLocationForUser(a.assignedtouserid))
							ELSE (SELECT dbo.GetLocationForUser(a.userid)) END AS Location, UserID                                                                            
							FROM vw_ExceptionQueueSearchData a'
		SET @Where = ' WHERE (1 = 1) and validrows = 1 '
                           
		IF(@MediaStream <> NULL OR (@MediaStream <> 'ALL'))
		BEGIN
			SET @Where = @Where + ' AND Mediastream IN (' + @MediaStream + ')'
		END
		ELSE
		BEGIN
			SET @Where = @Where + ' AND Mediastreamid IN (SELECT MediaStream FROM UserMediaStream where UserID = ' + CONVERT(VARCHAR, @UserId) + ')'
		END
		IF(@CreativeSignature <> '')
		BEGIN
			SET @Where = @Where + ' AND CreativeSignature = ''' + CONVERT(NVARCHAR(MAX), @CreativeSignature) + ''''
		END    
		IF(@RaisedFrom <> '' AND @RaisedTo <> '' ) 
		BEGIN
			SET @Where = @where + ' AND RaisedOn BETWEEN  ''' + CONVERT(VARCHAR, CAST(@RaisedFrom AS DATE), 110) + ''' AND ''' + CONVERT(VARCHAR, CAST(@RaisedTo AS DATE), 110) + '''' 
		END 
		IF(@IncludeResolved = 0) 
		BEGIN
			SET @Where = @where + ' AND ((ExceptionStatus is null) OR (ExceptionStatus <> ''Resolved'') AND  (ExceptionStatus <> ''Resolved w/o Further Action'') AND  (ExceptionStatus <> ''Resolved  No Take''))'
		END
		SET @Stmnt = @SelectStmnt + @Where + @Groupby 
		--PRINT @Stmnt 
		EXECUTE SP_EXECUTESQL @Stmnt 
	END TRY
	BEGIN CATCH
		DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_ExceptionQueueSearchData]: %d: %s', 16, 1, @error, @message, @lineNo); 
	END CATCH
END