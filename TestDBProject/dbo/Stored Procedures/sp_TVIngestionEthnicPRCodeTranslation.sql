-- ========================================================================
-- Author: Nagarjuna
-- Create date: 09/04/2015
-- Description:	This stored procedure deals with Ethnic PR Code Translation
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_TVIngestionEthnicPRCodeTranslation]
	@MTStationId int,
	@OriginalPRCode varchar(20),
	@EthnicPRCode varchar(20) output
AS
BEGIN
	SET NOCOUNT ON;

	 BEGIN TRY 
          BEGIN TRANSACTION 

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
				if (@ethnicGroupId <> -1 and @ethnicGroupId != 2) -- To be confimred with David Arnett which groupid equals to non-english
				BEGIN
					-- Translation only of EthnicGroupID is non-english
					select @EthnicPRCode = [TVEthnicPRCodeID] from [TVEthnicPRCode] where [EthnicGroupID] = @ethnicGroupId and OriginalPRCode = @OriginalPRCode
					if (@EthnicPRCode = @OriginalPRCode)
					BEGIN
						select @MaxPRCode=Max(SUBString([TVEthnicPRCodeID], 1,8)) from [TVEthnicPRCode]
						if (@MaxPRCode is null)
						BEGIN
						  select @MaxPRCode = 10000000
						END
						select @EthnicPRCode = CONCAT(CONVERT(INT,@MaxPRCode) + 1,'.ETH')
						insert into [TVEthnicPRCode] values(@EthnicPRCode,@ethnicGroupId,@OriginalPRCode,getdate())
					END
					print 'Ethnic PR Code : ' + @EthnicPRCode
				END
			END
			select @EthnicPRCode

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_TVIngestionEthnicPRCodeTranslation: %d: %s',16,1,@Error,@Message,@LineNo); 

          ROLLBACK TRANSACTION 
      END CATCH; 	
END