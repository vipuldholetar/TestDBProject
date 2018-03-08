CREATE TABLE [dbo].[FRStatusLog] (
    [LogTimeStamp]        DATETIME     NULL,
    [LogDMLOperation]     CHAR (1)     NULL,
    [LoginUser]           VARCHAR (32) NULL,
    [FRStatusID]          INT          NULL,
    [Descrip]             VARCHAR (50) NULL,
    [OldVal_Descrip]      VARCHAR (50) NULL,
    [DisplayOrder]        INT          NULL,
    [OldVal_DisplayOrder] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

