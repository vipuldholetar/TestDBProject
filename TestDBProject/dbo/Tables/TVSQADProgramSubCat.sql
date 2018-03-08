CREATE TABLE [dbo].[TVSQADProgramSubCat] (
    [ProgramSubCatId] INT          IDENTITY (1, 1) NOT NULL,
    [Category]        VARCHAR (50) NOT NULL,
    [Subcategory]     VARCHAR (50) NOT NULL,
    [CreateDT]        DATE         NOT NULL,
    [ModifiedDT]      DATE         NULL,
    PRIMARY KEY CLUSTERED ([ProgramSubCatId] ASC)
);

