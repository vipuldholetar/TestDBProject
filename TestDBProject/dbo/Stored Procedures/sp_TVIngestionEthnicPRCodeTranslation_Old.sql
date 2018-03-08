-- ========================================================================
-- Author: 
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with Ethnic PR Code Translation
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionEthnicPRCodeTranslation_Old]
	@MTStationId int,
	@OriginalPRCode varchar(20),
	@EthnicPRCode varchar(20) output
AS
BEGIN
	SET NOCOUNT ON;
	select @EthnicPRCode = @OriginalPRCode

	declare @ethnicGroupId int
	declare @MaxPRCode int

	select @ethnicGroupId = -1
	
	-- Check if record exist for MTStationID
	if (exists(select EthnicGroupId from [TVStation] where [TVStationID] = @MTStationId))
	BEGIN
		print 'MT StationID exists  : ' + convert(varchar(25),@MTStationId)
		-- Check if Ethnic GroupID exist for MtStationId
		select @ethnicGroupId = isnull(EthnicGroupId,-1) from [TVStation] where [TVStationID] = @MTStationId
		print 'EthnicGroup ID : ' + convert(varchar(25),@ethnicGroupId)
		if (@ethnicGroupId <> -1 and @ethnicGroupId != 1) -- To be confimred with David Arnett which groupid equals to non-english
		BEGIN
			-- Translation only of EthnicGroupID is non-english
			select @EthnicPRCode = [TVEthnicPRCodeID] from [TVEthnicPRCode] where [EthnicGroupID] = @ethnicGroupId and OriginalPRCode = @OriginalPRCode
			if (@EthnicPRCode = @OriginalPRCode)
			BEGIN
				select @MaxPRCode=Max(SUBString([TVEthnicPRCodeID], 1,8)) from [TVEthnicPRCode]
				select @EthnicPRCode = CONCAT(CONVERT(INT,@MaxPRCode) + 1,'.ETH')
				insert into [TVEthnicPRCode] values(@EthnicPRCode,@ethnicGroupId,@OriginalPRCode,getdate())
			END
			print 'Ethnic PR Code : ' + @EthnicPRCode
		END
	END
	select @EthnicPRCode
END
