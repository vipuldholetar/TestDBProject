CREATE TABLE [dbo].[SampleRefUser] (
    [UserID]                                     FLOAT (53)    NULL,
    [Username]                                   VARCHAR (255) NULL,
    [FName]                                      VARCHAR (255) NULL,
    [LName]                                      VARCHAR (255) NULL,
    [ActiveInd]                                  FLOAT (53)    NULL,
    [MTLegacyLocationID_(where codetypeid = 8)]  FLOAT (53)    NULL,
    [Location Descrip_(only for user reference)] VARCHAR (255) NULL,
    [Location]                                   VARCHAR (255) NULL,
    [IndHideUser]                                FLOAT (53)    NULL,
    [EmailID]                                    VARCHAR (255) NULL,
    [MTLegacyUserID]                             FLOAT (53)    NULL,
    [RonNotes]                                   VARCHAR (255) NULL
);

