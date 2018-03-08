CREATE TABLE [dbo].[CreativeDetailExclude] (
    [FK_ContentDetailID] INT      NOT NULL,
    [CropRectCoordX1]    INT      NULL,
    [CropRectCoordY1]    INT      NULL,
    [CropRectCoordX2]    INT      NULL,
    [CropRectCoordY2]    INT      NULL,
    [CropDetailSize]     INT      NULL,
    [CreatedDT]          DATETIME NOT NULL,
    [CreatedByID]        INT      NOT NULL,
    [ModifiedDT]         DATETIME NULL,
    [ModifiedByID]       INT      NULL
);

