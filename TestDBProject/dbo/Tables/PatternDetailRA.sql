CREATE TABLE [dbo].[PatternDetailRA] (
    [PatternDetailRAID] INT          IDENTITY (1, 1) NOT NULL,
    [PatternID]         INT          NOT NULL,
    [RCSCreativeID]     VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_PatternDetailRA_1] PRIMARY KEY CLUSTERED ([PatternDetailRAID] ASC)
);

