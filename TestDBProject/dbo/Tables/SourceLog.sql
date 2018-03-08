CREATE TABLE [dbo].[SourceLog] (
    [LogTimeStamp]            DATETIME     NULL,
    [LogDMLOperation]         CHAR (1)     NULL,
    [LoginUser]               VARCHAR (32) NULL,
    [SourceID]                INT          NULL,
    [ActiveInd]               TINYINT      NULL,
    [OldVal_ActiveInd]        TINYINT      NULL,
    [Descrip]                 VARCHAR (50) NULL,
    [OldVal_Descrip]          VARCHAR (50) NULL,
    [CreatedDT]               DATETIME     NULL,
    [OldVal_CreatedDT]        DATETIME     NULL,
    [CreateByID]              INT          NULL,
    [OldVal_CreateByID]       INT          NULL,
    [ModifiedDT]              DATETIME     NULL,
    [OldVal_ModifiedDT]       DATETIME     NULL,
    [ModifiedByID]            INT          NULL,
    [OldVal_ModifiedByID]     INT          NULL,
    [MTLegacySourceID]        INT          NULL,
    [OldVal_MTLegacySourceID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

