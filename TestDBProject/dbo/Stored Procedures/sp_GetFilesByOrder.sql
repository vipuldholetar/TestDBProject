
-- =============================================
-- Author:		SURESH N
-- Create date: 09/12/2015
-- Description:	Get Files by order using OccurrenceID
--Execution :   EXEC sp_GetFilesByOrder 510005
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetFilesByOrder]
	-- Add the parameters for the stored procedure here
	@OccurrenceID BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Mediastream varchar(50)
	
	SET @Mediastream=(SELECT dbo.fn_GetMediaStream(@OccurrenceID));

	if @Mediastream='CIR'
	begin
	SELECT CreativeMasterID,CreativeAssetName,PageNumber FROM CreativeDetailCIR WHERE CreativeMasterID in (SELECT [Pattern].[CreativeID] FROM [OccurrenceDetailCIR] inner join [Pattern] ON
   [OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID] and [OccurrenceDetailCIRID]=@OccurrenceID)
   end
	else if @Mediastream='PUB'
	begin
	SELECT CreativeMasterID,CreativeAssetName,PageNumber FROM CreativeDetailPUB WHERE CreativeMasterID in (SELECT [Pattern].[CreativeID] FROM [OccurrenceDetailPUB] inner join [Pattern] ON
   [OccurrenceDetailPUB].[PatternID]=[Pattern].[PatternID] and [OccurrenceDetailPUBID]=@OccurrenceID)
   end
   else if @Mediastream='EM'
	begin
	SELECT CreativeMasterID,CreativeAssetName,PageNumber FROM CreativeDetailEM WHERE CreativeMasterID in (SELECT [Pattern].[CreativeID] FROM [OccurrenceDetailEM] inner join [Pattern] ON
   [OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID] and [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceID)
   end
   else if @Mediastream='SOC'
	begin
	SELECT CreativeMasterID,CreativeAssetName,PageNumber FROM CreativeDetailSOC WHERE CreativeMasterID in (SELECT [Pattern].[CreativeID] FROM [OccurrenceDetailSOC] inner join [Pattern] ON
   [OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID] and [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=@OccurrenceID)
   end
   else if @Mediastream='WEB'
	begin
	SELECT CreativeMasterID,CreativeAssetName,PageNumber FROM CreativeDetailWEB WHERE CreativeMasterID in (SELECT [Pattern].[CreativeID] FROM [OccurrenceDetailWEB] inner join [Pattern] ON
   [OccurrenceDetailWEB].[PatternID]=[Pattern].[PatternID] and [OccurrenceDetailWEB].[OccurrenceDetailWEBID]=@OccurrenceID)
   end
END
