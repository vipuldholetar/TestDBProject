﻿CREATE TABLE [dbo].[PatternLogStagingRadio_XXX] (
    [LogTimeStamp]                      DATETIME      NULL,
    [LogDMLOperation]                   CHAR (1)      NULL,
    [LoginUser]                         VARCHAR (32)  NULL,
    [PatternID]                         INT           NULL,
    [OldValue_PatternID]                INT           NULL,
    [CreativeID]                        INT           NULL,
    [OldValue_CreativeID]               INT           NULL,
    [AdID]                              VARCHAR (15)  NULL,
    [OldValue_AdID]                     INT           NULL,
    [MediaStream]                       INT           NULL,
    [OldValue_MediaStream]              INT           NULL,
    [Exception]                         TINYINT       NULL,
    [OldValue_Exception]                TINYINT       NULL,
    [Priority]                          INT           NULL,
    [OldValue_Priority]                 INT           NULL,
    [ExceptionText]                     VARCHAR (50)  NULL,
    [OldValue_ExceptionText]            VARCHAR (50)  NULL,
    [Query]                             TINYINT       NULL,
    [OldValue_Query]                    TINYINT       NULL,
    [QueryCategory]                     INT           NULL,
    [OldValue_QueryCategory]            INT           NULL,
    [QueryText]                         VARCHAR (50)  NULL,
    [OldValue_QueryText]                VARCHAR (50)  NULL,
    [QueryAnswer]                       VARCHAR (MAX) NULL,
    [OldValue_QueryAnswer]              VARCHAR (MAX) NULL,
    [TakeReasonCode]                    VARCHAR (50)  NULL,
    [OldValue_TakeReasonCode]           VARCHAR (50)  NULL,
    [NoTakeReasonCode]                  VARCHAR (50)  NULL,
    [OldValue_NoTakeReasonCode]         VARCHAR (50)  NULL,
    [Status]                            VARCHAR (50)  NULL,
    [OldValue_Status]                   VARCHAR (50)  NULL,
    [EventID]                           INT           NULL,
    [OldValue_EventID]                  INT           NULL,
    [ThemeID]                           INT           NULL,
    [OldValue_ThemeID]                  INT           NULL,
    [SalesStartDT]                      DATETIME      NULL,
    [OldValue_SalesStartDT]             DATETIME      NULL,
    [SalesEndDT]                        DATETIME      NULL,
    [OldValue_SalesEndDT]               DATETIME      NULL,
    [FlashInd]                          TINYINT       NULL,
    [OldValue_FlashInd]                 TINYINT       NULL,
    [NationalIndicator]                 TINYINT       NULL,
    [OldValue_NationalIndicator]        TINYINT       NULL,
    [CreateBy]                          INT           NULL,
    [OldValue_CreateBy]                 INT           NULL,
    [CreateDate]                        DATETIME      NULL,
    [OldValue_CreateDate]               DATETIME      NULL,
    [ModifiedBy]                        INT           NULL,
    [OldValue_ModifiedBy]               INT           NULL,
    [ModifyDate]                        DATETIME      NULL,
    [OldValue_ModifyDate]               DATETIME      NULL,
    [EditInits]                         INT           NULL,
    [OldValue_EditInits]                INT           NULL,
    [LastMappedDate]                    DATETIME      NULL,
    [OldValue_LastMappedDate]           DATETIME      NULL,
    [LastMapperInits]                   INT           NULL,
    [OldValue_LastMapperInits]          INT           NULL,
    [CouponIndicator]                   BIT           NULL,
    [OldValue_CouponIndicator]          BIT           NULL,
    [CreativeSignature]                 VARCHAR (200) NULL,
    [OldValue_CreativeSignature]        VARCHAR (200) NULL,
    [AuditBy]                           VARCHAR (50)  NULL,
    [OldValue_AuditBy]                  VARCHAR (50)  NULL,
    [AuditDate]                         DATETIME      NULL,
    [OldValue_AuditDate]                DATETIME      NULL,
    [AdvertiserNameSuggestion]          VARCHAR (50)  NULL,
    [OldValue_AdvertiserNameSuggestion] VARCHAR (50)  NULL
);

