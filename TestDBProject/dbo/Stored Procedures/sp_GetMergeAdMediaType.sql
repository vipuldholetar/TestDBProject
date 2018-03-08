CREATE PROCEDURE [dbo].[sp_GetMergeAdMediaType]
		@OccurrenceList varchar(200)
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY

		DECLARE @MediaType VARCHAR(200)
		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'SELECT @MediaType = ''Email'' FROM OccurrenceDetailEM WHERE OccurrenceDetailEMID in (' + @OccurrenceList + ')'
		
		exec sp_executesql @SQL, N'@MediaType varchar(100) out', @MediaType out
	    

		IF LEN(@MediaType) > 0
			SELECT @MediaType
		ELSE
			SELECT 'Radio'
						
		END TRY
		BEGIN CATCH
		   DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_GetMergeAdMediaType]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
		END CATCH
  
END