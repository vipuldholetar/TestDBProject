CREATE TABLE [dbo].[MediaIrisNodeString] (
    [MediaIrisNodeStringID] INT          NOT NULL,
    [NodeString]            VARCHAR (25) NOT NULL,
    [NodeClearanceMktCode]  VARCHAR (4)  NOT NULL,
    [CreatedDT]             DATETIME     CONSTRAINT [DF_MediaIrisNodeString_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]            DATETIME     NULL,
    CONSTRAINT [PK_MediaIrisNodeStrings_NodeId] PRIMARY KEY CLUSTERED ([MediaIrisNodeStringID] ASC)
);

