CREATE TABLE [dbo].[SystemConfiguration] (
    [ConfigID]      INT           NULL,
    [EffectiveDT]   DATETIME      NULL,
    [EndDT]         DATETIME      NULL,
    [SystemName]    VARCHAR (200) NOT NULL,
    [ComponentName] VARCHAR (200) NOT NULL,
    [ValueGroup]    VARCHAR (200) NOT NULL,
    [Value]         VARCHAR (200) NOT NULL,
    [ValueTitle]    VARCHAR (200) NOT NULL,
    [ValueType]     VARCHAR (200) NOT NULL,
    [Notes]         VARCHAR (200) NOT NULL,
    [CreatedDT]     DATETIME      NOT NULL,
    [CreateByID]    INT           NOT NULL,
    [ModifiedDT]    DATETIME      NULL,
    [ModifiedByID]  INT           NULL
);

