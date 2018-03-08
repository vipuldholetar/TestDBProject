-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[sp_RCSIngestion_UpdateAudiotranscribed] 
	-- Add the parameters for the stored procedure here
	(@RCSAudioRawData dbo.RCSAudioData READONLY)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	  BEGIN try 

	   BEGIN TRANSACTION
	--UPDATE MainTbl    
	--			SET MainTbl.AudioTranscription= InputTbl.AudioTranscription   
	--			from [dbo].[CREATIVEDETAILSRASTAGING] MainTbl
	--			INNER JOIN @RCSAudioRawData InputTbl
	--			ON MainTbl.[CreativeDetailRAStagingID]=InputTbl.CreativeDetailID
	--SELECT COUNT(CreativeDetailID) AS ImportedRecCount FROM @RCSAudioRawData

	UPDATE MainTbl    
				SET MainTbl.AudioTranscription= InputTbl.AudioTranscription   
				from [dbo].[CreativeDetailStagingRA] MainTbl
				INNER JOIN @RCSAudioRawData InputTbl
				ON MainTbl.[CreativeDetailStagingRAID]=InputTbl.CreativeDetailID
	SELECT COUNT(CreativeDetailID) AS ImportedRecCount FROM @RCSAudioRawData

 COMMIT TRANSACTION 
	
      END try 
	   BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSIngestion_UpdateAudiotranscribed: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch; 
  END; 

	-- DECLARE @COUNTCREATIVEIDS  INT, 
 --                 @PTR     INT, 
 --                 @crediid INT

	--	SELECT @COUNTCREATIVEIDS = 0, 
	--   @PTR = 1 ,
	--   @crediid = 0

	--SELECT @COUNTCREATIVEIDS = Count(CreativeDetailID) 
	--  FROM   @RCSAudioRawData

	--WHILE ( @COUNTCREATIVEIDS > 0 ) 
	--BEGIN 
	--	  BEGIN try 
 --           SELECT @COUNTCREATIVEIDS = @COUNTCREATIVEIDS - 1 

	--		select @crediid =  @RCSAudioRawData where rowid = @PTR

	--		UPDATE MainTbl    
	--			SET MainTbl.AudioTranscription= InputTbl.AudioTranscription   
	--			from [dbo].[CREATIVEDETAILRA] MainTbl
	--			INNER JOIN [dbo].[RCSAudioData] InputTbl
	--			ON MainTbl.[CreativeDetailID]=@crediid

	--		SET @PTR = @PTR + 1 
 --     END try 

 --     BEGIN catch 
 --         PRINT( '' ) 

 --         --UPDATE @RCSAudioRawData 
 --         --SET    status = '' 
 --         --WHERE  rowid = @PTR 

 --         SET @PTR = @PTR + 1 
 --     END catch 
  -- END 
	





		--UPDATE MainTbl    
		--SET MainTbl.AudioTranscription= InputTbl.AudioTranscription   
		--from [dbo].[CREATIVEDETAILRA] MainTbl
		--INNER JOIN [dbo].[RCSAudioData] InputTbl
		--ON MainTbl.[CreativeDetailID]=InputTbl.[CreativeDetailID]

		--UPDATE [dbo].[CREATIVEDETAILRA] SET AudioTranscription=@AudioTrans WHERE [CreativeDetailID]=@ID 
    -- Insert statements for procedure here
	--DECLARE @ID int, @AudioTrans varchar(MAX)
	--DECLARE @MyCursor CURSOR
	--SET @MyCursor = CURSOR FAST_FORWARD
	--FOR
	--	SELECT * FROM @RCSAudioRawData
	--	OPEN @MyCursor -- open the cursor
	--	FETCH NEXT FROM @MyCursor 
	--	INTO @ID,@AudioTrans
	--	WHILE @@FETCH_STATUS = 0
	--		BEGIN
	--			IF(EXISTS(SELECT * FROM [dbo].[CREATIVEDETAILRA] WHERE [CreativeDetailID]=@ID))
	--				UPDATE [dbo].[CREATIVEDETAILRA] SET AudioTranscription=@AudioTrans WHERE [CreativeDetailID]=@ID
	--			FETCH NEXT FROM @MyCursor
	--			INTO @ID,@AudioTrans
	--		END
	--	CLOSE @MyCursor -- close the cursor

	--	DEALLOCATE @MyCursor -- De
--END
