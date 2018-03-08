CREATE TYPE [dbo].[ODRFtpSiteInventory] AS TABLE (
    [PK_CMSFileName]  VARCHAR (200) NOT NULL,
    [CMSFileSize]     INT           NOT NULL,
    [CMSSourceFolder] VARCHAR (200) NOT NULL,
    [CMSFileDate]     DATETIME      NOT NULL);

