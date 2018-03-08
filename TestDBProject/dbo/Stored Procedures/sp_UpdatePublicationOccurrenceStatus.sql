-- ===========================================================================================
-- Author			: RP 
-- Create date		: 18 May 2015  
-- Description		: Update Occurrence Status  
-- Updated By		: iyub on 07/01/2015 changed ConfigurationMaster  LOV
--					  Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=============================================================================================
CREATE PROCEDURE [dbo].[sp_UpdatePublicationOccurrenceStatus] 
(
@OccurrenceID    AS BIGINT,
@IsNewOccurrence AS BIT
) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @MTCTBoth AS VARCHAR(2) 
      DECLARE @WaitingStatusID AS INT 
      DECLARE @InProgressStatusID AS INT
      DECLARE @NoTakeStatusID AS INT
      DECLARE @NotRequiredStatusID AS INT
      DECLARE @RequiredStatusID AS INT
      DECLARE @CompleteStatusID AS INT
      DECLARE @IsRequiredStatus AS INT 
      DECLARE @MapReqdIndicator AS BIT 
      DECLARE @IndexReqdIndicator AS BIT 
      DECLARE @ScanReqdIndicator AS BIT 
      DECLARE @QCReqdIndicator AS BIT 
      DECLARE @RouteReqdIndicator AS BIT 

      BEGIN try 
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

          SELECT @MTCTBoth = b.mtctboth FROM   expectation a,printmtctmap b,[OccurrenceDetailPUB] c ,PubEdition e,PubIssue f,ad d                
          WHERE  
                 a.[MediaID] = c.[MediaTypeID] 
                 AND a.[MarketID] = c.[MarketID] 
                 AND b.[ExpectationID] = a.expectationid 
                 and d.[AdID]=c.[AdID]
				 and a.[RetailerID]=d.[AdvertiserID]
				 and b.[PublicationID]=e.[PublicationID]
				 and b.[LanguageID]=e.[LanguageID]
				 and c.[PubIssueID]=f.[PubIssueID]
				 and e.[PubEditionID]=f.[PubEditionID]
                 AND c.[OccurrenceDetailPUBID] = @OccurrenceID 

          IF @MTCTBoth IS NULL 
            BEGIN 
                SET @MTCTBoth='MT' 
            END 

          --PRINT( @MTCTBoth ) 

          SELECT @IsRequiredStatus = Count(1) FROM   [ConfigurationReqdStage] WHERE  mtctboth = @MTCTBoth AND [NewAdInd] = @IsNewOccurrence 

          --PRINT( @IsRequiredStatus ) 

          IF @IsRequiredStatus = 0 
            BEGIN 
                UPDATE [OccurrenceDetailPUB] 
                SET    MapStatusID = @RequiredStatusID, 
                       IndexStatusID = @RequiredStatusID, 
                       ScanStatusID = @RequiredStatusID, 
                       QCStatusID = @RequiredStatusID, 
                       RouteStatusID = @RequiredStatusID 
                WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
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
                      UPDATE [OccurrenceDetailPUB] 
                      SET    MapStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    MapStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 

                -- Update Index Status 
                IF ( @IndexReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    IndexStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    IndexStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 

                -- Update Scan Status 
                IF ( @ScanReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    ScanStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    ScanStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 

                -- Update QC Status 
                IF ( @QCReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    QCStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    QCStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 

                -- Update Route Status 
                IF ( @RouteReqdIndicator = 'true' ) 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    RouteStatusID = @WaitingStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE [OccurrenceDetailPUB] 
                      SET    RouteStatusID = @NotRequiredStatusID 
                      WHERE  [OccurrenceDetailPUBID] = @OccurrenceID 
                  END 
            END 

          IF @RouteReqdIndicator = 'false' 
             AND @QCReqdIndicator = 'false' 
             AND @ScanReqdIndicator = 'false' 
             AND @IndexReqdIndicator = 'false' 
             AND @MapReqdIndicator = 'false' 
            BEGIN 
                UPDATE [OccurrenceDetailPUB] 
                SET    OccurrenceStatusID = @CompleteStatusID 
                WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
            END 
          ELSE 
            BEGIN 
                UPDATE [OccurrenceDetailPUB] 
                SET    OccurrenceStatusID = @InProgressStatusID 
                WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
            END 

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_UpdatePublicationOccurrenceStatus]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END