CREATE TABLE [dbo].[OccurrenceClearanceTV] (
    [OccurrenceClearanceTVID] INT          IDENTITY (1, 1) NOT NULL,
    [OccurrenceDetailTVID]    INT          NOT NULL,
    [Clearance]               VARCHAR (50) NULL,
    [ClearanceMethod]         CHAR (1)     NULL,
    [AirDT]                   DATETIME     NULL,
    [AirTime]                 DATETIME     NULL,
    [ProgramID]               INT          NULL,
    [EpisodeID]               VARCHAR (50) NULL,
    [ElapsedTime]             DATETIME     NULL,
    [Offset]                  INT          NULL,
    [TVNationalClearanceID]   INT          NULL,
    [MatchupID]               INT          NULL,
    [AdID]                    INT          NULL,
    [PatternID]               INT          NULL,
    [Valid]                   BIT          NULL,
    [Deleted]                 TINYINT      NOT NULL,
    [CreatedDT]               DATETIME     NULL,
    [CreatedByID]             INT          NULL,
    [ModifiedDT]              DATETIME     NULL,
    [ModifiedByID]            INT          NULL,
    [ClearanceLockDT]         DATETIME     NULL,
    CONSTRAINT [PK_OCCURRENCEDETAILTV] PRIMARY KEY CLUSTERED ([OccurrenceClearanceTVID] ASC)
);


GO

CREATE TRIGGER [dbo].[TRGAFTERUPDATEOCCURRENCEDETAILTV] ON [dbo].[OccurrenceClearanceTV] 
FOR UPDATE
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN
IF NOT EXISTS (SELECT * FROM deleted)
   RETURN
   

   INSERT INTO [OccurrenceClearanceLogTV]
	   SELECT ins.[OccurrenceClearanceTVID],
	    del.Clearance,
		del.Deleted,
		ins.Clearance,
		ins.Deleted,
		getdate()
	   FROM inserted ins inner join deleted del on ins.[OccurrenceClearanceTVID]=del.[OccurrenceClearanceTVID]
GO

CREATE TRIGGER [dbo].[TRGAFTERINSERTOCCURRENCEDETAILTV] ON [dbo].[OccurrenceClearanceTV] 
FOR INSERT
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN

	   
       INSERT INTO [OccurrenceClearanceLogTV]
	   SELECT [OccurrenceClearanceTVID],
	    NULL,
		NULL,
		Clearance,
		Deleted,
		getdate()
	   FROM inserted