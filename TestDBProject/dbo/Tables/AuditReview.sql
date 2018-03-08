CREATE TABLE [dbo].[AuditReview] (
    [AuditReviewID]       INT          IDENTITY (1, 1) NOT NULL,
    [UserID]              INT          NULL,
    [OccurrenceID]        INT          NOT NULL,
    [OccurrenceMediaType] INT          NOT NULL,
    [Action]              VARCHAR (50) NOT NULL,
    [CreatedDT]           DATETIME     NULL,
    [AuditedDT]           DATETIME     NULL,
    [AuditedBy]           INT          NULL,
    PRIMARY KEY CLUSTERED ([AuditReviewID] ASC),
    CONSTRAINT [FK_AuditReview_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
);

