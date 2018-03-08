CREATE TABLE [dbo].[RefEthinicGroupLog] (
    [LogTimeStamp]       DATETIME       NULL,
    [LogDMLOperation]    CHAR (1)       NULL,
    [LoginUser]          VARCHAR (32)   NULL,
    [RefEthinicGroupID]  INT            NULL,
    [CTLegacyLanguageID] INT            NULL,
    [EthnicGroupName]    VARCHAR (255)  NULL,
    [Notes]              VARCHAR (1000) NULL,
    [CreatedDT]          DATETIME       NULL,
    [CreateByID]         INT            NULL,
    [ModifiedDT]         DATETIME       NULL,
    [ModifiedByID]       INT            NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

