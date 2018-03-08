CREATE TABLE [dbo].[CreativeDetailStagingTVLog] (
    [LogTimeStamp]               DATETIME      NULL,
    [LogDMLOperation]            CHAR (1)      NULL,
    [LoginUser]                  VARCHAR (32)  NULL,
    [CreativeDetailStagingTVID]  BIGINT        NULL,
    [CreativeStgMasterID]        INT           NULL,
    [OldVal_CreativeStgMasterID] INT           NULL,
    [OccurrenceID]               BIGINT        NULL,
    [OldVal_OccurrenceID]        BIGINT        NULL,
    [MediaFormat]                CHAR (10)     NULL,
    [OldVal_MediaFormat]         CHAR (10)     NULL,
    [MediaFilepath]              VARCHAR (200) NULL,
    [OldVal_MediaFilepath]       VARCHAR (200) NULL,
    [MediaFileName]              VARCHAR (200) NULL,
    [OldVal_MediaFileName]       VARCHAR (200) NULL,
    [FileSize]                   BIGINT        NULL,
    [OldVal_FileSize]            BIGINT        NULL,
    [CreativeResolution]         VARCHAR (2)   NULL,
    [OldVal_CreativeResolution]  VARCHAR (2)   NULL,
    [Deleted]                    BIT           DEFAULT ((0)) NULL,
    [OldVal_Deleted]             BIT           DEFAULT ((0)) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

