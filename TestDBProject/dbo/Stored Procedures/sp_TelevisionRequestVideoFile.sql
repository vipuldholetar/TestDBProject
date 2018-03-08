-- =============================================
-- Author:		Lisa East
-- Create date:	November 16,2017
-- Description:	Delete occurrencedetailtv record for a selected occurrence to request and return IN files details to re-pull video requested
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionRequestVideoFile]
	@OccurrenceID int, 
	@RequestorID as int, 
	@PRCODE as varchar(Max)
AS
BEGIN
    SET NOCOUNT ON;

	
    BEGIN TRY
		DECLARE @PATH AS VARCHAR(max)
		Declare @databasename varchar(25)
		DECLARE @Deletedcount int;  
		EXEC @Deletedcount = [sp_TelevisionDeletecreativedetailstagingtv] @OccurrenceID, '';  
 

		SELECT @databasename =db_name() 
	--IF @Deletedcount>0 
	--BEGIN 
		SELECT @PATH= ValueTitle 
		FROM  Configuration 
		WHERE value='VR'
		
		SET @PATH=@PATH+ '\' + convert (varchar(max),@PRCode) + '.IN'

		DECLARE @sql   VARCHAR(MAX)
		Set  @sql='EXEC   master..xp_cmdshell''bcp "Select o.PRCode, s.StationShortName, convert(char(9),o.AirDT,11) as AirDT , convert(varchar(9), o.AirTime, 108) as AirTime, o.AdLength,'+convert (varchar(30),@RequestorID)+' From  '+ convert (varchar(30),@databasename)+'.dbo.OccurrenceDetailTV o INNER JOIN  '+ convert (varchar(30),@databasename)+'.dbo.TVStation s on o.StationID = s.TVStationID	Where o.OccurrenceDetailTVID = '+ convert (varchar(30),@OccurrenceID) +'" queryout "' +convert (varchar(max),	@PATH) +'" -c -T'''
		print @sql
		execute (@sql)
		
		--Select @path, o.PRCode, s.StationShortName, cast(o.AirDT as date) as AirDT , o.AirTime, o.AdLength, @RequestorID
		--From OccurrenceDetailTV o 
		--INNER JOIN TVStation s on o.StationID = s.TVStationID
		--Where o.OccurrenceDetailTVID = @OccurrenceID
	--END 

	
    END  TRY
    BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		  RAISERROR ('[sp_TelevisionRequestVideoFile]: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH
END