CREATE TYPE [dbo].[TVMediaFiles] AS TABLE (
    [PRCode]        VARCHAR (20)  NOT NULL,
    [MediaFilePath] VARCHAR (300) NOT NULL,
    [MediaFileName] VARCHAR (200) NOT NULL,
    [FileSize]      INT           NOT NULL);

