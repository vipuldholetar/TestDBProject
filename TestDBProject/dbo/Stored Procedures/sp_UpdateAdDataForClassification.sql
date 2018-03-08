-- =============================================
-- Author:		Monika. J
-- Create date: 05/10/2015
-- Description:	Updating Ad that is Edited for Classification 
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateAdDataForClassification] 
	-- Add the parameters for the stored procedure here
	@Adid INT,
	@Campaign NVARCHAR(MAX),
	@KeyVisualElement NVARCHAR(MAX),
	@FK_CelebrityID NVARCHAR(MAX),
	@CoopPartner NVARCHAR(MAX),
	@Competitors NVARCHAR(MAX),
	@ClassificationGrp INT,
	@TagLineID NVARCHAR(MAX),
	@Username NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	  If @TagLineID='' 
	  set @TagLineID=null

	BEGIN TRY
		BEGIN TRANSACTION 
			 -- Insert statements for procedure here
			 DECLARE @CoopTable TABLE (AdID INT,Item NVARCHAR(1000),AdvID INT)
			 DECLARE @CompTable TABLE (AdID INT,Item NVARCHAR(1000),AdvID INT)

			INSERT INTO @CoopTable (Item)  
			SELECT * FROM  [dbo].[FN_CPSplitString] (@CoopPartner)

			INSERT INTO @CompTable (Item) 
			SELECT * FROM  [dbo].[FN_CPSplitString] (@Competitors)
			--Select * from @CoopTable
			Delete from AdCoopComp where [AdCoopID]=@Adid and CoopCompCode = 'C'
			INSERT INTO AdCoopComp ([AdvertiserID],[AdCoopID], CoopCompCode)
			Select distinct b.[AdvertiserID],@Adid,'C' from @CoopTable a, [Advertiser] b where a.Item = b.Descrip 
			
			Delete from AdCoopComp where [AdCoopID]=@Adid and CoopCompCode = 'X'
			INSERT INTO AdCoopComp ([AdvertiserID],[AdCoopID], CoopCompCode)
			Select distinct b.[AdvertiserID],@Adid,'X' from @CompTable a,[Advertiser] b where a.Item = b.Descrip

			 UPDATE [dbo].[Ad] 
						SET [Campaign]=@Campaign,
							[KeyVisualElement]=@KeyVisualElement,
							[TaglineID]=@TagLineID,
							[CelebrityID]=@FK_CelebrityID,							
							[ClassificationGroupID]=@ClassificationGrp,	
							[ClassifiedBy]=@Username,
							[ClassifiedDT]	= getdate()	  
						 WHERE [AdID]=@Adid

		COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_UpdateAdDataForClassification: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
END


--select * from [dbo].[AdCoopComp]