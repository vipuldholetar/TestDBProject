CREATE TABLE [dbo].[ProgramMap] (
    [ProgramMapID] INT      IDENTITY (1, 1) NOT NULL,
    [TMSSeqID]     INT      NOT NULL,
    [MTProgID]     INT      NOT NULL,
    [CreatedDT]    DATETIME NULL,
    [CreateByID]   INT      NULL,
    [ModifiedDT]   DATETIME NULL,
    [ModifiedByID] INT      NULL,
    CONSTRAINT [PK_ProgramMapMaster] PRIMARY KEY CLUSTERED ([ProgramMapID] ASC)
);

