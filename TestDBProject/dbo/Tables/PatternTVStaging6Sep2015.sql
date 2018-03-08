CREATE TABLE [dbo].[PatternTVStaging6Sep2015] (
    [PatternStagingTV6Sep2015ID] INT             IDENTITY (1, 1) NOT NULL,
    [CreativeStagingID]          INT             NULL,
    [CreativeSignatureID]        VARCHAR (200)   NOT NULL,
    [ScoreQ]                     INT             NULL,
    [Query]                      TINYINT         NULL,
    [Exception]                  TINYINT         NULL,
    [LanguageID]                 INT             NULL,
    [MOTReasonCODE]              VARCHAR (100)   NULL,
    [NoTakeReasonCODE]           VARBINARY (100) NULL
);

