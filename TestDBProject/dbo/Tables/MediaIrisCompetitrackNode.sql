CREATE TABLE [dbo].[MediaIrisCompetitrackNode] (
    [MediaIrisCompetitrackNodeID] INT          IDENTITY (1, 1) NOT NULL,
    [Server]                      VARCHAR (63) NOT NULL,
    [Source]                      VARCHAR (2)  NOT NULL,
    [CreatedDT]                   DATETIME     CONSTRAINT [MediaIrisCompetitrackNode_DefaultCreateDTM] DEFAULT (getdate()) NOT NULL,
    [ClearanceMktCODE]            VARCHAR (4)  NOT NULL,
    CONSTRAINT [PK_MediaIrisCompetitrackNode] PRIMARY KEY CLUSTERED ([MediaIrisCompetitrackNodeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MediaIrisCompetitrackNode_Server]
    ON [dbo].[MediaIrisCompetitrackNode]([Server] ASC);

