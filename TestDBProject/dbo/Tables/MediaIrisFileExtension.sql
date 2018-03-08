CREATE TABLE [dbo].[MediaIrisFileExtension] (
    [TypeCODE]  VARCHAR (15) NOT NULL,
    [Extension] VARCHAR (4)  NULL,
    CONSTRAINT [PK_MediaIrisFileExtension] PRIMARY KEY CLUSTERED ([TypeCODE] ASC)
);

