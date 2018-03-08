CREATE TABLE [dbo].[RefEthnicGroup] (
    [RefEthnicGroupID]   INT            IDENTITY (1, 1) NOT NULL,
    [CTLegacyLanguageID] INT            NULL,
    [EthnicGroupName]    VARCHAR (255)  NULL,
    [Notes]              VARCHAR (1000) NULL,
    [CreatedDT]          DATETIME       NOT NULL,
    [CreateByID]         INT            NOT NULL,
    [ModifiedDT]         DATETIME       NULL,
    [ModifiedByID]       INT            NULL,
    CONSTRAINT [PK_RefEthnicGroup] PRIMARY KEY CLUSTERED ([RefEthnicGroupID] ASC)
);

