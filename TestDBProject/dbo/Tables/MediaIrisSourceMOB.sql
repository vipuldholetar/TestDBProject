﻿CREATE TABLE [dbo].[MediaIrisSourceMOB] (
    [ResultID]           BIGINT         NULL,
    [Type]               VARCHAR (10)   NULL,
    [AdFilename]         VARCHAR (255)  NULL,
    [FullPathFilename]   VARCHAR (60)   NULL,
    [Url]                VARCHAR (300)  NULL,
    [ScreenshotFilename] VARCHAR (60)   NULL,
    [TimeStamp]          VARCHAR (14)   NULL,
    [SysTimeStamp]       DATETIME2 (7)  NULL,
    [Server]             VARCHAR (63)   NULL,
    [Site]               VARCHAR (50)   NULL,
    [AdSize]             INT            NULL,
    [CreativeID]         INT            NULL,
    [CountryCODE]        INT            NULL,
    [IP]                 VARCHAR (15)   NULL,
    [Src]                VARCHAR (300)  NULL,
    [Height]             VARCHAR (10)   NULL,
    [Width]              VARCHAR (10)   NULL,
    [LpUrl]              VARCHAR (1000) NULL,
    [ElementType]        VARCHAR (45)   NULL,
    [OffsetX]            INT            NULL,
    [OffsetY]            INT            NULL,
    [PageTitle]          VARCHAR (500)  NULL,
    [AdMD5]              VARCHAR (50)   NULL,
    [LpUrlOriginal]      VARCHAR (1000) NULL,
    [AdSHA1]             VARCHAR (50)   NULL,
    [AdFullPathFilename] VARCHAR (60)   NULL,
    [CreativeType]       VARCHAR (20)   NULL,
    [DataSet]            INT            NULL,
    [Environment]        VARCHAR (100)  NULL,
    [ConvertedDATE]      AS             (CONVERT([date],stuff(stuff(stuff([TimeStamp],(9),(0),' '),(12),(0),':'),(15),(0),':'))),
    [ConvertedDT]        AS             (CONVERT([datetime],stuff(stuff(stuff([TimeStamp],(9),(0),' '),(12),(0),':'),(15),(0),':'))),
    [UrlSHA1]            AS             (CONVERT([char],hashbytes('SHA1',[Url]),(2))),
    [LpUrlSHA1]          AS             (CONVERT([char],hashbytes('SHA1',[LpURL]),(2))),
    [SrcSHA1]            AS             (CONVERT([char],hashbytes('SHA1',[Src]),(2)))
);


GO
CREATE NONCLUSTERED INDEX [IX_MediaIrisSourceMOB_Comb1]
    ON [dbo].[MediaIrisSourceMOB]([DataSet] ASC, [AdSHA1] ASC, [CreativeType] ASC)
    INCLUDE([Server], [Site], [AdSize], [CreativeID], [Src], [AdFullPathFilename]);

