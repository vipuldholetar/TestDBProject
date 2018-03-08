-- =============================================        
-- Author:    Govardhan.R        
-- Create date: 04/06/2015        
-- Description:  Process RCS Ingestion Process        
-- Query : exec usp_RCSRadio_Ingestion_MasterData '1'        
-- =============================================        
CREATE PROCEDURE [dbo].[Usp_rcsradio_ingestion_masterdata] (@STATION_ID     AS 
INT, 
                                                           @AIRCHECK_ID    AS 
BIGINT, 
                                                           @CREATIVEID     AS 
VARCHAR(255), 
                                                           @PAID           AS 
INT, 
                                                           @AdvertiserName 
VARCHAR(255), 
                                                           @CLASSID        AS 
INT, 
                                                           @ClassName      AS 
VARCHAR(255), 
                                                           @SEQUENCE_ID    AS 
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
                                                           @AccountName    AS 
VARCHAR(255)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          --Check station id exists or not. Insert if not available else update.      
          IF NOT EXISTS(SELECT * 
                        FROM   [rcsradiostation] 
                        WHERE  RCSRadioStationID = @STATION_ID) 
            BEGIN 
                INSERT INTO rcsradiostation 
                            (RCSRadioStationID, 
                             Name, 
                             shortname, 
                             rcsmarket, 
                             timezone, 
                             radiofrequency, 
                             format, 
                             createdDT, 
                             [CreatedByID], 
                             effectivedt, 
                             enddt) 
                VALUES      (@STATION_ID, 
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
          --                    WHERE  rcsstationid = @STATION_ID 
          --                           AND rcsstationname = @RCSStationName 
          --                           AND shortname = @ShortName 
          --                           AND rcsmarket = @RCSMarket 
          --                           AND timezone = @TimeZone 
          --                           AND radiofrequency = @RadioFrequency 
          --                           AND format = @Format) 
          --        BEGIN 
          --            UPDATE rcsradiostation 
          --            SET    rcsstationname = @RCSStationName, 
          --                   shortname = @ShortName, 
          --                   rcsmarket = @RCSMarket, 
          --                   timezone = @TimeZone, 
          --                   radiofrequency = @RadioFrequency, 
          --                   format = @Format, 
          --                   modifieddtm = Getdate(), 
          --                   modifiedby = 1 
          --            WHERE  rcsstationid = @STATION_ID 
          --        END 
          --  END 

          --Check advertiser id exists or not. Insert if not available else update.      
          IF NOT EXISTS(SELECT * 
                        FROM   [rcsadvertisermaster] 
                        WHERE  rcsadvertiserid = @PAID) 
            BEGIN 
                INSERT INTO rcsadvertisermaster 
                            (rcsadvertiserid, 
                             rcsadvertisername, 
                             rcssequenceforcreation, 
                             createddtm, 
                             createdby) 
                VALUES      (@PAID, 
                             @AdvertiserName, 
                             @SEQUENCE_ID, 
                             Getdate(), 
                             1) 
            END 
          ELSE 
            BEGIN 
                IF NOT EXISTS(SELECT * 
                              FROM   [rcsadvertisermaster] 
                              WHERE  rcsadvertiserid = @PAID 
                                     AND rcsadvertisername = @AdvertiserName) 
                  BEGIN 
                      UPDATE rcsadvertisermaster 
                      SET    rcsadvertisername = @AdvertiserName, 
                             rcssequenceforupdate = @SEQUENCE_ID, 
                             modifieddtm = Getdate(), 
                             modifiedby = 1 
                      WHERE  rcsadvertiserid = @PAID 
                  END 
            END 

          --Check Account name exists or not. Insert if not available else update.      
          IF NOT EXISTS(SELECT * 
                        FROM   [RCSAcct] 
                        WHERE  RCSAcct.Name = @AccountName) 
            BEGIN 
                INSERT INTO [RCSAcct] 
                            (Name, 
                             [MostRecentAdvID], 
                             [Deleted], 
                             RCSSeqForCreation, 
                             CreatedDT, 
                             [CreatedByID]) 
                VALUES      (@AccountName, 
                             @SEQUENCE_ID, 
                             0, 
                             @SEQUENCE_ID, 
                             Getdate(), 
                             1) 
            END 

          --ELSE  
          --  BEGIN  
          --      UPDATE rcsaccountmaster  
          --      SET    mostrecentaircheckid = @SEQUENCE_ID,  
          --             rcssequenceforupdate = @SEQUENCE_ID,  
          --             modifieddtm = Getdate(),  
          --             modifiedby = 1  
          --      WHERE  rcsaccountname = @AccountName  
          --  END  
          --Check class id exists or not. Insert if not available else update.      
          IF NOT EXISTS(SELECT * 
                        FROM   [RCSClass] 
                        WHERE  rcsclassid = @CLASSID) 
            BEGIN 
                INSERT INTO [RCSClass] 
                            (rcsclassid, 
                             Name, 
                             [Deleted], 
                             RCSSeqForCreation, 
                             CreatedDT, 
                             [CreatedByID]) 
                VALUES      (@CLASSID, 
                             @ClassName, 
                             0, 
                             @SEQUENCE_ID, 
                             Getdate(), 
                             1) 
            END 
          ELSE 
            BEGIN 
                IF NOT EXISTS(SELECT * 
                              FROM   [RCSClass] 
                              WHERE  rcsclassid = @CLASSID 
                                     AND Name = @ClassName) 
                  BEGIN 
                      UPDATE [RCSClass] 
                      SET    Name = @ClassName, 
                             RCSSeqForCreation = @SEQUENCE_ID, 
                             ModifiedDT = Getdate(), 
                             [ModifiedByID] = 1 
                      WHERE  rcsclassid = @CLASSID 
                  END 
            END 

          ---uPDATE STATUS   
          UPDATE rcsrawdata 
          SET    ingestionstatus = 1 
          WHERE  SeqID = @SEQUENCE_ID 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_RCSRadio_Ingestion_MasterData: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;