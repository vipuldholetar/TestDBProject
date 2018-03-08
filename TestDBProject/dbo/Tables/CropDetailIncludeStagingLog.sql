CREATE TABLE [dbo].[CropDetailIncludeStagingLog] (
    [LogTimeStamp]           DATETIME     NULL,
    [LogDMLOperation]        CHAR (1)     NULL,
    [LoginUser]              VARCHAR (32) NULL,
    [CompositeCropStagingID] INT          NULL,
    [ContentDetailStagingID] INT          NULL,
    [CropRectCoordX1]        INT          NULL,
    [CropRectCoordY1]        INT          NULL,
    [CropRectCoordX2]        INT          NULL,
    [CropRectCoordY2]        INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

