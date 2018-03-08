CREATE TABLE [dbo].[Transaction] (
    [TransactionID]    INT          IDENTITY (1, 1) NOT NULL,
    [TransactionGroup] VARCHAR (50) NOT NULL,
    [ActivityType]     VARCHAR (50) NOT NULL,
    [TransactionName]  VARCHAR (50) NOT NULL,
    [TransactionCount] INT          NOT NULL,
    [Points]           INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([TransactionID] ASC)
);

