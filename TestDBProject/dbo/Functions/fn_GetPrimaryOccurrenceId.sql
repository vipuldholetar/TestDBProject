

-- =============================================================
-- Author                  :  Arun Nair
-- Create date             :  08/21/2015
-- Description             :  Get Primary OccurrenceId
-- Execution Process	   : 
-- =============================================================
CREATE FUNCTION [dbo].[fn_GetPrimaryOccurrenceId]
(
@Creativesignature AS NVARCHAR(MAX)
)
RETURNS  INTEGER
AS
BEGIN

	DECLARE @OccId  INTEGER
	IF(@Creativesignature <>'')
	BEGIN
		SELECT @OccId=[OccurrenceID] FROM [dbo].[CreativeStaging] 
		INNER JOIN [dbo].[CreativeDetailStagingRA]  ON [dbo].[CreativeStaging].[CreativeStagingID]=[dbo].[CreativeDetailStagingRA].[CreativeStgID]
		WHERE  [OccurrenceID] in (SELECT [OccurrenceDetailRAID] FROM [dbo].[OccurrenceDetailRA] 
		WHERE [RCSAcIdID] in (SELECT [RCSAcIdToRCSCreativeIdMapID] FROM [dbo].[RCSAcIdToRCSCreativeIdMap] WHERE [RCSCreativeID]=@CreativeSignature)) 		
	END 
	RETURN @OccId 
END
