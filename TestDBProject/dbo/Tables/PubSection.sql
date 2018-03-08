CREATE TABLE [dbo].[PubSection] (
    [PubSectionID]   INT            IDENTITY (1, 1) NOT NULL,
    [PublicationID]  INT            NOT NULL,
    [PubSectionName] NVARCHAR (MAX) NOT NULL,
    [EqAdvertiserID] NVARCHAR (MAX) NULL,
    [CreatedDT]      DATETIME       NOT NULL,
    [CreatedByID]    INT            NOT NULL,
    [ModifiedDT]     DATETIME       NULL,
    [ModifiedByID]   INT            NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This lists the equivalent AdvertiserID for this section.  This is for Coupon Book to PUB.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubSection', @level2type = N'COLUMN', @level2name = N'EqAdvertiserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Created Date & Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubSection', @level2type = N'COLUMN', @level2name = N'CreatedDT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Created by User', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubSection', @level2type = N'COLUMN', @level2name = N'CreatedByID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Modified Date & Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubSection', @level2type = N'COLUMN', @level2name = N'ModifiedDT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Modified by user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PubSection', @level2type = N'COLUMN', @level2name = N'ModifiedByID';

