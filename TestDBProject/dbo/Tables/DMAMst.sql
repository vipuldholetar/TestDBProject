CREATE TABLE [dbo].[DMAMst] (
    [DMAID]        INT           NOT NULL,
    [Descrip]      VARCHAR (100) NOT NULL,
    [CreatedDT]    DATETIME      NOT NULL,
    [CreatedByID]  INT           NOT NULL,
    [ModifiedDT]   DATETIME      NOT NULL,
    [ModifiedByID] INT           NOT NULL,
    CONSTRAINT [PK_DMA_Mst] PRIMARY KEY CLUSTERED ([DMAID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Designated Market codes, This table should be used for all TV Ingestions processes like TMS, COMSCORE, NIELSEN Etc..', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DMAMst';

