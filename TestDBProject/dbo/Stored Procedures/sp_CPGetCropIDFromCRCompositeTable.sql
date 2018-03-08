-- =============================================
-- Author:		Monika. J
-- Create date: 11/26/2015
-- Description:	To get crop ID detail
-- Excecution: sp_CPGetCropIDFromCRCompositeTable 6318
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPGetCropIDFromCRCompositeTable]
	-- Add the parameters for the stored procedure here
	@CreativeCropStagingID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NewCompCropID INT
	DECLARE @OccurrenceID int
	SET @OccurrenceID = (Select [PrimaryOccurrenceID] from Ad where [AdID]=@CreativeCropStagingID)
    -- Insert statements for procedure here
	BEGIN TRY
	IF(EXISTS(select Top 1 b.[CompositeCropID]  from [CreativeForCrop] a INNER JOIN CompositeCrop b ON b.[CreativeCropID]=a.[CreativeForCropID] INNER JOIN CreativeContentDetail c
		ON c.[CreativeCropID]=a.[CreativeForCropID] where [CreativeID]=@CreativeCropStagingID AND c.[CompletedByID] IS NULL))
    BEGIN
	   select Top 1 @NewCompCropID=b.[CompositeCropID] from [CreativeForCrop] a INNER JOIN CompositeCrop b ON b.[CreativeCropID]=a.[CreativeForCropID] INNER JOIN CreativeContentDetail c
	   ON c.[CreativeCropID]=a.[CreativeForCropID] where [CreativeID]=@CreativeCropStagingID AND c.[CompletedByID] IS NULL
    END
    ELSE
    BEGIN
	   SELECT @NewCompCropID = CropID FROM CompositeCropStaging 
	   WHERE [CreativeCropStagingID] IN(SELECT CreativeForCropStagingID FROM [CreativeForCropStaging] 
		  WHERE [CreativeCropID] IN(SELECT [CreativeForCropID] FROM [CreativeForCrop]
			 WHERE [CreativeID] = @CreativeCropStagingID	AND [OccurrenceID] = @OccurrenceID))
    END

	--ELSE
	--	BEGIN
	--		DECLARE @CreativeCropID INT
	--		DECLARE @CreativeContentID INT
	--		DECLARE @MediaType NVARCHAR(MAX)

	--		SET @CreativeCropID = (Select PK_ID FROM CreativeForCrop where FK_ID=@CreativeCropStagingID)

	--		SELECT @MediaType= b.ValueTitle FROM CREATIVEFORCROP a INNER JOIN [dbo].[CONFIGURATIONMASTER] b ON b.Value=a.MediaStream where a.PK_ID=@CreativeCropID

	--		INSERT INTO Compositecrop(FK_CreativeCropID,CompositeImageSize,CreatedDate,CreatedBy)
	--		VALUES(@CreativeCropID,2156,Current_TimeStamp,850016455)

	--		SET @NewCompCropID = Scope_Identity()

	--		INSERT INTO CreativeContentDetail(FK_CreativeMasterID,FK_CreativeCropID,FK_CreativeDetailID,MediaStream,SellableSpaceCoordX1,SellableSpaceCoordY1,
	--		SellableSpaceCoordX2,SellableSpaceCoordY2,CreateDate,CreateBy)
	--		VALUES (8466,@CreativeCropID,8189,@MediaType,0,0,0,0,Current_TimeStamp,850016455)

	--		SET @CreativeContentID=Scope_Identity()

	--		INSERT INTO CreativeDetailInclude(FK_CropID,FK_ContentDetailID,CreateDate,CreateBy)
	--		VALUES(@NewCompCropID,@CreativeContentID,Current_TimeStamp,850016455)
			
	--		--select * from CreativeDetailInclude
	--	END
		SELECT @NewCompCropID as NewCompCropID
	END TRY
	BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetCropIDFromCRCompositeTable: %d: %s',16,1,@error,@message,@lineNo); 
			  
	END CATCH	
END


