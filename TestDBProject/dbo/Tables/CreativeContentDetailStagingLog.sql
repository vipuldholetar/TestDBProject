﻿CREATE TABLE [dbo].[CreativeContentDetailStagingLog] (
    [LogTimeStamp]                   DATETIME     NULL,
    [LogDMLOperation]                CHAR (1)     NULL,
    [LoginUser]                      VARCHAR (32) NULL,
    [CreativeContentDetailStagingID] INT          NULL,
    [CreativeCropStagingID]          INT          NULL,
    [OldVal_CreativeCropStagingID]   INT          NULL,
    [ContentDetailID]                INT          NULL,
    [OldVal_ContentDetailID]         INT          NULL,
    [CreativeDetailID]               INT          NULL,
    [OldVal_CreativeDetailID]        INT          NULL,
    [SellableSpaceCoordX1]           INT          NULL,
    [OldVal_SellableSpaceCoordX1]    INT          NULL,
    [SellableSpaceCoordY1]           INT          NULL,
    [OldVal_SellableSpaceCoordY1]    INT          NULL,
    [SellableSpaceCoordX2]           INT          NULL,
    [OldVal_SellableSpaceCoordX2]    INT          NULL,
    [SellableSpaceCoordY2]           INT          NULL,
    [OldVal_SellableSpaceCoordY2]    INT          NULL,
    [LockedByID]                     INT          NULL,
    [OldVal_LockedByID]              INT          NULL,
    [LockedDT]                       DATETIME     NULL,
    [OldVal_LockedDT]                DATETIME     NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

