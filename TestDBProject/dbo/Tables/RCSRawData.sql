﻿CREATE TABLE [dbo].[RCSRawData] (
    [RCSRawDataID]    INT            IDENTITY (1, 1) NOT NULL,
    [MediaType]       VARCHAR (1)    NOT NULL,
    [StationID]       INT            NOT NULL,
    [StartDT]         DATETIME       NOT NULL,
    [EndDT]           DATETIME       NOT NULL,
    [TitleID]         INT            NOT NULL,
    [AcID]            BIGINT         NOT NULL,
    [MetaTitleID]     INT            NOT NULL,
    [CreativeID]      VARCHAR (255)  NULL,
    [PaID]            INT            NOT NULL,
    [ClassID]         INT            NOT NULL,
    [Action]          TINYINT        NOT NULL,
    [SeqID]           BIGINT         NOT NULL,
    [BatchID]         INT            NOT NULL,
    [ParsedDT]        DATETIME       NOT NULL,
    [ClassName]       NVARCHAR (250) NOT NULL,
    [AcctName]        NVARCHAR (250) NOT NULL,
    [AdvName]         NVARCHAR (250) NOT NULL,
    [IngestionStatus] TINYINT        NULL,
    [CreatedDT]       DATETIME       NOT NULL,
    [CreatedByID]     INT            NOT NULL,
    [ModifiedDT]      DATETIME       NULL,
    [ModifiedByID]    INT            NULL,
    CONSTRAINT [PK_RCSRawData_1] PRIMARY KEY CLUSTERED ([RCSRawDataID] ASC)
);

