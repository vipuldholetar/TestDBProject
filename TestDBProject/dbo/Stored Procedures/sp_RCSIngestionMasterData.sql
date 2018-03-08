
-- =============================================         
-- Author:    Govardhan.R         
-- Create date: 04/06/2015         
-- Description:  Process RCS Ingestion Process         
-- Query : exec sp_RCSIngestionMasterData '1'         
-- =============================================         
CREATE PROCEDURE [sp_RCSIngestionMasterData] (@StationId     AS 
INT, 
                                                           @AcId    AS 
BIGINT, 
                                                           @CreativeId     AS 
VARCHAR(255), 
                                                           @PaId           AS 
INT, 
                                                           @AdvName 
VARCHAR(255), 
                                                           @ClassId        AS 
INT, 
                                                           @ClassName      AS 
VARCHAR(255), 
                                                           @SeqId    AS 
BIGINT, 
                                                           @RCSStationName AS 
VARCHAR(255), 
                                                           @ShortName      AS 
VARCHAR(255), 
                                                           @RCSMarket      AS 
VARCHAR(255), 
                                                           @TimeZone       AS 
VARCHAR(255), 
                                                           @RadioFrequency AS 
FLOAT, 
                                                           @Format         AS 
VARCHAR(255), 
                                                           @AcctName    AS 
VARCHAR(255)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          --Check station Id exists or not. Insert if not available else update.       
          IF NOT EXISTS(SELECT * 
                        FROM   RCSRadioStation 
                        WHERE  [RCSRadioStationID] = @StationId) 
            BEGIN 
                INSERT INTO RCSRadioStation 
                            ([RCSRadioStationID], 
                             Name, 
                             ShortName, 
                             RCSMarket, 
                             TimeZone, 
                             RadioFrequency, 
                             [Format], 
                             [CreatedDT], 
                             [CreatedByID], 
                             [EffectiveDT], 
                             [EndDT]) 
                VALUES      (@StationId, 
                             @RCSStationName, 
                             @ShortName, 
                             @RCSMarket, 
                             @TimeZone, 
                             @RadioFrequency, 
                             @Format, 
                             Getdate(), 
                             1, 
                             Getdate(), 
                             1) 
            END 

          --Below script is commented based on communication by sherebyah on 05/06/2015 evening call. 
          --ELSE  
          --  BEGIN  
          --      IF NOT EXISTS(SELECT *  
          --                    FROM   [rcsradiostation]  
          --                    WHERE  rcsstationId = @StationId  
          --                           AND rcsstationname = @RCSStationName  
          --                           AND shortname = @ShortName  
          --                           AND rcsmarket = @RCSMarket  
          --                           AND timezone = @TimeZone  
          --                           AND radiofrequency = @RadioFrequency  
          --                           AND [Format] = @Format)  
          --        BEGIN  
          --            UPDATE rcsradiostation  
          --            SET    rcsstationname = @RCSStationName,  
          --                   shortname = @ShortName,  
          --                   rcsmarket = @RCSMarket,  
          --                   timezone = @TimeZone,  
          --                   radiofrequency = @RadioFrequency,  
          --                   [Format] = @Format,  
          --                   ModifiedDate = Getdate(),  
          --                   ModifiedBy = 1  
          --            WHERE  rcsstationId = @StationId  
          --        END  
          --  END  
          --Check Adv Id exists or not. Insert if not available else update.       
          IF NOT EXISTS(SELECT * 
                        FROM   [RCSAdv] 
                        WHERE  [Name] = @AdvName) 
            BEGIN 
                INSERT INTO [RCSAdv] 
                            (Name, 
                             RCSSeqForCreation, 
                             [CreatedDT], 
                             [CreatedByID]) 
                VALUES      (@AdvName, 
                             @SeqId, 
                             Getdate(), 
                             1) 
            END 
          ELSE 
            BEGIN 
                      UPDATE [RCSAdv] 
                      SET    RCSSeqForUpdate = @SeqId, 
                             [ModifiedDT] = Getdate(), 
                             [ModifiedByID] = 1 
                      WHERE  [Name] = @AdvName
            END 

          --Check class Id exists or not. Insert if not available else update.       
          IF NOT EXISTS(SELECT * 
                        FROM   [RCSClass] 
                        WHERE  [Name] = @ClassName) 
            BEGIN 
                INSERT INTO [RCSClass] 
                            (Name, 
                             [Deleted], 
                             RCSSeqForCreation, 
                             [CreatedDT], 
                             [CreatedByID]) 
                VALUES      (@ClassName, 
                             0, 
                             @SeqId, 
                             Getdate(), 
                             1) 
            END 
          ELSE 
            BEGIN 
                      UPDATE [RCSClass] 
                      SET    RCSSeqForUpdate = @SeqId, 
                             [ModifiedDT] = Getdate(), 
                             [ModifiedByID] = 1 
                      WHERE  [Name] = @ClassName
                  END 

	     --Check Acct name exists or not. Insert if not available else update.       
          IF NOT EXISTS(SELECT * 
                        FROM   [RCSAcct] 
                        WHERE  Name = @AcctName) 
            BEGIN 
                INSERT INTO [RCSAcct] 
                            (Name, 
                             [MostRecentAdvID], 
							 [MostRecentClassID],
                             [Deleted], 
                             RCSSeqForCreation, 
                             [CreatedDT], 
                             [CreatedByID]) 
                VALUES      (@AcctName, 
                             (SELECT RCSAdvID
                              FROM   [RCSAdv] 
                              WHERE  [Name] = @AdvName),
							  (SELECT RCSClassID 
                              FROM   [RCSClass] 
                              WHERE  [Name] = @ClassName), 
                             0, 
                             @SeqId, 
                             Getdate(), 
                             1) 
            END 
			  ----INSERT ADVERTISER MAP TABLE 
			BEGIN
				  INSERT INTO advertisermap 
							  (rcsadvertiserid, 
							   priority, 
							   autoindexing, 
							   [Deleted], 
							   createdDT, 
							   [CreatedByID]) 
				  SELECT [RCSAdvID], 
						 1        [Priority], 
						 1        [AutoIndexing], 
						 0        [IsDeleted], 
						 Getdate()[CreateDTM], 
						 5        [CreatedBy] 
				  FROM   RCSAdv
				  WHERE Name = @AdvName
				  and not exists (select 1 from AdvertiserMap where RCSAdvertiserId = RCSAdvID)
			  END
			  ----INSERT CLASS MAP TABLE 
			BEGIN
			     INSERT INTO classmap 
						  (RCSClassId,
						  priority, 
						   isdeleted, 
						   createDate, 
						   createdby) 
				  
				  SELECT RCSClassID,
						 1         [Priority], 
						 0         [IsDeleted], 
						 Getdate() [CreateDTM], 
						 5         [CreatedBy] 
				  FROM    RCSClass 
				  WHERE  Name = @ClassName
				  and not exists (select 1 from ClassMap where ClassMap.RCSClassId = RCSClass.RCSClassID ) 
			 END
			  ----INSERT RCS ACCOUNT MAP TABLE 
			  BEGIN
				  INSERT INTO acctmap 
							  (RCSAcctID, 
							   AcctName, 
							   RCSAdvID,
							   priority, 
							   autoindexing, 
							   deleted, 
							   createdDT, 
							   CreatedByID) 
				  SELECT [RCSAcctID], 
						 name, 
						 (select RCSAdvID from RCSAdv where name = @AdvName),
						 1              [Priority], 
						 1              [autoindexing], 
						 0[IsDeleted], 
						 Getdate()      [CreateDTM], 
						 5              [CreatedBy] 
				  FROM   RCSAcct
				  WHERE Name = @AcctName
				  and not exists (select 1 from AcctMap where AcctMap.RCSAcctId = RCSAcct.RCSAcctID)
				END

          ---uPDATE STATUS    
          UPDATE RCSRawData 
          SET    IngestionStatus = 1 
          WHERE  [SeqID] = @SeqId 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSIngestionMasterData: %d: %s',16,1,@Error, 
                     @Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;