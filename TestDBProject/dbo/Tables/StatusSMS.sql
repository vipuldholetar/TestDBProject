CREATE TABLE [dbo].[StatusSMS] (
    [StatusSMSID] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDT]   DATETIME      NULL,
    [MessageID]   VARCHAR (50)  NULL,
    [MessageText] VARCHAR (MAX) NULL,
    [Destination] VARCHAR (50)  NULL,
    [StatusCode]  VARCHAR (50)  NULL,
    CONSTRAINT [PK_STATUS_SMS] PRIMARY KEY CLUSTERED ([StatusSMSID] ASC)
);

