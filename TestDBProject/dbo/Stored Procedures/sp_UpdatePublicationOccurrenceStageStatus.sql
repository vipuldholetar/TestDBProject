-- =====================================================================
-- Author		: RP  
-- Create date	: 18 May 2015   
-- Execute      : [dbo].[sp_UpdatePublicationOccurrenceStageStatus] 
-- Description	:  Update Occurrence Status  
-- Updated By	: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--======================================================================

CREATE PROCEDURE [dbo].[sp_UpdatePublicationOccurrenceStageStatus] 
(
@OccurrenceID AS VARCHAR(10), 
@Stage        AS INT
) 

AS 

  BEGIN 

      SET NOCOUNT ON; 

      DECLARE @MTCTBoth AS VARCHAR(2) 

      DECLARE @WaitingStatusID AS INT = 0
      DECLARE @InProgressStatusID AS INT = 0
      DECLARE @NoTakeStatusID AS INT = 0
      DECLARE @NotRequiredStatusID AS INT = 0
      DECLARE @RequiredStatusID AS INT = 0
      DECLARE @CompleteStatusID AS INT = 0

      DECLARE @MapReqdStageStatusID AS INT = 0
      DECLARE @IndexReqdStageStatusID AS INT = 0
      DECLARE @ScanReqdStageStatusID AS INT = 0
      DECLARE @QCReqdStageStatusID AS INT  = 0
      DECLARE @RouteReqdStageStatusID AS INT  = 0

	  DECLARE @WAITINGSCANSTATUS AS INT=0
	  DECLARE @COMPLETESCANSTATUS AS INT=0
	  DECLARE @NOTREQSCANSTATUS AS INT =0

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



			SELECT @WAITINGSCANSTATUS = ss.[ScanStatusID] 
			from ScanStatus ss
			inner join Configuration c on ss.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Scan Status' AND c.Value = 'w' 

			SELECT @COMPLETESCANSTATUS = ss.[ScanStatusID] 
			from ScanStatus ss
			inner join Configuration c on ss.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Scan Status' AND c.Value = 'C' 

			SELECT @NOTREQSCANSTATUS = ss.[ScanStatusID] 
			from ScanStatus ss
			inner join Configuration c on ss.[Status] = c.ValueTitle
			where c.SystemName = 'All' and c.ComponentName = 'Scan Status' AND c.Value = 'NR' 



		  --Get Status from OccurrenceTable for occurrenceid
			  SELECT @MapReqdStageStatusID = MapStatusID,@IndexReqdStageStatusID = IndexStatusID,@ScanReqdStageStatusID = ScanStatusID,
					 @QCReqdStageStatusID = QCStatusID,@RouteReqdStageStatusID = RouteStatusID 
			  FROM   [OccurrenceDetailPUB] WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 

          IF @stage = 2  --Update Status for Occurrencetable 
            BEGIN 
                IF @ScanReqdStageStatusID <> @WaitingStatusID  AND @QCReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB]  SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID 
					  WHERE  [OccurrenceDetailPUBID] IN( @occurrenceid ) 
                  END 
                ELSE 
                  BEGIN 
				      UPDATE [OccurrenceDetailPUB] SET    MapStatusID = @CompleteStatusID,IndexStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
                  END 
            END 

          IF @stage =3  --Update Status
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID AND  @RouteReqdStageStatusID <> @WaitingStatusID --@QCReqdStageStatusID <> @WaitingStatusID AND --L.E. MI-977 after scan and index set occurrence as complete
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] SET    ScanStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid  
                  END 
                ELSE 
                  BEGIN				  
                      UPDATE [OccurrenceDetailPUB] SET    ScanStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
                  END 
            END 

          IF @stage =4  --Update Status
            BEGIN 
                IF @MapReqdStageStatusID <> @WaitingStatusID AND @ScanReqdStageStatusID <> @WaitingStatusID AND @RouteReqdStageStatusID <> @WaitingStatusID
                  BEGIN 
					 UPDATE [OccurrenceDetailPUB] SET    QCStatusID = @CompleteStatusID,OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] SET    QCStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
                  END
            END 
			--L.E. 3.16.17 new stages for mapped scan status and new ad scan status MI-977
			IF @stage =5  --Update New Add Scan Status to waiting 
            BEGIN 
					 UPDATE [OccurrenceDetailPUB] SET    ScanStatusID = @WAITINGSCANSTATUS WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
            END 


			IF @stage =6  --Update Map Add Status  --Update Scan status of Map to Not required and occ status complete  
			BEGIN
				UPDATE [OccurrenceDetailPUB] SET     ScanStatusID = @NOTREQSCANSTATUS, OccurrenceStatusID = @CompleteStatusID WHERE  [OccurrenceDetailPUBID] = @occurrenceid  
            END 

				COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_UpdatePublicationOccurrenceStageStatus]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
      END CATCH 

  END