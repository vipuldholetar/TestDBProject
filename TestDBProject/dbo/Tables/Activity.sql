CREATE TABLE [dbo].[Activity] (
    [ActivityID]    INT          IDENTITY (1, 1) NOT NULL,
    [ActivityGroup] VARCHAR (50) NOT NULL,
    [ActivityType]  VARCHAR (50) NOT NULL,
    [ActivityName]  VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([ActivityID] ASC)
);

