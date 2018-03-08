-- ============================================================================
-- Author		: RP  
-- Create date	: 18 May 2015   
-- Execution	:
-- Description	:  Update Occurrence Status  
-- Updated By	: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--================================================================================  

CREATE PROCEDURE [dbo].[sp_UpdateOccurrenceStageStatus] 
(
@OccurrenceID AS VARCHAR(10),
@Stage        AS INT
) 

AS 

  BEGIN 

      SET NOCOUNT ON; 

      DECLARE @MTCTBoth AS VARCHAR(2)

      DECLARE @WaitingStatusID AS INT 
      DECLARE @InProgressStatusID AS INT
      DECLARE @NoTakeStatusID AS INT
      DECLARE @NotRequiredStatusID AS INT
      DECLARE @RequiredStatusID AS INT
      DECLARE @CompleteStatusID AS INT

      DECLARE @MapReqdStageStatusID AS INT
      DECLARE @IndexReqdStageStatusID AS INT
      DECLARE @ScanReqdStageStatusID AS INT
      DECLARE @QCReqdStageStatusID AS INT 
      DECLARE @RouteReqdStageStatusID AS INT 

      BEGIN TRY 
          BEGIN TRANSACTION 
			select @WaitingStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'W' 

			select @InProgressStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'P' 

			select @NoTakeStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

			select @NotRequiredStatusID = os.[RouteStatusID] 
			from RouteStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Route Status' AND c.Value = 'NR' 

			select @CompleteStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

			select @RequiredStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'R' 

          SELECT @MapReqdStageStatusID = MapStatusID, 
                 @IndexReqdStageStatusID = IndexStatusID, 
                 @ScanReqdStageStatusID = ScanStatusID, 
                 @QCReqdStageStatusID = QCStatusID, 
                 @RouteReqdStageStatusID = RouteStatusID 
          FROM   [OccurrenceDetailCIR] 
          WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 

          IF @stage = 2 
            BEGIN 
                IF @ScanReqdStageStatusID <> @WaitingStatusID 
                   AND @QCReqdStageStatusID <> @WaitingStatusID 
                   AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    MapStatusID = @CompleteStatusID, 
                             IndexStatusID = @CompleteStatusID, 
                             OccurrenceStatusID = @CompleteStatusID 
                      WHERE  [OccurrenceDetailCIRID] IN( @occurrenceid ) 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    MapStatusID = @CompleteStatusID, 
                             IndexStatusID = @CompleteStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
                  END 
            END 

          IF @stage =3 
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID 
                   AND @QCReqdStageStatusID <> @WaitingStatusID 
                   AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    ScanStatusID = @CompleteStatusID, 
                             OccurrenceStatusID = @CompleteStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @occurrenceid  
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    ScanStatusID = @CompleteStatusID
                       WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
                  END 
            END 
			
          IF @stage =4
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID 
                   AND @ScanReqdStageStatusID <> @WaitingStatusID 
                   AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    QCStatusID = @CompleteStatusID, 
                             OccurrenceStatusID = @CompleteStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @occurrenceid  
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    QCStatusID = @CompleteStatusID
                       WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
                  END 
            END 
          COMMIT TRANSACTION 
      END TRY 
      BEGIN CATCH
          DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_UpdateOccurrenceStatus]: %d: %s',16,1,@error,@message,@lineNo); 
		  ROLLBACK TRANSACTION 
      END CATCH 
  END