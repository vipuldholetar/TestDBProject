CREATE TABLE [dbo].[MediaIrisCompetitrackDeviceMap] (
    [DeviceMapID]         INT          NOT NULL,
    [MediaIrisDeviceID]   INT          NOT NULL,
    [MobileDeviceID]      INT          NOT NULL,
    [EffectiveStartDT]    DATE         NOT NULL,
    [EffectiveEndDT]      DATE         NOT NULL,
    [MediaIrisDeviceName] VARCHAR (50) NULL,
    [CreatedDT]           DATETIME     CONSTRAINT [DF_MediaIrisDeviceMap_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [ModifiedDT]          DATETIME     NULL,
    CONSTRAINT [PK_MediaIrisDeviceMap] PRIMARY KEY CLUSTERED ([DeviceMapID] ASC),
    CONSTRAINT [FK_MediaIrisDeviceMap_MobileDevice] FOREIGN KEY ([MobileDeviceID]) REFERENCES [dbo].[MobileDevice] ([MobileDeviceID])
);

