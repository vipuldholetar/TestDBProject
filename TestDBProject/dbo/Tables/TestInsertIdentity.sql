CREATE TABLE [dbo].[TestInsertIdentity] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [col1] VARCHAR (255) NULL,
    [col2] VARCHAR (255) NULL,
    [dt]   DATETIME      NULL
);

