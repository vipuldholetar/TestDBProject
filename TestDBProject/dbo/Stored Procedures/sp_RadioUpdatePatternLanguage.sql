
-- =================================================================================
-- Author			: Karunakar
-- Create date		: 04/01/2015
-- Description		: This stored procedure is used to Update Language for Radio Pattern
-- Execution Process: [Ino_raq_updatePatternLanguage]  2,'','hindi'
-- Updated By		: Ramesh on 08/11/2015 - CleanUp for OneMTDB 
--				    Ashanie: remove insert into language table
-- ===================================================================================

CREATE PROCEDURE [dbo].[sp_RadioUpdatePatternLanguage] 
@pRCSCreativeID VARCHAR(50), 
@pLanguageID    INT, 
@pLanguageName  VARCHAR(50 )='' 
AS 
  BEGIN 
      DECLARE @languageid INT 
      BEGIN TRY 
    --      IF ( @planguageName <> '' ) 
    --        BEGIN 
    --            --INSERT INTO [Language]   (description) VALUES     (@planguagename) 
    --            --SELECT @languageid = Scope_identity(); 
			 --UPDATE [PatternStaging] SET [LanguageID] = @languageid WHERE  [PatternStagingID] 
				--IN (SELECT [PatternStgID] FROM   [PatternDetailRAStaging] WHERE [RCSCreativeID] = @pRCSCreativeID) 
    --        END 
    --      ELSE 
    --        BEGIN 
                UPDATE [PatternStaging] SET  [LanguageID] = @pLanguageID WHERE CreativeSignature=@pRCSCreativeID
                --WHERE  [PatternStagingID] IN ((SELECT [PatternStgID] FROM   [PatternDetailRAStaging]  WHERE  [RCSCreativeID] = @pRCSCreativeID)) 
            --END 
      END TRY 

      BEGIN catch 
          DECLARE @error   INT, @message VARCHAR(4000),  @lineNo  INT 
          SELECT @error = Error_number(),  @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_RadioUpdatePatternLanguage]: %d: %s',16,1,@error, @message,@lineNo); 
      END catch 
  END