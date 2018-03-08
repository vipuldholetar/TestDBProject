CREATE TABLE [dbo].[UserRolesLog] (
    [LogTimeStamp]    DATETIME     NULL,
    [LogDMLOperation] CHAR (1)     NULL,
    [LoginUser]       VARCHAR (32) NULL,
    [UserID]          INT          NULL,
    [RoleID]          INT          NULL,
    [OldVal_RoleID]   INT          NULL,
    CHECK ([LogDMLOperation]='U' OR [LogDMLOperation]='I' OR [LogDMLOperation]='D')
);

