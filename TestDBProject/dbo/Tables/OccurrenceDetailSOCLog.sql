﻿CREATE TABLE [dbo].[OccurrenceDetailSOCLog] (
    [LogTimeStamp]          DATETIME      NULL,
    [LogDMLOperation]       CHAR (1)      NULL,
    [LoginUser]             VARCHAR (32)  NULL,
    [OccurrenceDetailSOCID] BIGINT        NULL,
    [MediaTypeID]           INT           NULL,
    [MarketID]              INT           NULL,
    [EnvelopeID]            INT           NULL,
    [AdID]                  INT           NULL,
    [PatternID]             INT           NULL,
    [SocialType]            VARCHAR (MAX) NULL,
    [DistributionDT]        DATETIME      NULL,
    [AdDT]                  DATETIME      NULL,
    [Priority]              INT           NULL,
    [SubjectPost]           VARCHAR (MAX) NULL,
    [LandingPageURL]        VARCHAR (MAX) NULL,
    [URL]                   VARCHAR (MAX) NULL,
    [CountryOrigin]         VARCHAR (MAX) NULL,
    [FormatCode]            VARCHAR (MAX) NULL,
    [RatingCode]            VARCHAR (MAX) NULL,
    [RelationshiptoAdv]     VARCHAR (MAX) NULL,
    [PromotionalInd]        TINYINT       NULL,
    [PromoFlagReason]       VARCHAR (MAX) NULL,
    [AssignedtoOffice]      VARCHAR (MAX) NULL,
    [NoTakeReason]          VARCHAR (MAX) NULL,
    [Query]                 TINYINT       NULL,
    [MapStatusID]           INT           NULL,
    [IndexStatusID]         INT           NULL,
    [ScanStatusID]          INT           NULL,
    [QCStatusID]            INT           NULL,
    [RouteStatusID]         INT           NULL,
    [OccurrenceStatusID]    INT           NULL,
    [CreateFromAuditInd]    TINYINT       NULL,
    [FlyerID]               INT           NULL,
    [AuditedByID]           INT           NULL,
    [AuditedDT]             DATETIME      NULL,
    [CreatedDT]             DATETIME      NULL,
    [CreatedByID]           INT           NULL,
    [ModifiedDT]            DATETIME      NULL,
    [ModifiedByID]          INT           NULL,
    [WebsiteID]             INT           NULL,
    [OldVal_WebsiteID]      INT           NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

