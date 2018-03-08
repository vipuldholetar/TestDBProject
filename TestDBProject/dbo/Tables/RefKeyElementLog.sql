CREATE TABLE [dbo].[RefKeyElementLog] (
    [LogTimeStamp]     DATETIME      NULL,
    [LogDMLOperation]  CHAR (1)      NULL,
    [LoginUser]        VARCHAR (32)  NULL,
    [RefKeyElementID]  INT           NULL,
    [KeyElementName]   VARCHAR (50)  NULL,
    [KElementDataType] VARCHAR (255) NULL,
    [MaskFormat]       VARCHAR (50)  NULL,
    [MultiInd]         TINYINT       NULL,
    [SystemName]       VARCHAR (50)  NULL,
    [ComponentName]    VARCHAR (50)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

