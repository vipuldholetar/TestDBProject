CREATE TABLE [dbo].[CreativeDetailStagingRALog] (
    [LogTimeStamp]              DATETIME       NULL,
    [LogDMLOperation]           CHAR (1)       NULL,
    [LoginUser]                 VARCHAR (32)   NULL,
    [CreativeDetailStagingRAID] INT            NULL,
    [CreativeStgID]             INT            NULL,
    [OldVal_CreativeStgID]      INT            NULL,
    [MediaFormat]               CHAR (10)      NULL,
    [OldVal_MediaFormat]        CHAR (10)      NULL,
    [MediaFilePath]             VARCHAR (MAX)  NULL,
    [OldVal_MediaFilePath]      VARCHAR (MAX)  NULL,
    [MediaFileName]             VARCHAR (MAX)  NULL,
    [OldVal_MediaFileName]      VARCHAR (MAX)  NULL,
    [FileSize]                  BIGINT         NULL,
    [OldVal_FileSize]           BIGINT         NULL,
    [AudioTranscription]        NVARCHAR (MAX) NULL,
    [OldVal_AudioTranscription] NVARCHAR (MAX) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

