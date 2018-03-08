-- =============================================   
-- Author:    Asit   
-- Create date: 09/01/2015   
-- Description: Get Distinct InputFileName from RawTVPlaylist table.  
-- Query :   
/*  
exec sp_GetDistinctOccurancePlaylist
*/ 

-- =============================================   

CREATE PROCEDURE [dbo].[sp_TVGetDistinctPlaylistFiles] 

AS 

  BEGIN 

      BEGIN TRY 

	  DECLARE @DistinctInputFileName TABLE
		(
		  [RowId] [INT] IDENTITY(1,1) NOT NULL,
		  InputFileName VARCHAR(200)	 
		);

		INSERT INTO @DistinctInputFileName
		(
		InputFileName
		)
		select InputFileName
		from (
		SELECT distinct InputFileName, first_value(RawTVPlayListID) over (partition by InputFileName order by RawTVPlayListID) firstID
				FROM RawTVPlaylist with (nolock)
				where IngestionStatus = 0
		) x
		order by firstID	

	  SELECT * FROM @DistinctInputFileName

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_TVGetDistinctPlaylistFiles: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;