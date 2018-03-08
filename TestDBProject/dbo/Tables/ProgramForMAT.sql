CREATE TABLE [dbo].[ProgramForMAT] (
    [ProgramFormatID] INT            IDENTITY (1, 1) NOT NULL,
    [ProgramFormat]   VARCHAR (1000) NULL,
    [CreatedDT]       DATETIME       NOT NULL,
    [CreatedByID]     INT            NOT NULL,
    [ModifiedDT]      DATETIME       NULL,
    [ModifiedByID]    INT            NULL,
    CONSTRAINT [PK_PROGRAMFORMATMASTER] PRIMARY KEY CLUSTERED ([ProgramFormatID] ASC)
);

