﻿CREATE TABLE [dbo].[NLSNNetworkAndCableComRating] (
    [NLSNNetworkAndCableComRatingID] UNIQUEIDENTIFIER NOT NULL,
    [StationID]                      VARCHAR (50)     NOT NULL,
    [AirDT]                          DATETIME         NOT NULL,
    [StartTime]                      TIME (7)         NOT NULL,
    [EndTime]                        TIME (7)         NOT NULL,
    [HouseHold]                      BIGINT           NOT NULL,
    [National_FC2_5]                 BIGINT           NULL,
    [National_FC6_8]                 BIGINT           NULL,
    [National_FC9_11]                BIGINT           NULL,
    [National_FT12_14]               BIGINT           NULL,
    [National_FT15_17]               BIGINT           NULL,
    [National__F18_20]               BIGINT           NULL,
    [National_F21_24]                BIGINT           NULL,
    [National_F25_29]                BIGINT           NULL,
    [National_F30_34]                BIGINT           NULL,
    [National_F35_39]                BIGINT           NULL,
    [National_F40_44]                BIGINT           NULL,
    [National_F45_49]                BIGINT           NULL,
    [National_F50_54]                BIGINT           NULL,
    [National_F55_64]                BIGINT           NULL,
    [National_F65PLUS]               BIGINT           NULL,
    [National_MC2_5]                 BIGINT           NULL,
    [National_MC6_8]                 BIGINT           NULL,
    [National_MC9_11]                BIGINT           NULL,
    [National_MT12_14]               BIGINT           NULL,
    [National_MT15_17]               BIGINT           NULL,
    [National_M18_20]                BIGINT           NULL,
    [National_M21_24]                BIGINT           NULL,
    [National_M25_29]                BIGINT           NULL,
    [National_M30_34]                BIGINT           NULL,
    [National_M35_39]                BIGINT           NULL,
    [National_M40_44]                BIGINT           NULL,
    [National_M45_49]                BIGINT           NULL,
    [National_M50_54]                BIGINT           NULL,
    [National_M55_64]                BIGINT           NULL,
    [National_M65PLUS]               BIGINT           NULL,
    CONSTRAINT [PK_NLSNNetworkAndCableComRating] PRIMARY KEY CLUSTERED ([NLSNNetworkAndCableComRatingID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_NLSNNetworkAndCableComRating_17_21627170__K5]
    ON [dbo].[NLSNNetworkAndCableComRating]([EndTime] ASC);

