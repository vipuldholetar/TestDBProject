-- ====================================================================================================================
-- Author:  Karunakar P
-- Create date: 11 June 2015  
-- Description:   Update Occurrence Status for OccurrenceDetailPub
-- Updated By : Updated Changes Based on Configuration Master table LOV on 01 july 2015 By Karunakar
-- Updated By : Updated Changes Based on Clean Up of ONE MT DB  Ad table  on 17th August 2015 By Karunakar.
--			  : Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--========================================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFOccurrenceStatus] 
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


	  BEGIN try 
          BEGIN TRANSACTION 

          --SELECT @WaitingStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Occurrence Status' 
          --       AND value = 'W' 

          --SELECT @InProgressStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Occurrence Status' 
          --       AND value = 'P' 

          --SELECT @NoTakeStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Occurrence Status' 
          --       AND value = 'NT' 

          --SELECT @NotRequiredStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Scan Status' 
          --       AND value = 'NR' 

          --SELECT @CompleteStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Occurrence Status' 
          --       AND value = 'C' 

          --SELECT @RequiredStatus = valuetitle 
          --FROM   [Configuration] 
          --WHERE  systemname = 'All' 
          --       AND componentname = 'Occurrence Status' 
          --       AND value = 'R' 

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

		select @NotRequiredStatusID = os.[ScanStatusID] 
		from ScanStatus os
		inner join Configuration c on os.[Status] = c.ValueTitle
		where c.SystemName = 'All' and c.ComponentName = 'Scan Status' AND c.Value = 'NR' 

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
                 [OccurrenceDetailPUB] c,
				 Ad d, 
                 pubedition e,
				 PubIssue f 
          WHERE  c.[AdID]=d.[AdID] 
			 And c.[PubIssueID]=f.[PubIssueID]
			 And e.[PubEditionID]=f.[PubEditionID]
			 And a.[MediaID]=c.[MediaTypeID]
			 And a.[MarketID] = c.[MarketID]
			 And a.[RetailerID] = d.[AdvertiserID]
			 And b.[ExpectationID]=a.expectationid
			 and b.[PublicationID]=e.[PublicationID]
			 and b.[LanguageID]=e.[LanguageID]	  


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
                UPDATE [OccurrenceDetailPUB] 
                SET   
				     -- mapstatus = @requiredStatus, 
                     -- indexstatus = @requiredStatus, 
                       ScanStatusID = @RequiredStatusID, 
                       QCStatusID = @RequiredStatusID, 
                       RouteStatusID = @RequiredStatusID 
                WHERE  [OccurrenceDetailPUBID] = @occurrenceid 
            END 
          ELSE 
            BEGIN 
                SELECT 
				      --@MapReqdIndicator = mapreqdindicator, 
                      --@IndexReqdIndicator = indexreqdindicator, 
                       @ScanReqdIndicator = [ScanReqdInd], 
                       @QCReqdIndicator = [QCReqdInd], 
                       @RouteReqdIndicator = [RouteReqdInd] 
                FROM   [ConfigurationReqdStage] 
                WHERE  mtctboth = @MTCTBoth 
                       AND [NewAdInd] = @IsNewOccurrence 

               

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
            -- AND @IndexReqdIndicator = 'false' 
            -- AND @MapReqdIndicator = 'false' 
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
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_UpdateOccurrenceStatus]: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 
      END catch

  End