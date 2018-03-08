CREATE TABLE [dbo].[Job] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [JobCODE]       VARCHAR (20)   NOT NULL,
    [ProcessCODE]   VARCHAR (20)   NOT NULL,
    [Name]          VARCHAR (200)  NOT NULL,
    [Descrip]       VARCHAR (1000) NOT NULL,
    [Status]        VARCHAR (50)   NOT NULL,
    [Type]          VARCHAR (20)   NOT NULL,
    [StartupType]   VARCHAR (20)   NOT NULL,
    [Configuration] XML            NOT NULL,
    [CreateDT]      DATETIME       NULL
);

