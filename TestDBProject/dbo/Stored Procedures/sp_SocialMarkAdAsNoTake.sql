-- ==============================================================================================
-- Author		: KARUNAKAR
-- Create date	: 11/26/2015
-- Description	: Mark Adid as Notake Ad in Social
-- UpdatedBy	: [dbo].[sp_SocialMarkAdAsNoTake] 10459,158
--				: Karunakar on 11/27/2015,Mark ad as No Take then Making all Occurrences Status will be NO Take
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_SocialMarkAdAsNoTake] 
(
	@AdId int,
	@NoTakeReasonCode int
)
AS
BEGIN	
	SET NOCOUNT ON;
		   BEGIN TRY

			   --Declare @Status AS NVARCHAR(50)
			   Declare @NotakeReason AS NVARCHAR(50)
				DECLARE @PrimaryOccrncId As INTEGER
				Update Ad SET NoTakeAdReason=@NoTakeReasonCode WHERE [AdID]=@AdId

				
				--SELECT @Status=ValueTitle  FROM   [Configuration]  WHERE SystemName='All' and Componentname='Occurrence Status' and Value='NT'
				declare @NoTakeStatusID int
				select @NoTakeStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
				SELECT @NotakeReason=ValueTitle  FROM   [Configuration]  WHERE ConfigurationID=@NoTakeReasonCode and SystemName='All'
				--Update OccurrenceNoTake 
				Print(@NotakeReason)
				SELECT @PrimaryOccrncId=[PrimaryOccurrenceID] FROM AD WHERE [AdID]=@AdId
				UPDATE [dbo].[OccurrenceDetailSOC] 
				SET 
				OccurrenceStatusID = @NoTakeStatusID,
				NoTakeReason = @NotakeReason 
				WHERE [AdID] = @AdId

		   END TRY
		   BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialMarkAdAsNoTake]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END