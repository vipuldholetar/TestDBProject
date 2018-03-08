CREATE TABLE [dbo].[NLSNFTPLog] (
    [NLSNFTPLogID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [FileType]     VARCHAR (2)   NOT NULL,
    [FTPFolder]    VARCHAR (100) NOT NULL,
    [FTPFileName]  VARCHAR (100) NOT NULL,
    [DownloadDT]   DATETIME      NOT NULL,
    [UnzipDT]      DATETIME      NULL,
    [ProcessDT]    DATETIME      NULL,
    CONSTRAINT [PK_NLSFTPLog] PRIMARY KEY CLUSTERED ([NLSNFTPLogID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table will hold the FTP relevant logs. TBD - A genral log table as part of Spend Framework Methodolgy can take care of this. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NLSNFTPLog';

