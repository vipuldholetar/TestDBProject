CREATE TABLE [dbo].[ImagePath] (
    [path]        VARCHAR (512) NULL,
    [locationid]  INT           NOT NULL,
    [MediaTypeId] VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_ImagePath] PRIMARY KEY CLUSTERED ([locationid] ASC, [MediaTypeId] ASC)
);

