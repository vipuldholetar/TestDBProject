CREATE TABLE [dbo].[JobStep] (
    [JobStepID]      INT            IDENTITY (1, 1) NOT NULL,
    [JobStepCODE]    VARCHAR (20)   NOT NULL,
    [JobCODE]        VARCHAR (20)   NOT NULL,
    [JobPackageCODE] VARCHAR (20)   NULL,
    [ProcessCODE]    VARCHAR (20)   NOT NULL,
    [Name]           VARCHAR (200)  NOT NULL,
    [Descrip]        VARCHAR (1000) NOT NULL,
    [Source]         VARCHAR (200)  NULL,
    [Target]         VARCHAR (200)  NULL,
    [Order]          INT            NOT NULL,
    [Predecessor]    INT            NOT NULL,
    [Configuration]  XML            NOT NULL,
    [CreatedDT]      DATETIME       NULL,
    [Status]         VARCHAR (50)   NULL
);

