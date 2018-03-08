-- ===========================================================================
-- Author:		Govardhan 
-- Create date: 25 April 2015
-- Description:	Insert into FTP logs.
-- Updated By		:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_CPInsertFTPLog]
(
@FileType varchar(25),
@FTPFolder varchar(250),
@FTPFileName varchar(50)
)
AS
BEGIN
		BEGIN TRY
			INSERT INTO NLSNFTPLog(FileType,FTPFolder,FTPFileName,[DownloadDT])
			VALUES(@FileType,@FTPFolder,@FTPFileName,getdate())

		END TRY

		BEGIN CATCH
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_CPInsertFTPLog]: %d: %s',16,1,@error,@message,@lineNo);           
      END CATCH

END
