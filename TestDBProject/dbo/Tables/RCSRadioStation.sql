CREATE TABLE [dbo].[RCSRadioStation] (
    [RCSRadioStationID] INT          NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [ShortName]         VARCHAR (50) NOT NULL,
    [RCSMarket]         VARCHAR (50) NOT NULL,
    [TimeZone]          VARCHAR (50) NOT NULL,
    [RadioFrequency]    FLOAT (53)   NOT NULL,
    [Format]            VARCHAR (50) NOT NULL,
    [LanguageId]        INT          NULL,
    [CreatedDT]         DATETIME     DEFAULT (getdate()) NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [EffectiveDT]       DATETIME     NOT NULL,
    [EndDT]             DATETIME     NOT NULL,
    CONSTRAINT [PK_RCSRadioStation] PRIMARY KEY CLUSTERED ([RCSRadioStationID] ASC)
);

