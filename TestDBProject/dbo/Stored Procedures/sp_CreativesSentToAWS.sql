CREATE PROCEDURE [dbo].[sp_CreativesSentToAWS] (
	@MediaType NVarchar(4),--name
	@AdID Int, --new?
	@CreativeDetailID int,	
	@AwsCreativeKey NVarchar(200),
	@AwsThumbnailKey NVarchar(200),
	@CreativeDomainCode NVarchar(200), 
	@CreativeDomainName NVarchar(200), 
	@FileFormat NVarchar(50), 
	@MimeType NVarchar(50), 
	@PlayerMode NVarchar(200), 
	@OrderID int,
	@OccurrenceID int,
	@CreativeSignature NVarchar(300),
	@ViewType NVarchar(50)
)
AS
begin
SET XACT_ABORT OFF;
 BEGIN TRY 
         
			insert into CreativesSentToAWS( MediaType, AdID, CreativeDetailID, AwsCreativeKey, AwsThumbnailKey, CreativeDomainCode, CreativeDomainName, FileFormat, MimeType, PlayerMode, OrderID, OccurrenceID, CreativeSignature, transferDT,viewType			
			)
			values (
				@MediaType,
				@AdID,
				@CreativeDetailID,
				@AwsCreativeKey ,
				@AwsThumbnailKey ,
				@CreativeDomainCode , 
				@CreativeDomainName , 
				@FileFormat, 
				@MimeType, 
				@PlayerMode, 
				@OrderID,
				@OccurrenceID,
				@CreativeSignature,
				GetDate(),
				@ViewType
			)


 END TRY 

	BEGIN CATCH 
		DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_CreativesSentToAWS]: %d: %s',16,1,@error,  @message ,@lineNo); 		
	END CATCH 
END