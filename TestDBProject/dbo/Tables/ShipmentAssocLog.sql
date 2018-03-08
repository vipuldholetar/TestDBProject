CREATE TABLE [dbo].[ShipmentAssocLog] (
    [LogTimeStamp]         DATETIME     NULL,
    [LogDMLOperation]      CHAR (1)     NULL,
    [LoginUser]            VARCHAR (32) NULL,
    [ShipperID]            INT          NULL,
    [OldVal_ShipperID]     INT          NULL,
    [ShippingMethodID]     INT          NULL,
    [PackageTypeID]        INT          NULL,
    [OldVal_PackageTypeID] INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

