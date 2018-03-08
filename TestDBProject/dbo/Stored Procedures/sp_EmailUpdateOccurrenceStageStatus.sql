-- ============================================================================
-- Author		: Arun Nair 
-- Create date	: 10/26/2015
-- Execution	:
-- Description	:  Update Occurrence Status  for Email
-- Updated By	: 
--================================================================================  

CREATE PROCEDURE [dbo].[sp_EmailUpdateOccurrenceStageStatus]--2022,4
(
@OccurrenceID AS VARCHAR(10),
@Stage        AS INT
) 

AS 

  BEGIN 

      SET NOCOUNT ON; 

      DECLARE @MTCTBoth AS VARCHAR(2)
      --DECLARE @WaitingStatus AS VARCHAR(20) 
      --DECLARE @InProgressStatus AS VARCHAR(20)
      --DECLARE @NoTakeStatus AS VARCHAR(20)
      --DECLARE @NotRequiredStatus AS VARCHAR(20)
      --DECLARE @RequiredStatus AS VARCHAR(20) 
      --DECLARE @CompleteStatus AS VARCHAR(20)
      --DECLARE @MapReqdStageStatus AS VARCHAR(20) 
      --DECLARE @IndexReqdStageStatus AS VARCHAR(20) 
      --DECLARE @ScanReqdStageStatus AS VARCHAR(20) 
      --DECLARE @QCReqdStageStatus AS VARCHAR(20)
      --DECLARE @RouteReqdStageStatus AS VARCHAR(20) 

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

          --SELECT @WaitingStatus = ValueTitle FROM   [Configuration]  WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'W' 
          --SELECT @InProgressStatus = ValueTitle FROM   [Configuration] WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'P' 
          --SELECT @NoTakeStatus = ValueTitle FROM   [Configuration] WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'NT' 
          --SELECT @NotRequiredStatus = ValueTitle  FROM   [Configuration] WHERE  Systemname = 'All'  AND Componentname = 'Route Status'  AND value = 'NR' 
          --SELECT @CompleteStatus = ValueTitle FROM   [Configuration]  WHERE  Systemname = 'All'  AND Componentname = 'Occurrence Status'  AND value = 'C' 
          --SELECT @RequiredStatus = ValueTitle FROM   [Configuration]  WHERE  Systemname = 'All'  AND Componentname = 'Occurrence Status' AND value = 'R'
		  
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
		  
			select @RequiredStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 
		  
			select @CompleteStatusID = os.[OccurrenceStatusID] 
			from OccurrenceStatus os
			inner join Configuration c on os.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'R' 



          SELECT 
		  @MapReqdStageStatusID = MapStatusID, 
		  @IndexReqdStageStatusID = IndexStatusID,  
		  @ScanReqdStageStatusID = ScanStatusID,  
		  @QCReqdStageStatusID = QCStatusID, 
          @RouteReqdStageStatusID = RouteStatusID  
		  FROM [dbo].[OccurrenceDetailEM] 
		  WHERE  [OccurrenceDetailEMID] = @OccurrenceID 

          IF @stage = 2 
            BEGIN 
                IF (@ScanReqdStageStatusID <> @WaitingStatusID    AND @QCReqdStageStatusID <> @WaitingStatusID  AND @RouteReqdStageStatusID <> @WaitingStatusID )
                  BEGIN 
                      UPDATE [dbo].[OccurrenceDetailEM] SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID
                      WHERE  [ParentOccurrenceID] =@OccurrenceID

					  UPDATE [dbo].[OccurrenceDetailEM] SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID
                      WHERE  [OccurrenceDetailEMID] =@OccurrenceID

                  END 
                ELSE 
                  BEGIN 
				  UPDATE [dbo].[OccurrenceDetailEM] SET    MapStatusID = @CompleteStatusID, IndexStatusID = @CompleteStatusID  WHERE   [ParentOccurrenceID] =@OccurrenceID
                  UPDATE [dbo].[OccurrenceDetailEM] SET    MapStatusID = @CompleteStatusID, IndexStatusID = @CompleteStatusID  WHERE  [OccurrenceDetailEMID] = @occurrenceid 
                  END 
            END 
          IF @stage =3 
            BEGIN 
                IF(@MapReqdStageStatusID <> @WaitingStatusID AND @QCReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID)
                  BEGIN 
                      UPDATE [dbo].[OccurrenceDetailEM] SET    ScanStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [ParentOccurrenceID] = @occurrenceid 
					   UPDATE [dbo].[OccurrenceDetailEM] SET    ScanStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid   
                  END 
                ELSE 
                  BEGIN
                      UPDATE [dbo].[OccurrenceDetailEM]  SET    ScanStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
					   UPDATE [dbo].[OccurrenceDetailEM]  SET    ScanStatusID = @CompleteStatusID WHERE  [ParentOccurrenceID] =@OccurrenceID
                  END 
            END 			
          IF @stage =4
            BEGIN 
                IF (@MapReqdStageStatusID <> @WaitingStatusID  AND @ScanReqdStageStatusID <> @WaitingStatusID  AND @RouteReqdStageStatusID <> @WaitingStatusID) 
                  BEGIN 
                      UPDATE [dbo].[OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID,  OccurrenceStatusID = @CompleteStatusID  WHERE  [ParentOccurrenceID] = @occurrenceid
					     UPDATE [dbo].[OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID,  OccurrenceStatusID = @CompleteStatusID  WHERE  [OccurrenceDetailEMID] = @occurrenceid  
                  END 
                ELSE 
                  BEGIN 
					  UPDATE [dbo].[OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID WHERE  [OccurrenceDetailEMID] = @occurrenceid 
					  UPDATE [dbo].[OccurrenceDetailEM] SET    QCStatusID = @CompleteStatusID WHERE  [ParentOccurrenceID] =@OccurrenceID
                  END 

            END 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH
          DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_EmailUpdateOccurrenceStageStatus]: %d: %s',16,1,@error,@message,@lineNo); 
		  ROLLBACK TRANSACTION 
      END CATCH 

  END