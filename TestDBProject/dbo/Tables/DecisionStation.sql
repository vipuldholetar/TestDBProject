CREATE TABLE [dbo].[DecisionStation] (
    [DecisionStationID] INT          IDENTITY (1, 1) NOT NULL,
    [TVStationID]       INT          NOT NULL,
    [ClearanceBucket]   VARCHAR (25) NULL,
    [ClearancePriority] INT          NOT NULL,
    [EffectiveDate]     DATE         NOT NULL,
    [EndDate]           DATE         NULL,
    PRIMARY KEY CLUSTERED ([DecisionStationID] ASC),
    CONSTRAINT [FK_DecisionStation_To_TVStation] FOREIGN KEY ([TVStationID]) REFERENCES [dbo].[TVStation] ([TVStationID])
);

