

-- ==============================================================================================
-- Author		: Arun Nair
-- Create date	: 11/12/2015
-- Description	: Mark Adid as Notake Ad in Website
-- UpdatedBy	: [dbo].[sp_WebsiteMarkAdAsNoTake] 10459,158
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_WebsiteMarkAdAsNoTake] 
(
	@AdId int,
	@NoTakeReasonCode int
)
AS
BEGIN	
	SET NOCOUNT ON;
		   BEGIN TRY

			   Declare @NotakeReason AS NVARCHAR(50)
				DECLARE @PrimaryOccrncId As INTEGER
				Update Ad SET NoTakeAdReason=@NoTakeReasonCode WHERE [AdID]=@AdId

				declare @NoTakeStatusID int
				select @NoTakeStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

				SELECT @NotakeReason=ValueTitle  FROM   [Configuration]  WHERE ConfigurationID=@NoTakeReasonCode and SystemName='All'
				--Update OccurrenceNoTake 
				Print(@NotakeReason)
				SELECT @PrimaryOccrncId=[PrimaryOccurrenceID] FROM AD WHERE [AdID]=@AdId
				UPDATE [dbo].[OccurrenceDetailWEB] 
				SET 
				OccurrenceStatusID = @NoTakeStatusID,
				NoTakeReason=@NotakeReason 
				WHERE [OccurrenceDetailWEBID] = @PrimaryOccrncId

		   END TRY
		   BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_WebsiteMarkAdAsNoTake]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END