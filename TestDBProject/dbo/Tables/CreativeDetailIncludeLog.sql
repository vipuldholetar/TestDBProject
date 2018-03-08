CREATE TABLE [dbo].[CreativeDetailIncludeLog] (
    [LogTimeStamp]       DATETIME     NULL,
    [LogDMLOperation]    CHAR (1)     NULL,
    [LoginUser]          VARCHAR (32) NULL,
    [FK_CropID]          INT          NULL,
    [FK_ContentDetailID] INT          NULL,
    [CropRectCoordX1]    INT          NULL,
    [CropRectCoordY1]    INT          NULL,
    [CropRectCoordX2]    INT          NULL,
    [CropRectCoordY2]    INT          NULL,
    [CropDetailSize]     INT          NULL,
    [CreatedDT]          DATETIME     NULL,
    [CreatedByID]        INT          NULL,
    [ModifiedDT]         DATETIME     NULL,
    [ModifiedByID]       INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

