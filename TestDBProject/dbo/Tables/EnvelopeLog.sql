﻿CREATE TABLE [dbo].[EnvelopeLog] (
    [LogTimeStamp]               DATETIME      NULL,
    [LogDMLOperation]            CHAR (1)      NULL,
    [LoginUser]                  VARCHAR (32)  NULL,
    [EnvelopeID]                 INT           NULL,
    [ReceivedDT]                 DATETIME      NULL,
    [OldVal_ReceivedDT]          DATETIME      NULL,
    [SenderID]                   INT           NULL,
    [OldVal_SenderID]            INT           NULL,
    [ReceivedByID]               INT           NULL,
    [OldVal_ReceivedByID]        INT           NULL,
    [ShipperID]                  INT           NULL,
    [OldVal_ShipperID]           INT           NULL,
    [ShippingMethodID]           INT           NULL,
    [OldVal_ShippingMethodID]    INT           NULL,
    [TrackingNumber]             VARCHAR (100) NULL,
    [OldVal_TrackingNumber]      VARCHAR (100) NULL,
    [ActualWeight]               FLOAT (53)    NULL,
    [OldVal_ActualWeight]        FLOAT (53)    NULL,
    [ListedWeight]               FLOAT (53)    NULL,
    [OldVal_ListedWeight]        FLOAT (53)    NULL,
    [PackageTypeID]              INT           NULL,
    [OldVal_PackageTypeID]       INT           NULL,
    [PackageAssignmentID]        INT           NULL,
    [OldVal_PackageAssignmentID] INT           NULL,
    [FormName]                   VARCHAR (100) NULL,
    [OldVal_FormName]            VARCHAR (100) NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);
