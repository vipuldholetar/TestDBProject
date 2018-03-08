CREATE TABLE [dbo].[Size_Backup20161121] (
    [SizeID]         INT           IDENTITY (1, 1) NOT NULL,
    [SizingMethodID] INT           NOT NULL,
    [PubTypeID]      INT           NULL,
    [Height]         FLOAT (53)    NULL,
    [Width]          FLOAT (53)    NULL,
    [SizeDescrip]    VARCHAR (255) NULL,
    [CreatedDT]      DATETIME      NOT NULL,
    [CreatedByID]    INT           NOT NULL,
    [ModifiedDT]     DATETIME      NULL,
    [ModifiedByID]   INT           NULL
);

