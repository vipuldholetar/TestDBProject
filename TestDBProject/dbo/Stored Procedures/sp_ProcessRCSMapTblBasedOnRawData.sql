-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 04/21/2015    
-- Description: Process RCS Map Tables Based On RawData  
-- Query : exec sp_ProcessRCSMapTblBasedOnRawData 
-- =============================================    
CREATE PROCEDURE [dbo].[sp_ProcessRCSMapTblBasedOnRawData] 
AS 
  BEGIN 
      ----INSERT ADVERTISER MAP TABLE 
      INSERT INTO [AdvertiserMap] 
                  ([RCSAdvertiserID], 
                   [Priority], 
                   AutoIndexing, 
                   [Deleted], 
                   [CreatedDT], 
                   [CreatedByID]) 
      SELECT RD.[PaID]  FK_RCSAdvId, 
             1        [Priority], 
             1        [AutoIndexing], 
             0        [IsDeleted], 
             Getdate()[CreateDate], 
             5        [CreatedBy] 
      FROM   (SELECT DISTINCT [PaID] 
              FROM   RCSRawData 
              WHERE  [PaID] NOT IN (SELECT [RCSAdvertiserID] 
                                  FROM   [AdvertiserMap]) 
                     AND [PaID] != 0) AS RD 

      ----INSERT CLASS MAP TABLE 
      INSERT INTO ClassMap 
                  ([RCSClassId], 
                   [Priority], 
                   IsDeleted, 
                   CreateDate, 
                   CreatedBy) 
      SELECT RD.[ClassID] [FK_RCSClassId], 
             1         [Priority], 
             0         [IsDeleted], 
             Getdate() [CreateDate], 
             5         [CreatedBy] 
      FROM   (SELECT DISTINCT [ClassID] 
              FROM   RCSRawData 
              WHERE  [ClassID] NOT IN (SELECT DISTINCT [RCSClassId] 
                                     FROM   ClassMap) 
                     AND [ClassID] != 0) AS RD 

      ----INSERT RCS ACCOUNT MASTER TABLE 
      INSERT INTO [RCSAcct] 
                  (Name, 
                   [MostRecentAdvID], 
                   [Deleted], 
                   RCSSeqForCreation, 
                   [CreatedDT], 
                   [CreatedByID]) 
      SELECT RD.AcctName [RCSAccountName], 
             1             [MostRecentAircheckID], 
             0             [IsDeleted], 
             1             [RCSSequenceForCreation], 
             Getdate()     [CreateDate], 
             5             [CreatedBy] 
      FROM   (SELECT DISTINCT AcctName 
              FROM   RCSRawData 
              WHERE  AcctName NOT IN (SELECT DISTINCT Name 
                                         FROM   [RCSAcct]) 
                     AND AcctName != '') AS RD 

      ----INSERT RCS ACCOUNT MAP TABLE 
      INSERT INTO AcctMap 
                  ([RCSAcctID], 
                   AcctName, 
                   [Priority], 
                   AutoIndexing, 
                   [Deleted], 
                   [CreatedDT], 
                   [CreatedByID]) 
      SELECT RD.[RCSAcctID][RCSAccountID], 
             Name, 
             1              [Priority], 
             1              [AutoIndexing], 
             0				[IsDeleted], 
             Getdate()      [CreateDate], 
             5              [CreatedBy] 
      FROM   (SELECT DISTINCT [RCSAcctID], 
                              Name 
              FROM   [RCSAcct] 
              WHERE  [RCSAcctID] NOT IN (SELECT DISTINCT [RCSAcctID] 
                                          FROM   AcctMap)) AS RD 
  END