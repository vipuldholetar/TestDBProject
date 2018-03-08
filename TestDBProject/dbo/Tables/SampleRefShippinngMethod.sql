CREATE TABLE [dbo].[SampleRefShippinngMethod] (
    [SampleRefShippinngMethodID]             FLOAT (53)    NULL,
    [ShipperID]                              FLOAT (53)    NULL,
    [Shipper Name_(only for user reference)] VARCHAR (255) NULL,
    [ShippingMethodName]                     VARCHAR (255) NULL,
    [KimComments]                            VARCHAR (255) NULL,
    [IndNeedTrackingNo]                      FLOAT (53)    NULL,
    [IndWeighBasedCost]                      VARCHAR (255) NULL,
    [CreatedDT]                              VARCHAR (255) NULL,
    [CreatedByID]                            VARCHAR (255) NULL,
    [ModifiedDT]                             VARCHAR (255) NULL,
    [ModifiedByID]                           VARCHAR (255) NULL,
    [MTLegacyCodeID_(where CodeTypeID = 2)]  FLOAT (53)    NULL
);

