CREATE TABLE [dbo].[TMSEthnicGroup] (
    [TMSEthnicGroupID] INT          NOT NULL,
    [Descrip]          VARCHAR (20) NOT NULL,
    [CreatedDT]        DATETIME     NOT NULL,
    [CreateByID]       INT          NOT NULL,
    [ModifiedDT]       DATETIME     NOT NULL,
    [ModifiedByID]     INT          NOT NULL,
    CONSTRAINT [PK_TMSEthnicGrpMaster] PRIMARY KEY CLUSTERED ([TMSEthnicGroupID] ASC)
);

