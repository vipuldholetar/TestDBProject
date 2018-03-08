-- =====================================================================================================
-- Author			: RP 
-- Create date		: 18 May 2015  
-- Description		: Update Occurrence Status  
-- Updated By		: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--					: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=======================================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateOccurrenceStatus] 
(
@OccurrenceID    AS BIGINT, 
@IsNewOccurrence AS BIT
) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @MTCTBoth AS VARCHAR(2) 
      --DECLARE @WaitingStatus AS VARCHAR(20) 
      --DECLARE @InProgressStatus AS VARCHAR(20) 
      --DECLARE @NoTakeStatus AS VARCHAR(20) 
      --DECLARE @NotRequiredStatus AS VARCHAR(20) 
      --DECLARE @RequiredStatus AS VARCHAR(20) 
      --DECLARE @CompleteStatus AS VARCHAR(20) 
      DECLARE @IsRequiredStatus AS INT 
      DECLARE @MapReqdIndicator AS BIT 
      DECLARE @IndexReqdIndicator AS BIT 
      DECLARE @ScanReqdIndicator AS BIT 
      DECLARE @QCReqdIndicator AS BIT 
      DECLARE @RouteReqdIndicator AS BIT 

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

          SELECT @MTCTBoth = b.mtctboth 
          FROM   expectation a, 
                 printmtctmap b, 
                 [OccurrenceDetailCIR] c, 
                 pubedition d 
          WHERE  c.[PubEditionID] = d.[PubEditionID] 
                 AND a.[MediaID] = c.[MediaTypeID] 
                 AND a.[MarketID] = c.[MarketID] 
                 AND a.[RetailerID] = c.[AdvertiserID] 
                 AND b.[ExpectationID] = a.expectationid 
                 AND b.[PublicationID] = d.[PublicationID] 
                 AND b.[LanguageID] = c.[LanguageID] 
                 AND c.[OccurrenceDetailCIRID] = @OccurrenceID 

          IF @MTCTBoth IS NULL 
            BEGIN 
                SET @MTCTBoth='MT' 
            END 

          PRINT( @MTCTBoth ) 

          SELECT @IsRequiredStatus = Count(1) 
          FROM   [ConfigurationReqdStage] 
          WHERE  mtctboth = @MTCTBoth 
                 AND [NewAdInd] = @IsNewOccurrence 

          PRINT( @IsRequiredStatus ) 

          IF @IsRequiredStatus = 0 
            BEGIN 
                UPDATE [OccurrenceDetailCIR] 
                SET    MapStatusID = @RequiredStatusID, 
                       IndexStatusID = @RequiredStatusID, 
                       ScanStatusID = @RequiredStatusID, 
                       QCStatusID = @RequiredStatusID, 
                       RouteStatusID = @RequiredStatusID 
                WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
            END 
          ELSE 
            BEGIN 
                SELECT @MapReqdIndicator = [MapReqdInd], 
                       @IndexReqdIndicator = [IndexReqdInd], 
                       @ScanReqdIndicator = [ScanReqdInd], 
                       @QCReqdIndicator = [QCReqdInd], 
                       @RouteReqdIndicator = [RouteReqdInd] 
                FROM   [ConfigurationReqdStage] 
                WHERE  mtctboth = @MTCTBoth 
                       AND [NewAdInd] = @IsNewOccurrence 

                -- Update MapStatus 
                IF ( @MapReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    MapStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    MapStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 

                -- Update Index Status 
                IF ( @IndexReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    IndexStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    IndexStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 

                -- Update Scan Status 
                IF ( @ScanReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    ScanStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    ScanStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 

                -- Update QC Status 
                IF ( @QCReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    QCStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    QCStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 

                -- Update Route Status 
                IF ( @RouteReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    RouteStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailCIR] 
                      SET    RouteStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceID 
                  END 
            END 

          IF @RouteReqdIndicator = 'false' 
             AND @QCReqdIndicator = 'false' 
             AND @ScanReqdIndicator = 'false' 
             AND @IndexReqdIndicator = 'false' 
             AND @MapReqdIndicator = 'false' 
            BEGIN 
                UPDATE [OccurrenceDetailCIR] 
                SET    OccurrenceStatusID = @CompleteStatusID 
                WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
            END 
          ELSE 
            BEGIN 
                UPDATE [OccurrenceDetailCIR] 
                SET    OccurrenceStatusID = @InProgressStatusID 
                WHERE  [OccurrenceDetailCIRID] = @occurrenceid 
            END 

          COMMIT TRANSACTION 
      END TRY 
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		  RAISERROR ('[sp_UpdateOccurrenceStatus]: %d: %s',16,1,@error,@message,@lineNo); 
		  ROLLBACK TRANSACTION 
      END CATCH 
  END