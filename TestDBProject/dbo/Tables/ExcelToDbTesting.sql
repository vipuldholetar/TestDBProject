CREATE TABLE [dbo].[ExcelToDbTesting] (
    [ExcelToDbTestingID] INT           IDENTITY (1, 1) NOT NULL,
    [Name]               VARCHAR (255) NOT NULL,
    [DateOfBirth]        DATETIME      NOT NULL,
    [Place]              VARCHAR (50)  NULL,
    [Height]             FLOAT (53)    NULL,
    [Active]             BIT           NULL,
    CONSTRAINT [PK__ExcelToD__F4A24B22F63F98C2] PRIMARY KEY CLUSTERED ([ExcelToDbTestingID] ASC)
);

