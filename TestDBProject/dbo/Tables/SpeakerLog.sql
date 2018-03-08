CREATE TABLE [dbo].[SpeakerLog] (
    [LogTimeStamp]       DATETIME     NULL,
    [LogDMLOperation]    CHAR (1)     NULL,
    [LoginUser]          VARCHAR (32) NULL,
    [SpeakerID]          INT          NULL,
    [SpeakerName]        VARCHAR (50) NULL,
    [OldVal_SpeakerName] VARCHAR (50) NULL,
    [LanguageID]         INT          NULL,
    [OldVal_LanguageID]  INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

