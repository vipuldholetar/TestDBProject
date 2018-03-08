CREATE TABLE [dbo].[CompositeCropStagingLog] (
    [LogTimeStamp]                 DATETIME     NULL,
    [LogDMLOperation]              CHAR (1)     NULL,
    [LoginUser]                    VARCHAR (32) NULL,
    [CompositeCropStagingID]       INT          NULL,
    [CreativeCropStagingID]        INT          NULL,
    [OldVal_CreativeCropStagingID] INT          NULL,
    [CropID]                       INT          NULL,
    [OldVal_CropID]                INT          NULL,
    [Deleted]                      TINYINT      NULL,
    [OldVal_Deleted]               TINYINT      NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

