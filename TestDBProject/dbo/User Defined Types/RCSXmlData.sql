CREATE TYPE [dbo].[RCSXmlData] AS TABLE (
    [MediaType]   VARCHAR (1)    NOT NULL,
    [StationId]   INT            NOT NULL,
    [StartTime]   DATETIME       NOT NULL,
    [EndTime]     DATETIME       NOT NULL,
    [TitleId]     INT            NOT NULL,
    [AcId]        BIGINT         NOT NULL,
    [MetaTitleId] INT            NOT NULL,
    [CreativeId]  VARCHAR (255)  NOT NULL,
    [PaId]        INT            NOT NULL,
    [ClassId]     INT            NOT NULL,
    [Action]      BIT            NOT NULL,
    [SeqId]       VARCHAR (15)   NOT NULL,
    [ClassName]   NVARCHAR (250) NOT NULL,
    [AcctName]    NVARCHAR (250) NOT NULL,
    [AdvName]     NVARCHAR (250) NOT NULL);

