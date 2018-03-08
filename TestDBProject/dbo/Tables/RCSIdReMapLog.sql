CREATE TABLE [dbo].[RCSIdReMapLog] (
    [RSCIdReMapLogID]  INT          IDENTITY (1, 1) NOT NULL,
    [RCSOldCreativeID] VARCHAR (50) NULL,
    [RCSNewCreativeID] VARCHAR (50) NOT NULL,
    [RCSOldAircheckID] INT          NULL,
    [RCSNewAircheckID] INT          NOT NULL,
    [RCSOldClassID]    INT          NULL,
    [RCSNewClassID]    INT          NOT NULL,
    [RCSOldAccountID]  INT          NULL,
    [RCSNewAccountID]  INT          NOT NULL,
    [RCSOldAdvID]      INT          NULL,
    [RCSNewAdvID]      INT          NOT NULL,
    [RCSOldStationID]  INT          NULL,
    [RCSNewStationID]  INT          NULL,
    [OldPriority]      INT          NOT NULL,
    [NewPriority]      INT          NOT NULL,
    [RCSSeq]           BIGINT       NOT NULL,
    [CreatedDT]        DATETIME     NOT NULL,
    CONSTRAINT [PK_RCSIdReMapLog] PRIMARY KEY CLUSTERED ([RSCIdReMapLogID] ASC)
);

