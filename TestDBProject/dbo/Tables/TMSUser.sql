CREATE TABLE [dbo].[TMSUser] (
    [TMSUserID]    INT          IDENTITY (1, 1) NOT NULL,
    [UserName]     VARCHAR (20) NOT NULL,
    [CreatedDT]    DATETIME     NULL,
    [CreatedByID]  INT          NULL,
    [ModifiedDT]   DATETIME     NULL,
    [ModifiedByID] INT          NULL,
    CONSTRAINT [PK_TMSUsers] PRIMARY KEY CLUSTERED ([TMSUserID] ASC)
);

