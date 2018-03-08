
-- =============================================   
-- Author:    Nagarjuna   
-- Create date: 07/09/2015   
-- Description: Loads the data from TV Playlist file to database table.  
-- Query :   
/*  
exec sp_TVInsertPlaylistFileData '',  
*/ 
-- =============================================   

CREATE PROCEDURE [dbo].[sp_TVInsertPlaylistFileData] (@TVPLData dbo.TVPLData readonly) 
AS 
  BEGIN 
     -- SET nocount ON; 
      BEGIN TRY 
        BEGIN TRANSACTION 
		DECLARE  @count INT,
			 @FileName VARCHAR(200),
			 @DeleteCount INT

			

			SET @FileName =  (SELECT DISTINCT([InputFileName]) FROM @TVPLData)
			SET @DeleteCount = 0;

			-- Insert playlist records into RawTVPlaylist table if the file is not re-export scenario.
			INSERT INTO  [dbo].[RawTVPlaylist]([InputFileName], [CaptureStationCODE], [AirDateTime], [CaptureTime], 
												[Length],[PatternCODE], [CreatedDT], [IngestionDT],[IngestionStatus], [Station] )

			SELECT [InputFileName], [CaptureStationCode], [AirDateTime], [CaptureTime], [Length], 
					[PatternCode], [CreateDTM], [IngestionDTM],[IngestionStatus], [Station]

			FROM @TVPLData			

			SELECT  @count =  Count(*) FROM @TVPLData	
			INSERT INTO [TVIngestionLog](SrcFileName, [OccurrencesCountInFile], [OccurrencesDeleted], [FileSkippedFor0024] , [LogEntryDT]) 
			VALUES(@FileName, @count, @DeleteCount, 0, GETDATE())
	
		  COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_TVInsertPlaylistFileData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;