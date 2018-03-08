CREATE TABLE [dbo].[StationMapMasterLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [StationMapMasterID]  INT          NULL,
    [TMSStationID]        INT          NULL,
    [OldVal_TMSStationID] INT          NULL,
    [TVStationID]         INT          NULL,
    [OldVal_TVStationID]  INT          NULL,
    [CreatedDT]           DATETIME     NULL,
    [OldVal_CreatedDT]    DATETIME     NULL,
    [CreatedByID]         INT          NULL,
    [OldVal_CreatedByID]  INT          NULL,
    [ModifiedDT]          DATETIME     NULL,
    [OldVal_ModifiedDT]   DATETIME     NULL,
    [ModifiedByID]        INT          NULL,
    [OldVal_ModifiedByID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

