CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchCinema]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchCinema]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchCircular]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchCircular]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchEmail]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchEmail]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchMobile]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchMobile]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchOnlineDisplay]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchOnlineDisplay]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchAV]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchAV]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchOnlineVideo]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchOnlineVideo]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchDigital]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchDigital]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchOutdoor]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchOutdoor]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchPrint]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchPrint]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchPublication]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchPublication]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchRadio]
    ([Advertiser] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchRadio]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchRadioClassifyPromo]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchRadioClassifyPromo]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchSocial]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033, [SocialType] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchSocial]
    ON [ino_usf_ftcatalog];


GO
CREATE FULLTEXT INDEX ON [dbo].[vw_UniversalSearchTelevision]
    ([Advertiser] LANGUAGE 1033, [LastRunDate] LANGUAGE 1033, [CreateDate] LANGUAGE 1033, [LeadAudio] LANGUAGE 1033, [LeadText] LANGUAGE 1033, [RecutDetail] LANGUAGE 1033, [Language] LANGUAGE 1033, [CreativeSignature] LANGUAGE 1033, [Visual] LANGUAGE 1033, [Description] LANGUAGE 1033, [Format] LANGUAGE 1033)
    KEY INDEX [IDX_vw_UniversalSearchTelevision]
    ON [ino_usf_ftcatalog];

