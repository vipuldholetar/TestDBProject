
-- =============================================
-- Author	  :	Arun Nair 
-- Create date: 20 April 2015
-- Description:	Insert Values To Staging Tables
-- Execution  : 
--===================================================
CREATE PROCEDURE [dbo].[ino_test_values] -- 'M2209601-20223710'
(
@CreativeSignature AS NVARCHAR(50)
)
AS
BEGIN
	  SET NOCOUNT ON;	

				BEGIN TRY
					BEGIN TRANSACTION 
					
						DECLARE @OccurrenceID AS INT=0
						DECLARE @CreativeStagingID AS INT=0
						DECLARE @CreativeDetailsRAStagingID AS INT =0
						DECLARE @PatternMasterStagingID AS INT =0
						DECLARE @NumberRecords as int=0
						DECLARE @RowCount as int=0

					  CREATE TABLE #tempoccurencesforcreativesignature 
					  (   rowid        INT IDENTITY(1, 1),
					      occurrenceid INT 
					   ) 

					INSERT INTO #tempoccurencesforcreativesignature  SELECT [OccurrenceDetailRAID] FROM   [dbo].[OccurrenceDetailRA] INNER JOIN rcsacidtorcscreativeidmap
					 ON rcsacidtorcscreativeidmap.RCSAcIdToRCSCreativeIdMapID = [OccurrenceDetailRA].[RCSAcIdID] INNER JOIN [RCSCreative] ON rcscreative.rcscreativeid =rcsacidtorcscreativeidmap.[RCSCreativeID] 
					 AND rcscreative.rcscreativeid = @CreativeSignature 

					SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
					SET @RowCount = 1 
					WHILE @RowCount <= @NumberRecords 
						BEGIN
							 
							SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature  WHERE  rowid = @RowCount
								INSERT INTO [dbo].[CREATIVEMASTERSTAGING] VALUES (null,0,null,null,null,null,null,null,getdate(),null,@OccurrenceID)
								SELECT @CreativeStagingID = Scope_identity() 
								INSERT  INTO [dbo].[CREATIVEDETAILSRASTAGING] VALUES(@CreativeStagingID,'Wav','D:\','Kalimba.mp3',150)
								SELECT @CreativeDetailsRAStagingID= Scope_identity() 
								INSERT INTO [dbo].[PATTERNMASTERSTAGING] VALUES(@CreativeStagingID,null,null,null,null,null,null,null,null,null,null,'Valid',0,null,1,getdate(),1,null,null)							
								SELECT  @PatternMasterStagingID= Scope_identity()  
								INSERT INTO [dbo].[PATTERNDETAILRASTAGING] VALUES(@PatternMasterStagingID,@CreativeSignature,null,null,null,null)
						SET @RowCount=@rowcount + 1 
					END 

					DROP TABLE #tempoccurencesforcreativesignature 
					COMMIT TRANSACTION
					END TRY 

			BEGIN CATCH 

						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('[ino_text_values]: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 

END


Select * from [PATTERNDETAILRASTAGING]
Select * from [dbo].[CREATIVEMASTERSTAGING]
Select * from [dbo].[CREATIVEDETAILSRASTAGING]
Select * from [dbo].[PATTERNMASTERSTAGING]