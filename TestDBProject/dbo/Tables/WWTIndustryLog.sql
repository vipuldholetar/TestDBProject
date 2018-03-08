CREATE TABLE [dbo].[WWTIndustryLog] (
    [LogTimeStamp]                     DATETIME      NULL,
    [LogDMLOperation]                  CHAR (1)      NULL,
    [LoginUser]                        VARCHAR (32)  NULL,
    [WWTIndustryID]                    INT           NULL,
    [RefIndustryGroupID]               INT           NULL,
    [OldVal_RefIndustryGroupID]        INT           NULL,
    [IndustryName]                     VARCHAR (100) NULL,
    [OldVal_IndustryName]              VARCHAR (100) NULL,
    [ClassificationGroupId]            INT           NULL,
    [OldVal_ClassificationGroupId]     INT           NULL,
    [AdvRegistrationAttemptInd]        TINYINT       NULL,
    [OldVal_AdvRegistrationAttemptInd] TINYINT       NULL,
    [AdvRegistrationAllowInd]          TINYINT       NULL,
    [OldVal_AdvRegistrationAllowInd]   TINYINT       NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

