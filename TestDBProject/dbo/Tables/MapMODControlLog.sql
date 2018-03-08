CREATE TABLE [dbo].[MapMODControlLog] (
    [LogTimeStamp]      DATETIME       NULL,
    [LogDMLOperation]   CHAR (1)       NULL,
    [LoginUser]         VARCHAR (32)   NULL,
    [MadMODControlID]   INT            NULL,
    [MapModReason]      NVARCHAR (MAX) NULL,
    [ConditionCODE]     VARCHAR (100)  NULL,
    [NewRevYesInd]      BIT            NULL,
    [MapAdYesInd]       BIT            NULL,
    [ScanReqYesInd]     BIT            NULL,
    [AppendDescYesCODE] CHAR (1)       NULL,
    [AppendTextYes]     NVARCHAR (MAX) NULL,
    [NewRevNoInd]       BIT            NULL,
    [MapAdNoInd]        BIT            NULL,
    [ScanReqNoInd]      BIT            NULL,
    [AppendDescNoCODE]  CHAR (1)       NULL,
    [AppendTextNo]      NVARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

