CREATE TABLE [dbo].[EthnicPRCodeLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [EthnicPRCodeID]  VARCHAR (50) NULL,
    [EthnicGroupID]   VARCHAR (50) NULL,
    [OriginalPRCode]  VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

