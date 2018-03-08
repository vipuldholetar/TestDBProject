-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 04/21/2015    
-- Description: Process RCS Map Tables Based On RawData  
-- Query : exec ProcessRCSMapTablesBasedOnRawData 
-- =============================================    
CREATE PROCEDURE [dbo].Processrcsmaptablesbasedonrawdata 
AS 
  BEGIN 
      ----INSERT ADVERTISER MAP TABLE 
      INSERT INTO advertisermap 
                  (rcsadvertiserid, 
                   priority, 
                   autoindexing, 
                   [Deleted], 
                   createdDT, 
                   [CreatedByID]) 
      SELECT RD.[PaID]  [RCSAdvertiserID], 
             1        [Priority], 
             1        [AutoIndexing], 
             0        [IsDeleted], 
             Getdate()[CreateDTM], 
             5        [CreatedBy] 
      FROM   (SELECT DISTINCT [PaID] 
              FROM   rcsrawdata 
              WHERE  [PaID] NOT IN (SELECT rcsadvertiserid 
                                  FROM   advertisermap) 
                     AND [PaID] != 0) AS RD 

      ----INSERT CLASS MAP TABLE 
      INSERT INTO classmap 
                  (ClassMapID, 
                   priority, 
                   isdeleted, 
                   createDate, 
                   createdby) 
      SELECT RD.[ClassID][RCSClassID], 
             1         [Priority], 
             0         [IsDeleted], 
             Getdate() [CreateDTM], 
             5         [CreatedBy] 
      FROM   (SELECT DISTINCT [ClassID] 
              FROM   rcsrawdata 
              WHERE  [ClassID] NOT IN (SELECT DISTINCT ClassMapID 
                                     FROM   classmap) 
                     AND [ClassID] != 0) AS RD 

      ----INSERT RCS ACCOUNT MASTER TABLE 
      INSERT INTO [RCSAcct] 
                  (Name, 
                   [MostRecentAdvID], 
                   [Deleted], 
                   RCSSeqForCreation, 
                   CreatedDT, 
                   [CreatedByID]) 
      SELECT RD.AcctName[RCSAccountName], 
             1             [MostRecentAircheckID], 
             0             [IsDeleted], 
             1             [RCSSequenceForCreation], 
             Getdate()     [CreateDTM], 
             5             [CreatedBy] 
      FROM   (SELECT DISTINCT AcctName 
              FROM   rcsrawdata 
              WHERE  AcctName NOT IN (SELECT DISTINCT Name 
                                         FROM   [RCSAcct]) 
                     AND AcctName != '') AS RD 

      ----INSERT RCS ACCOUNT MAP TABLE 
      INSERT INTO accountmap 
                  (rcsaccountid, 
                   accountname, 
                   priority, 
                   autoindexing, 
                   isdeleted, 
                   createdtm, 
                   createdby) 
      SELECT RD.[RCSAcctID][RCSAccountID], 
             name, 
             1              [Priority], 
             1              [autoindexing], 
             0[IsDeleted], 
             Getdate()      [CreateDTM], 
             5              [CreatedBy] 
      FROM   (SELECT DISTINCT [RCSAcctID], 
                              Name 
              FROM   [RCSAcct] 
              WHERE  [RCSAcctID] NOT IN (SELECT DISTINCT [RCSAcctID] 
                                          FROM   accountmap)) AS RD 
  END