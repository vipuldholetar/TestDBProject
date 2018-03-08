CREATE TABLE [dbo].[TVEthnicPRCodes_Backup] (
    [PK_Id]            VARCHAR (200) NOT NULL,
    [FK_EthnicGroupId] INT           NOT NULL,
    [OriginalPRCode]   VARCHAR (200) NOT NULL,
    [CreateDTM]        DATETIME      NOT NULL
);

