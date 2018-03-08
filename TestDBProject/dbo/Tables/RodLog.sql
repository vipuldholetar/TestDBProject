CREATE TABLE [dbo].[RodLog] (
    [LogTimeStamp]      DATETIME     NULL,
    [LogDMLOperation]   CHAR (1)     NULL,
    [LoginUser]         VARCHAR (32) NULL,
    [RodID]             INT          NULL,
    [Scan]              INT          NULL,
    [OldVal_Scan]       INT          NULL,
    [StatusID]          INT          NULL,
    [OldVal_StatusID]   INT          NULL,
    [SenderID]          INT          NULL,
    [OldVal_SenderID]   INT          NULL,
    [Priority]          INT          NULL,
    [OldVal_Priority]   INT          NULL,
    [PulledByID]        INT          NULL,
    [OldVal_PulledByID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

