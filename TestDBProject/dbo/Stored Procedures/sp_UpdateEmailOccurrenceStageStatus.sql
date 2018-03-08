-- =====================================================================
-- Author		: RP  
-- Create date	: 3rd November 2015   
-- Execute      : [dbo].[sp_UpdateEmailOccurrenceStageStatus] 
-- Description	:  Update Occurrence Status  
-- Updated By	: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--======================================================================

CREATE PROCEDURE [dbo].sp_UpdateEmailOccurrenceStageStatus 
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
		  --Get Statusvalues from ConfigurationMaster
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


		  --Get Status from OccurrenceTable for occurrenceid
			  SELECT @MapReqdStageStatusID = MapStatusID,@IndexReqdStageStatusID = IndexStatusID,@ScanReqdStageStatusID = ScanStatusID,
					 @QCReqdStageStatusID = QCStatusID,@RouteReqdStageStatusID = RouteStatusID 
			  FROM   [OccurrenceDetailEM] WHERE  [OccurrenceDetailEMID] = @OccurrenceID 

          IF @stage = 2  --Update Status for Occurrencetable 
            BEGIN 
                IF @ScanReqdStageStatusID <> @WaitingStatusID  AND @QCReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailEM]  SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID 
					  WHERE  [OccurrenceDetailEMID] IN( @occurrenceid ) 
                  END 
                ELSE 
                  BEGIN 
				      UPDATE [OccurrenceDetailEM] SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
                  END 
            END 

          IF @stage =3  --Update Status
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID AND @QCReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailEM] SET    ScanStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid  
                  END 
                ELSE 
                  BEGIN				  
                      UPDATE [OccurrenceDetailEM] SET    ScanStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
                  END 
            END 

          IF @stage =4  --Update Status
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID AND @ScanReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID
                  BEGIN 
					 UPDATE [OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
                  END
            END 
				COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_UpdateEmailOccurrenceStageStatus]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
      END CATCH 

  END