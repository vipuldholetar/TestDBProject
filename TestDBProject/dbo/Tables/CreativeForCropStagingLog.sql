CREATE TABLE [dbo].[CreativeForCropStagingLog] (
    [LogTimeStamp]                   DATETIME       NULL,
    [LogDMLOperation]                CHAR (1)       NULL,
    [LoginUser]                      VARCHAR (32)   NULL,
    [CreativeForCropStagingID]       INT            NULL,
    [CreativeCropID]                 INT            NULL,
    [OldVal_CreativeCropID]          INT            NULL,
    [AdID]                           INT            NULL,
    [OldVal_AdID]                    INT            NULL,
    [OccurrenceID]                   INT            NULL,
    [OldVal_OccurrenceID]            INT            NULL,
    [CreativeMasterStagingID]        INT            NULL,
    [OldVal_CreativeMasterStagingID] INT            NULL,
    [MediaStream]                    NVARCHAR (MAX) NULL,
    [OldVal_MediaStream]             NVARCHAR (MAX) NULL,
    [LockedByID]                     INT            NULL,
    [OldVal_LockedByID]              INT            NULL,
    [LockedDT]                       DATETIME       NULL,
    [OldVal_LockedDT]                DATETIME       NULL,
    [AdDT]                           DATETIME       NULL,
    [OldVal_AdDT]                    DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

