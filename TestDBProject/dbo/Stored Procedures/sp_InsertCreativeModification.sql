-- =============================================
-- Author:		Ashanie Cole
-- Create date:	April 2017
-- Description:	keep track of creative modifications so they can be replicated to all locations
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertCreativeModification]
    @MediaStreamId INT,
    @AdId INT,
    @CreativeId INT,
    @OccurrenceId INT,
    @CreativeSignature VARCHAR(100),
    @CreativePath VARCHAR(max),
    @UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LocationId INT
	DECLARE @BasePath as varchar(500)
	DECLARE @Synced BIT

	IF @AdId > 0 OR @CreativeId > 0 OR @OccurrenceId > 0 OR (@CreativeSignature <> '' AND @CreativeSignature IS NOT NULL)
	BEGIN
		SELECT @LocationId = LocationId 
		FROM [User]
		WHERE UserId = @UserId

		SELECT @BasePath = Value 
		FROM configuration 
		WHERE ComponentName = 'Creative Repository'

		IF @CreativePath like @BasePath + '%'
			SET @Synced = 1
		ELSE
			SET @Synced = 0

		SET @CreativePath = REPLACE(@CreativePath, '\\','\')
		SET @CreativePath = '\' + @CreativePath

		INSERT INTO [dbo].[CreativeModifications]
			([MediaStreamId]
			,[AdId]
			,[CreativeId]
			,[OccurrenceId]
			,[CreativeSignature]
			,[CreativePath]
			,[LocationId]
			,[Synced]
			,[ModifiedById]
			,[ModifiedDT]
			)
		VALUES
			(@MediaStreamId
			,@AdId
			,@CreativeId
			,@OccurrenceId
			,@CreativeSignature
			,@CreativePath
			,@LocationId
			,@Synced
			,@UserId
			,GETDATE())
	END
END