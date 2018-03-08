-- =============================================
-- Author			:	Karunakar		
-- Create date		:	30th December 2015
-- Description		:	This Procedure is used for getting Publication PubSectionName from PubSection table
-- =============================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFGetPubSection] 
	(
	@publicationid as Int	
	)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 
			--Selecting PubSectionName from PubSection
			SELECT PubSectionName, [PubSectionID]   FROM PubSection inner join Publication on 
			--PubSection.PK_PubSectionID=Publication.SectionDefault  AND 
			Pubsection.[PublicationID]=Publication.[PublicationID] 
            WHERE Publication.[PublicationID] = @publicationid ORDER BY PubSectionName




	END TRY
	 BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number() ,@message = Error_message() ,@lineNo = Error_line() 
          RAISERROR ('sp_PublicationDPFGetPubSection: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH
END
