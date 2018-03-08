-- ========================================================================
-- Author: Nagarjuna
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with Ethnic PR Code Translation
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionMain_1oct2015](@TVBatchData [dbo].[TVBatchData] readonly)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
          BEGIN TRANSACTION 

			declare @fileToProcess varchar(100)
			declare @totalRowCount int
			declare @currentRowId int
 
			DECLARE @playListFiles TABLE
			(
				[RowId] [INT] IDENTITY(1,1) NOT NULL,		  
				[InputFileName] [varchar](200)		 
			);

			insert into @playListFiles 
			select InputFileName from @TVBatchData

			select @totalRowCount = count(*) from @playListFiles
			select @currentRowId = 1
				
			WHILE @currentRowId <= @totalRowCount
			BEGIN
				-- For each file name call a separate stored proc to Ingest the data

				select @fileToProcess = InputFileName from @playListFiles where RowId = @currentRowId

				EXEC [dbo].[sp_TVIngestionProcessFile] @fileToProcess

				-- Move to the next file
				select @currentRowId = @currentRowId+1
			END

			delete from RawTVPlaylist where InputFileName IN (SELECT InputFileName from @TVBatchData)

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVIngestionMain: %d: %s',16,1,@Error,@Message, @LineNo); 

          ROLLBACK TRANSACTION 
	 END CATCH;
END
