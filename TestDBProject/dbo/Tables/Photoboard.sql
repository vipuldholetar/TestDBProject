CREATE TABLE [dbo].[Photoboard] (
    [PhotoboardID]  INT           IDENTITY (1, 1) NOT NULL,
    [AdID]          INT           NOT NULL,
    [MediaStream]   INT           NULL,
    [StartedByID]   INT           NULL,
    [StartedDT]     DATETIME      NULL,
    [FinishedByID]  INT           NULL,
    [FinishedDT]    DATETIME      NULL,
    [AssignedToID]  INT           NULL,
    [AuditByID]     INT           NULL,
    [AuditDT]       DATETIME      NULL,
    [Status]        VARCHAR (50)  NULL,
    [AVRepository]  VARCHAR (100) NULL,
    [AVAssetName]   VARCHAR (100) NULL,
    [PDFRepository] VARCHAR (100) NULL,
    [PDFAssetName]  VARCHAR (100) NULL,
    [Deleted]       TINYINT       DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([PhotoboardID] ASC),
    CONSTRAINT [FK_Photoboard_To_Ad] FOREIGN KEY ([AdID]) REFERENCES [dbo].[Ad] ([AdID])
);

