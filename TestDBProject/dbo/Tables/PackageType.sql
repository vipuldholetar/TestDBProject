CREATE TABLE [dbo].[PackageType] (
    [PackageTypeID]   INT          IDENTITY (1, 1) NOT NULL,
    [ShipperID]       INT          NOT NULL,
    [PackageTypeName] VARCHAR (50) NOT NULL,
    [CreatedDT]       DATETIME     CONSTRAINT [DF_PackageType_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [CreateByID]      INT          CONSTRAINT [DF_PackageType_CreateBy] DEFAULT ((1)) NOT NULL,
    [ModifiedDT]      DATETIME     NULL,
    [ModifiedByID]    INT          NULL,
    CONSTRAINT [PK_PackageType] PRIMARY KEY CLUSTERED ([PackageTypeID] ASC),
    CONSTRAINT [FK_PackageType_Shipper] FOREIGN KEY ([ShipperID]) REFERENCES [dbo].[Shipper] ([ShipperID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key in PackageType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackageType', @level2type = N'COLUMN', @level2name = N'PackageTypeID';

