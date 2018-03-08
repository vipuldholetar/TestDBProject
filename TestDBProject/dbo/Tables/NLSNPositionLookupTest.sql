CREATE TABLE [dbo].[NLSNPositionLookupTest] (
    [FileType]      VARCHAR (100) NOT NULL,
    [FieldName]     VARCHAR (50)  NOT NULL,
    [StartPosition] INT           NULL,
    [EndPosition]   INT           NULL,
    [Condition]     VARCHAR (100) NULL,
    [Descrip]       VARCHAR (250) NULL,
    [CreatedDT]     DATETIME      NULL,
    [CreatedByID]   INT           NULL,
    [ModifiedDT]    DATETIME      NULL,
    [ModifiedByID]  INT           NULL,
    CONSTRAINT [PK_NLSNPositionLookup_Test] PRIMARY KEY CLUSTERED ([FileType] ASC, [FieldName] ASC)
);

