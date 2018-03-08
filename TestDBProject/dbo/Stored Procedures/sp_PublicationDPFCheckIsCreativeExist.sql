
-- ===============================================================================================
-- Author			: KARUNAKAR
-- Create date		: 2nd July 2015
-- Description		: This stored procedure is used to Check the Ad Id Exist in  Creative Master 
-- Execution Process:  sp_PublicationDPFCheckIsCreativeExist 8071
--UpdatedBy			: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFCheckIsCreativeExist]
	@AdId As Int
AS
BEGIN
	SET NOCOUNT ON;
	Declare @IsCreativeExists As  Bit

	if Exists(Select 1 from [Creative] Where [AdId]=@Adid)
	BEGIN
	   Set @IsCreativeExists=1
	END
	ELSE
	BEGIN
	Set @IsCreativeExists=0
	END
	Select @IsCreativeExists As IsCreativeExists
END
