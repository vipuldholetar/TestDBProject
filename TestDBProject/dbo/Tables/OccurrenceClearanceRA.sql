CREATE TABLE [dbo].[OccurrenceClearanceRA] (
    [OccurrenceClearanceRAID] INT          IDENTITY (1, 1) NOT NULL,
    [OccurrenceDetailRAID]    INT          NOT NULL,
    [Clearance]               VARCHAR (50) NULL,
    [Deleted]                 TINYINT      NOT NULL,
    [CreatedDT]               DATETIME     NULL,
    [CreatedByID]             INT          NULL,
    [ModifiedDT]              DATETIME     NULL,
    [ModifiedByID]            INT          NULL,
    CONSTRAINT [PK_OCCURRENCECLEARANCERA] PRIMARY KEY CLUSTERED ([OccurrenceClearanceRAID] ASC)
);


GO

CREATE TRIGGER [dbo].[TRGAFTERINSERTOCCURRENCECLEARANCERA] ON [dbo].[OccurrenceClearanceRA] 
FOR INSERT
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN

	   
       INSERT INTO [OccurrenceClearanceLogRA]
	   SELECT [OccurrenceClearanceRAID],
	    NULL,
		NULL,
		Clearance,
		Deleted,
		getdate()
	   FROM inserted

GO

CREATE TRIGGER [dbo].[TRGAFTERUPDATEOCCURRENCECLEARANCERA] ON [dbo].[OccurrenceClearanceRA] 
FOR UPDATE
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN
IF NOT EXISTS (SELECT * FROM deleted)
   RETURN
   

   INSERT INTO [OccurrenceClearanceLogRA]
	   SELECT ins.[OccurrenceClearanceRAID],
	    del.Clearance,
		del.Deleted,
		ins.Clearance,
		ins.Deleted,
		getdate()
	   FROM inserted ins inner join deleted del on ins.[OccurrenceClearanceRAID]=del.[OccurrenceClearanceRAID]
