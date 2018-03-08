

-- =============================================     

-- Author:    Nagarjuna     

-- Create date: 07/17/2015     

-- Description:  This procedure is used to process the TV media files

-- Query : exec sp_TVProcessMediaFiles

-- =============================================    

CREATE PROCEDURE [dbo].[sp_TVProcessMediaFiles_OLD] (@TVMediaFiles dbo.TVMediaFiles readonly)

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

	    [FileName] VARCHAR(200) NOT NULL,

		[FilePath] varchar(200) NOT NULL,

		[FileSize] bigint NOT NULL

	  );



	  -- Table for getting records for 

	  DECLARE @PatternMasterStgTV TABLE

	  (

	    [RowId] [INT] IDENTITY(1,1) NOT NULL,

	    [CreativeSignature] VARCHAR(200) NOT NULL

	  );



	  DECLARE @TVMediaBasedOnPRCode TABLE

	  (

	    [RowId] [INT] IDENTITY(1,1) NOT NULL,

	    [MediaFileName] VARCHAR(200) NOT NULL,

		[MediaFilePath] VARCHAR(200) NOT NULL,

		[FileSize] bigint NOT NULL

	  );





	  DECLARE @RowCount        INT, 

                @TotalRows       INT,

				@MediaRowCount        INT, 

                @TotalMediaRows       INT,

				@FilePath varchar(200),

				@CreativeSignature varchar(200),

				@OriginalPRCode varchar(200),

				@OriginalPRAfterSplit varchar(200),

				@JPEGFileName varchar(200),

				@WavFileName varchar(200),

				@MP4FileName varchar(200),

				@CreativeMasterStgId INT,

				@MediaFormat Varchar(10),

				@FileName varchar(200),

				@MediaPath varchar(200),

				@FileSize bigint





	 SELECT @RowCount = 1, 

               @TotalRows = 0,

			   @MediaRowCount = 1,

			   @TotalMediaRows = 0



	

	  INSERT INTO @TVMediaFilesData

	  (

	  [FileName],

	  [FilePath],

	  [FileSize]

	  )

	  select 

	  MediaFileName,

	  MediaFilePath,

	  FileSize

	  from @TVMediaFiles



	  --select * from @TVMediaFilesData



	  INSERT INTO @PatternMasterStgTV

	  (

	  CreativeSignature

	  )

	  SELECT 

	  [CreativeSignature]

	  FROM [PatternTVStaging] inner join [TVPattern] ON [TVPattern].[TVPatternCODE]=[PatternTVStaging].[CreativeSignature] WHERE [CreativeStagingID] IS NULL



	  SELECT @TotalRows = COUNT(*) FROM @PatternMasterStgTV

	  print(@TotalRows)



	  WHILE @TotalRows > 0

	  BEGIN

		SELECT @TotalRows = @TotalRows - 1

		SET @MediaPath = ''

		SELECT @CreativeSignature = CreativeSignature FROM @PatternMasterStgTV WHERE RowId = @RowCount



		SELECT @OriginalPRCode = OriginalPRCode FROM [TVPattern] WHERE [TVPatternCODE] = @CreativeSignature

		SELECT @OriginalPRAfterSplit = dbo.TVGetSplitStringByRowNo(@OriginalPRCode,'.',1)



		DELETE FROM @TVMediaBasedOnPRCode

		

		INSERT INTO @TVMediaBasedOnPRCode

		(

		[MediaFileName],

		MediaFilePath,

		FileSize

		)

		SELECT 

		[FileName],

		FilePath,

		FileSize

		FROM @TVMediaFilesData WHERE [FileName] LIKE '%'+@OriginalPRAfterSplit+'%'

		

		--select * from @TVMediaBasedOnPRCode



		SELECT @TotalMediaRows = COUNT(*) FROM @TVMediaBasedOnPRCode

			

		IF( @TotalMediaRows > 0)

		BEGIN

			

			IF(EXISTS(SELECT * FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.mpg%'))

			BEGIN

			

			SELECT @MP4FileName = [MediaFileName] FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.mpg%'



			IF(EXISTS(SELECT * FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.wav%'))

			BEGIN

				SELECT @WavFileName = [MediaFileName] FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.wav%'

			END

			else

			begin

				SELECT @WavFileName = ''

			end

			

			IF(EXISTS(SELECT * FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.jpg%'))

			BEGIN

				SELECT @JPEGFileName = [MediaFileName] FROM @TVMediaBasedOnPRCode WHERE [MediaFileName] LIKE '%.jpg%'

			END

			else

			begin

				SELECT @JPEGFileName = ''

			end



			INSERT INTO [CreativeStaging] 

			(

			Deleted,

			[CreatedDT]

			)

			VALUES

			(

			0,

			GETDATE()

			)



			SELECT @CreativeMasterStgId = Scope_identity() 

			

			--Update the table PatternMasterStgTV with CreativeMasterStgId

			UPDATE [PatternTVStaging]

			SET [CreativeStagingID] = @CreativeMasterStgId

			WHERE [CreativeSignature] = @CreativeSignature



			--Looping through media files based on PR Code

			WHILE @TotalMediaRows > 0

			BEGIN

				SELECT @TotalMediaRows = @TotalMediaRows - 1	

				

				SELECT @FileName = MediaFileName FROM @TVMediaBasedOnPRCode WHERE [RowId] =  @MediaRowCount

				SELECT @MediaPath = [MediaFilePath] FROM @TVMediaBasedOnPRCode WHERE [RowId] =  @MediaRowCount

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

		END

		SET @MediaRowCount = @MediaRowCount + @TotalMediaRows

		SELECT @RowCount = @RowCount + 1

	  END

	 

	 delete from @TVMediaFilesData

	  --INSERT INTO TVMediaFileData

	  --(

	  --MediaFilePath,

	  --MediaFileName,

	  --FileSize

	  --)

	  --select 

	  --MediaFilePath,

	  --MediaFileName,

	  --[FileSize]

	  --from @TVMediaFiles





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