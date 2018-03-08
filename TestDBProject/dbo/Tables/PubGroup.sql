CREATE TABLE [dbo].[PubGroup] (
    [PubGroupID] INT          IDENTITY (1, 1) NOT NULL,
    [GroupType]  VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([PubGroupID] ASC)
);

