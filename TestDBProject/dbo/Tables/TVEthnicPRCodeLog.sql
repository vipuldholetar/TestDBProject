CREATE TABLE [dbo].[TVEthnicPRCodeLog] (
    [LogTimeStamp]          DATETIME      NULL,
    [LogDMLOperation]       CHAR (1)      NULL,
    [LoginUser]             VARCHAR (32)  NULL,
    [TVEthnicPRCodeID]      VARCHAR (200) NULL,
    [EthnicGroupID]         INT           NULL,
    [OldVal_EthnicGroupID]  INT           NULL,
    [OriginalPRCode]        VARCHAR (200) NULL,
    [OldVal_OriginalPRCode] VARCHAR (200) NULL,
    [CreatedDT]             DATETIME      NULL,
    [OldVal_CreatedDT]      DATETIME      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

