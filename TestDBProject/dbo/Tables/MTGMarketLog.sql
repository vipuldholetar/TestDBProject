CREATE TABLE [dbo].[MTGMarketLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [MTGMarketID]     INT          NULL,
    [Type]            CHAR (1)     NULL,
    [OldVal_Type]     CHAR (1)     NULL,
    [Code]            VARCHAR (4)  NULL,
    [OldVal_Code]     VARCHAR (4)  NULL,
    [Name]            VARCHAR (25) NULL,
    [OldVal_Name]     VARCHAR (25) NULL,
    [State]           VARCHAR (3)  NULL,
    [OldVal_State]    VARCHAR (3)  NULL,
    [Region]          VARCHAR (4)  NULL,
    [OldVal_Region]   VARCHAR (4)  NULL,
    [Country]         VARCHAR (4)  NULL,
    [OldVal_Country]  VARCHAR (4)  NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

