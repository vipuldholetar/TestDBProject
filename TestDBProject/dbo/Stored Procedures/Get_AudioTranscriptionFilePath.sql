-- =============================================
-- Author:		<Author,,Monika.J>
-- Create date: <Create Date,08-07-2015,>
-- Description:	<Description,To get list of audio transcription file path,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_AudioTranscriptionFilePath] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN try 

	   BEGIN TRANSACTION   

	--SELECT Top 5 T1.*,T3.Speaker_Name FROM CreativeDetailsRAStg T1 INNER JOIN PatternMasterStg T2 ON T1.FK_CreativeStgId=T2.FK_CreativeStgId
	--INNER JOIN SPEAKERMASTER T3 ON T2.LanguageID=T3.LanguageID WHERE T1.AudioTranscription IS NULL
	

		declare @tempTable table
			(
			ID int,
			PK_Id int, 
			FK_CreativeStgId int, 
			MediaFormat char(10), 
			MediaFilePath varchar(max), 
			MediaFileName varchar(max), 
			FileSize bigint, 
			AudioTranscription nvarchar(max),
			Speaker_Name varchar(50)
			)

		-- Insert statements for procedure here
		Insert into @tempTable (ID,PK_Id, FK_CreativeStgId, MediaFormat, MediaFilePath, MediaFileName, FileSize, AudioTranscription, Speaker_Name)
		SELECT  ROW_NUMBER() OVER (ORDER BY T1.[CreativeDetailStagingRAID]) AS [serial number] ,T1.*,T3.[SpeakerName] FROM [CreativeDetailStagingRA] T1 INNER JOIN [PatternStaging] T2 ON T1.[CreativeStgID]=T2.[CreativeStgID]
		INNER JOIN [Speaker] T3 ON T2.[LanguageID]=T3.LanguageID WHERE T1.AudioTranscription IS NULL
		order by [serial number] OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY	

		select  PK_Id, FK_CreativeStgId, MediaFormat, MediaFilePath, MediaFileName, FileSize, AudioTranscription, Speaker_Name
		from @tempTable
	COMMIT TRANSACTION 
	
    END try 
	   BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('Get_AudioTranscriptionFilePath: %d: %s',16,1,@Error,@Message,@LineNo); 
		  ROLLBACK TRANSACTION 
      END catch
  END
  --update CreativeDetailsRAStg set AudioTranscription = NULL where PK_Id = 1007