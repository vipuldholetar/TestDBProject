CREATE TABLE [dbo].[TVClearanceLog] (
    [TVClearanceLogID]           INT      IDENTITY (1, 1) NOT NULL,
    [OccurrenceClientFacingRAID] INT      NOT NULL,
    [OldAdID]                    INT      NULL,
    [OldProgramFormat]           INT      NULL,
    [OldValueID]                 TINYINT  NULL,
    [OldAirDT]                   DATETIME NULL,
    [OldAirStartTime]            DATETIME NULL,
    [NewAdID]                    INT      NULL,
    [NewProgramFormat]           INT      NULL,
    [NewValueID]                 TINYINT  NULL,
    [NewAirDT]                   DATETIME NULL,
    [NewAirStartTime]            DATETIME NULL,
    [InsertedDT]                 DATETIME NOT NULL,
    CONSTRAINT [PK_TVCLEARANCELOG] PRIMARY KEY CLUSTERED ([TVClearanceLogID] ASC),
    CONSTRAINT [FK_TVCLEARANCELOG_OCCURRENCECLIENTFACINGRA] FOREIGN KEY ([OccurrenceClientFacingRAID]) REFERENCES [dbo].[OccurrenceClientFacingRA] ([OccurrenceClientFacingRAId]),
    CONSTRAINT [FK_TVCLEARANCELOG_PROGRAMFORMATMASTER] FOREIGN KEY ([OldProgramFormat]) REFERENCES [dbo].[ProgramForMAT] ([ProgramFormatID]),
    CONSTRAINT [FK_TVCLEARANCELOG_PROGRAMFORMATMASTER1] FOREIGN KEY ([NewProgramFormat]) REFERENCES [dbo].[ProgramForMAT] ([ProgramFormatID])
);

