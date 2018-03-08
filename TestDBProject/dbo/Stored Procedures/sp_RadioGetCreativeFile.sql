-- =============================================
-- Author			: KARUNAKAR
-- Create date		: 04/08/2015
-- Description		: This stored procedure is used to retreive creative file
-- Execution Process: [sp_RadioGetCreativeFile] "444"
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
-- =============================================
CREATE PROCEDURE [dbo].[sp_RadioGetCreativeFile]
	@pCreativeSignatureID varchar(50)
AS
BEGIN
    
       BEGIN TRY
       --select @pCreativeSignatureID As CreativeSignatureID,'D:\Kalimba.mp3' as CreativeFilePath
		    SELECT [PatternStaging].[PatternStagingID],
			[CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].MediaFormat))  AS CreativeFilePath 
		    FROM [PatternStaging]	INNER JOIN [CreativeStaging] on [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
			inner join [CreativeDetailStagingRA] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID] 
			and [PatternStaging].CreativeSignature=@pCreativeSignatureID
       END TRY 

		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_RadioGetCreativeFile: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 

END