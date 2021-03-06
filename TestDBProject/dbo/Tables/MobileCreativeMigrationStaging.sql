﻿CREATE TABLE [dbo].[MobileCreativeMigrationStaging] (
    [PK_Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [AdId]                  INT           NULL,
    [SourceOccurrenceId]    INT           NULL,
    [EnvelopId]             INT           NULL,
    [PrimaryIndicator]      BIT           NULL,
    [PrimaryQuality]        INT           NULL,
    [CreativeType]          VARCHAR (MAX) NULL,
    [StatusId]              INT           NULL,
    [PullPageCount]         INT           NULL,
    [Weight]                FLOAT (53)    NULL,
    [FormName]              VARCHAR (100) NULL,
    [CheckInOccrncs]        INT           NULL,
    [SpReviewStatusId]      INT           NULL,
    [EntryInd]              INT           NULL,
    [ParentVehicleId]       INT           NULL,
    [FilterMatches]         VARCHAR (100) NULL,
    [SourceMatchInd]        INT           NULL,
    [TypeId]                INT           NULL,
    [FlashInd]              INT           NULL,
    [CouponInd]             INT           NULL,
    [Priority]              INT           NULL,
    [NationalInd]           INT           NULL,
    [DistDate]              DATETIME      NULL,
    [Cini]                  VARCHAR (50)  NULL,
    [Erin]                  VARCHAR (50)  NULL,
    [Init]                  VARCHAR (50)  NULL,
    [AssetThmbnlName]       VARCHAR (50)  NULL,
    [ThmbnlRep]             VARCHAR (50)  NULL,
    [LegacyThmbnlAssetName] VARCHAR (50)  NULL,
    [ThmbnlFileType]        VARCHAR (50)  NULL
);

