CREATE TABLE [dbo].[CreativeForCropLog] (
    [LogTimeStamp]            DATETIME       NULL,
    [LogDMLOperation]         CHAR (1)       NULL,
    [LoginUser]               VARCHAR (32)   NULL,
    [CreativeForCropID]       INT            NULL,
    [CreativeID]              INT            NULL,
    [OldVal_CreativeID]       INT            NULL,
    [OccurrenceID]            INT            NULL,
    [OldVal_OccurrenceID]     INT            NULL,
    [CreativeMasterID]        INT            NULL,
    [OldVal_CreativeMasterID] INT            NULL,
    [MediaStream]             NVARCHAR (MAX) NULL,
    [OldVal_MediaStream]      NVARCHAR (MAX) NULL,
    [CompletedByID]           INT            NULL,
    [OldVal_CompletedByID]    INT            NULL,
    [CompletedDT]             NVARCHAR (50)  NULL,
    [OldVal_CompletedDT]      NVARCHAR (50)  NULL,
    [AdDate]                  DATETIME       NULL,
    [OldVal_AdDate]           DATETIME       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

