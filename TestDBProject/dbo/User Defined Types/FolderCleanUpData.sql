CREATE TYPE [dbo].[FolderCleanUpData] AS TABLE (
    [BusinessOwner]           VARCHAR (250)  NULL,
    [FolderPath]              NVARCHAR (MAX) NULL,
    [ParentFolder]            NVARCHAR (MAX) NULL,
    [SizeBeforeCleanup]       NVARCHAR (MAX) NULL,
    [NumberOfFilesBfrCleanup] INT            NULL,
    [NumberofDays]            INT            NULL,
    [SubFolderCleanup]        NVARCHAR (50)  NULL);

