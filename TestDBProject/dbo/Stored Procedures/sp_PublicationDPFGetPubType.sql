-- =============================================
-- Author			:	Swagathika		
-- Create date		:	30th December 2015
-- Description		:	This Procedure is used for getting Publication Type from Configurationmaster
-- =============================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFGetPubType] 
	(
	@publicationid int
	)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 
  
	select ConfigurationID,pub.pubtype,[Configuration].value as [Type] 
    from publication pub 
    inner join [Configuration] on [Configuration].ConfigurationID=pub.pubtype
	where pub.[PublicationID]=@publicationid

	END TRY
	 BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number() 
                 ,@message = Error_message() 
                 ,@lineNo = Error_line() 

          RAISERROR ('sp_PublicationDPFGetPubType: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH
END
