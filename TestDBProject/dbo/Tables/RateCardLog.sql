CREATE TABLE [dbo].[RateCardLog] (
    [LogTimeStamp]               DATETIME     NULL,
    [LogDMLOperation]            CHAR (1)     NULL,
    [LoginUser]                  VARCHAR (32) NULL,
    [RateCardID]                 INT          NULL,
    [PublicationID]              INT          NULL,
    [OldVal_PublicationID]       INT          NULL,
    [PubEditionID]               INT          NULL,
    [OldVal_PubEditionID]        INT          NULL,
    [EffectiveDT]                DATETIME     NULL,
    [OldVal_EffectiveDT]         DATETIME     NULL,
    [ExpirationDT]               DATETIME     NULL,
    [OldVal_ExpirationDT]        DATETIME     NULL,
    [DefaultSizingMethod]        VARCHAR (50) NULL,
    [OldVal_DefaultSizingMethod] VARCHAR (50) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

