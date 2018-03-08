
-- ===============================================================================================
-- Author			: KARUNAKAR
-- Create date		: 5th Nov 2015
-- Description		: This stored procedure is used to Check the Ad Id Exist in  Creative Master 
-- Execution Process: sp_EmailDPFCheckIsCreativeExist 10427
-- UpdatedBy		: 
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailDPFCheckIsCreativeExist]
	@AdId As Int
AS
BEGIN
	SET NOCOUNT ON;
	Declare @IsCreativeExists As  Bit
	DECLARE @CreativeMasterID INT
	
	select @CreativeMasterID=[CreativeID] from [Pattern] where [PatternID]=(Select [PatternID] from [OccurrenceDetailEM] where [OccurrenceDetailEMID]=(Select [PrimaryOccurrenceID] from Ad where [AdID]=@AdId))

	if Exists(Select 1 from [Creative] Where PK_Id=@CreativeMasterID)
	BEGIN
	   Set @IsCreativeExists=1
	END
	ELSE
	BEGIN
	Set @IsCreativeExists=0
	END
	Select @IsCreativeExists As IsCreativeExists
END