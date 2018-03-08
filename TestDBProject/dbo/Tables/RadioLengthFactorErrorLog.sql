CREATE TABLE [dbo].[RadioLengthFactorErrorLog] (
    [RadioLengthFactorErrorLogID] INT      IDENTITY (1, 1) NOT NULL,
    [OccurrenceClientFacingRAID]  INT      NULL,
    [AdID]                        INT      NULL,
    [AdLength]                    INT      NULL,
    [InsertedDT]                  DATETIME NULL
);

