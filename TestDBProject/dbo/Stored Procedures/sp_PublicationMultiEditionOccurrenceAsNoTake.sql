


-- ======================================================================================
-- Author            : Arun Nair 
-- Create date       : 
-- Description       : Update Occurrence As NoTake in Publication
-- Updated By		 : Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionOccurrenceAsNoTake]
( 
 @OccurrenceId AS BigInt,
@Configurationid as integer
) 
AS
BEGIN  
       SET NOCOUNT ON;
              DECLARE @PubissueId AS INT 
        BEGIN TRY 
					declare @NoTakeStatusID int
					select @NoTakeStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

                     BEGIN TRANSACTION                 
                     UPDATE [OccurrenceDetailPUB] SET OccurrenceStatusID = @NoTakeStatusID, 
                      NoTakeReason=(SELECT value FROM [Configuration] WHERE configurationid=@configurationID) 
                      WHERE [OccurrenceDetailPUBID]=@OccurrenceId   

                     COMMIT TRANSACTION 
        END TRY 
		BEGIN CATCH 
		  DECLARE @error INT,@message VARCHAR(4000), @lineNo      INT 
		  SELECT @error = Error_number(),@message = Error_message(),  @lineNo = Error_line();
			  RAISERROR ('[sp_PublicationMultiEditionOccurrenceAsNoTake]: %d: %s',16,1,@error,@message,@lineNo);        
		  ROLLBACK TRANSACTION 
		END CATCH 
END