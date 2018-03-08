CREATE TABLE [dbo].[TMSTvProg] (
    [TMSTvProgID]  INT           IDENTITY (1, 1) NOT NULL,
    [ProgDescrip]  VARCHAR (250) NOT NULL,
    [CreatedDT]    DATETIME      CONSTRAINT [DF_TMSTvProgMaster_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedByID]  INT           NULL,
    [ModifiedDT]   DATETIME      CONSTRAINT [DF_TMSTvProgMaster_ModifyDate] DEFAULT (getdate()) NULL,
    [ModifiedByID] INT           NULL,
    CONSTRAINT [PK_TMSTvProgMaster] PRIMARY KEY CLUSTERED ([TMSTvProgID] ASC)
);

