CREATE TABLE [dbo].[RefCelebrityLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [RefCelebrityID]       INT          NULL,
    [CelebrityName]        VARCHAR (50) NULL,
    [OldVal_CelebrityName] VARCHAR (50) NULL,
    [CreatedDT]            DATETIME     NULL,
    [OldVal_CreatedDT]     DATETIME     NULL,
    [CreateByID]           INT          NULL,
    [OldVal_CreateByID]    INT          NULL,
    [ModifiedDT]           DATETIME     NULL,
    [OldVal_ModifiedDT]    DATETIME     NULL,
    [ModifiedByID]         INT          NULL,
    [OldVal_ModifiedByID]  INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

