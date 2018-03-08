
-- =============================================     
-- Author:    Nagarjuna     
-- Create date: 07/17/2015     
-- Description:  This procedure is used to process the TV media files
-- Query : exec sp_TVProcessMediaFiles
--DROP PROCEDURE   sp_TVProcessMediaFiles
-- =============================================  

CREATE PROCEDURE [dbo].[sp_TVProcessMediaFiles] (@TVMediaFiles dbo.TVMediaFiles readonly)
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
	  BEGIN TRANSACTION 
	   	  
	  DECLARE @MediaBasePath AS VARCHAR(250);
	  SELECT @MediaBasePath = VALUE FROM [Configuration] where systemName='All' and componentName='Creative Repository'

	  --Table for populating Media files that are in shared folder
	  DECLARE @TVMediaFilesData TABLE
	  (
	    [RowId] [INT] IDENTITY(1,1) NOT NULL,
		[PRCode] varchar(20) NOT NULL,
	    [FileName] VARCHAR(200) NOT NULL,
		[FilePath] varchar(200) NOT NULL,
		[FileSize] bigint NOT NULL
	  );

	  -- Table for getting records for 
	  DECLARE @DistnctPRCodes TABLE
	  (
	    [RowId] [INT] IDENTITY(1,1) NOT NULL,
	    [PRCode] VARCHAR(20) NOT NULL
	  );

	  DECLARE @TVMediaBasedOnPRCode TABLE
	  (
	    [RowId] [INT] IDENTITY(1,1) NOT NULL,
		[PRCode] varchar(20) NOT NULL,
	    [FileName] VARCHAR(200) NOT NULL,
		[FilePath] varchar(200) NOT NULL,
		[FileSize] bigint NOT NULL
	  );


	  DECLARE @RowCount        INT, 
                @TotalRows       INT,
				@MediaRowCount        INT, 
                @TotalMediaRows       INT,
				@FilePath varchar(200),
				@CreativeSignature varchar(200),
				@NonEthnicPRCode varchar(200),
				@OriginalPRCode varchar(200),
				@OriginalPRAfterSplit varchar(200),
				@JPEGFileName varchar(200),
				@WavFileName varchar(200),
				@MP4FileName varchar(200),
				@CreativeMasterStgId INT,
				@MediaFormat Varchar(10),
				@FileName varchar(200),
				@MediaPath varchar(200),
				@FileSize bigint,
				@UpdatedCreativeSignature varchar(20),
				@MinOccurrenceID int
				


	 SELECT @RowCount = 1, 
               @TotalRows = 0,
			   @MediaRowCount = 1,
			   @TotalMediaRows = 0

	  delete from @TVMediaFilesData
	  INSERT INTO @TVMediaFilesData
	  (
	  [PRCode],
	  [FileName],
	  [FilePath],
	  [FileSize]
	  )
	  select 
	  PRCode,	  
	  [MediaFileName],
	  [MediaFilePath],
	  FileSize
	  from @TVMediaFiles

	  --select * from @TVMediaFilesData

	  INSERT INTO @DistnctPRCodes
	  (
	  PRCode  
	  )
	  SELECT 
	  distinct PRCode
	  from @TVMediaFilesData
	  left join TVEthnicPRCode on TVEthnicPRCodeID = PRCode

	  SELECT @TotalRows = COUNT(*) FROM @DistnctPRCodes
	  print(@TotalRows)

	  WHILE @TotalRows > 0
	  BEGIN
		SELECT @TotalRows = @TotalRows - 1
		SET @MediaPath = ''
		SELECT @CreativeSignature = PRCode FROM @DistnctPRCodes WHERE RowId = @RowCount
		--SET @UpdatedCreativeSignature = @CreativeSignature + '%'
		SELECT @MinOccurrenceID = min(OccurrenceDetailTVID) from OccurrenceDetailTV where PRCODE = @CreativeSignature

		INSERT INTO [CreativeStaging] 
			(
			Deleted,
			[CreatedDT],
			OccurrenceID,
			CreativeSignature
			)
			VALUES
			(
			0,
			GETDATE(),
			@MinOccurrenceID,
			@CreativeSignature
			)

		SELECT @CreativeMasterStgId = Scope_identity() 
		
		--Update the table PatternMasterStgTV with CreativeMasterStgId

		UPDATE [PatternStaging]
		SET [CreativeStgID] = @CreativeMasterStgId
		WHERE [CreativeSignature] = @CreativeSignature
		
		DELETE FROM @TVMediaBasedOnPRCode
		
		INSERT INTO @TVMediaBasedOnPRCode
		(
		[PRCode],
		[FileName],
		FilePath,
		FileSize
		)
		SELECT 
		[PRCode],
		[FileName],
		FilePath,
		FileSize
		FROM @TVMediaFilesData WHERE [PRCode] = @CreativeSignature
		
		--select * from @TVMediaBasedOnPRCode

		SELECT @TotalMediaRows = COUNT(*) FROM @TVMediaBasedOnPRCode
			
		IF( @TotalMediaRows > 0)
		BEGIN

			--Looping through media files based on PR Code
			WHILE @TotalMediaRows > 0
			BEGIN
				SELECT @TotalMediaRows = @TotalMediaRows - 1	
				
				SELECT @FileName = [FileName] FROM @TVMediaBasedOnPRCode WHERE [RowId] =  @MediaRowCount
				SELECT @MediaPath = FilePath FROM @TVMediaBasedOnPRCode WHERE [RowId] =  @MediaRowCount
				SELECT @MediaFormat = dbo.TVGetSplitStringByRowNo(@FileName,'.',2)
				SELECT @MediaPath =REPLACE((REPLACE(@MediaPath, '\'+@FileName, '')),@MediaBasePath,'')+'\'
				SELECT @FileSize = FileSize FROM @TVMediaBasedOnPRCode WHERE [RowId] =  @MediaRowCount
				
				INSERT INTO [CreativeDetailStagingTV]
				(
				[CreativeStgMasterID],
				MediaFormat,
				MediaFilepath,
				MediaFileName,
				FileSize
				)
				VALUES
				(
				@CreativeMasterStgId,
				@MediaFormat,
				@MediaPath,
				@FileName,
				@FileSize
				)

				SELECT @MediaRowCount = @MediaRowCount + 1
			END

			DELETE FROM @TVMediaBasedOnPRCode

			END	
		--SET @MediaRowCount = @MediaRowCount + @TotalMediaRows
		SELECT @RowCount = @RowCount + 1		
		END
		
		
	  
	  COMMIT TRANSACTION 
	  END try 
      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVProcessMediaFiles: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END;