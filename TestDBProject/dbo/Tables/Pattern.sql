CREATE TABLE [dbo].[Pattern] (
    [PatternID]                INT           IDENTITY (1, 1) NOT NULL,
    [CreativeID]               INT           NULL,
    [AdID]                     INT           NULL,
    [MediaStream]              INT           NULL,
    [Exception]                TINYINT       NULL,
    [Priority]                 INT           NULL,
    [ExceptionText]            VARCHAR (50)  NULL,
    [Query]                    TINYINT       NULL,
    [QueryCategory]            INT           NULL,
    [QueryText]                VARCHAR (50)  NULL,
    [QueryAnswer]              VARCHAR (MAX) NULL,
    [TakeReasonCode]           VARCHAR (50)  NULL,
    [NoTakeReasonCode]         VARCHAR (50)  NULL,
    [Status]                   VARCHAR (50)  NOT NULL,
    [EventID]                  INT           NULL,
    [ThemeID]                  INT           NULL,
    [SalesStartDT]             DATETIME      NULL,
    [SalesEndDT]               DATETIME      NULL,
    [FlashInd]                 TINYINT       NULL,
    [NationalIndicator]        TINYINT       NULL,
    [CreateBy]                 INT           NULL,
    [CreateDate]               DATETIME      DEFAULT (getdate()) NULL,
    [ModifiedBy]               INT           NULL,
    [ModifyDate]               DATETIME      NULL,
    [EditInits]                INT           NULL,
    [LastMappedDate]           DATETIME      NULL,
    [LastMapperInits]          INT           NULL,
    [CouponIndicator]          BIT           NULL,
    [CreativeSignature]        VARCHAR (200) NULL,
    [AuditBy]                  VARCHAR (50)  NULL,
    [AuditDate]                DATETIME      NULL,
    [AdvertiserNameSuggestion] VARCHAR (256) NULL,
    [FormatCode]               VARCHAR (10)  NULL,
    CONSTRAINT [PK_PatternMaster_1] PRIMARY KEY CLUSTERED ([PatternID] ASC),
    CONSTRAINT [FK_Pattern_To_Ad] FOREIGN KEY ([AdID]) REFERENCES [dbo].[Ad] ([AdID]) ON DELETE SET NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Pattern_StreamAndSignature]
    ON [dbo].[Pattern]([MediaStream] ASC, [CreativeSignature] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Pattern_Combo_1]
    ON [dbo].[Pattern]([MediaStream] ASC, [AdID] ASC, [CreativeID] ASC)
    INCLUDE([PatternID], [CreativeSignature]);


GO
CREATE NONCLUSTERED INDEX [IX_Pattern_AdId]
    ON [dbo].[Pattern]([AdID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CreativeIDAdID]
    ON [dbo].[Pattern]([CreativeID] ASC, [AdID] ASC)
    INCLUDE([PatternID], [MediaStream]);


GO

CREATE TRIGGER mt_trDeleteTriggerToLogOnPattern ON Pattern
	FOR DELETE AS 
SET NOCOUNT ON
insert into PatternLog(LogTimeStamp, LogDMLOperation, LoginUser, [PatternID], [CreativeID], [AdID], [MediaStream], [Exception], [Priority], [ExceptionText], [Query], [QueryCategory], [QueryText], [QueryAnswer], [TakeReasonCode], [NoTakeReasonCode], [Status], [EventID], [ThemeID], [SalesStartDT], [SalesEndDT], [FlashInd], [NationalIndicator], [CreateBy], [CreateDate], [ModifiedBy], [ModifyDate], [EditInits], [LastMappedDate], [LastMapperInits], [CouponIndicator], [CreativeSignature], [AuditBy], [AuditDate], [AdvertiserNameSuggestion], [FormatCode])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[PatternID],  D.[CreativeID],  D.[AdID],  D.[MediaStream],  D.[Exception],  D.[Priority],  D.[ExceptionText],  D.[Query],  D.[QueryCategory],  D.[QueryText],  D.[QueryAnswer],  D.[TakeReasonCode],  D.[NoTakeReasonCode],  D.[Status],  D.[EventID],  D.[ThemeID],  D.[SalesStartDT],  D.[SalesEndDT],  D.[FlashInd],  D.[NationalIndicator],  D.[CreateBy],  D.[CreateDate],  D.[ModifiedBy],  D.[ModifyDate],  D.[EditInits],  D.[LastMappedDate],  D.[LastMapperInits],  D.[CouponIndicator],  D.[CreativeSignature],  D.[AuditBy],  D.[AuditDate],  D.[AdvertiserNameSuggestion],  D.[FormatCode]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into PatternLog for any record DELETED in Pattern.
The inserted row will contain the record that was deleted from the original table */
GO
CREATE TRIGGER mt_trInsertTriggerToLogOnPattern ON Pattern
	FOR INSERT AS 
SET NOCOUNT ON
insert into PatternLog(LogTimeStamp, LogDMLOperation, LoginUser, [PatternID], [CreativeID], [AdID], [MediaStream], [Exception], [Priority], [ExceptionText], [Query], [QueryCategory], [QueryText], [QueryAnswer], [TakeReasonCode], [NoTakeReasonCode], [Status], [EventID], [ThemeID], [SalesStartDT], [SalesEndDT], [FlashInd], [NationalIndicator], [CreateBy], [CreateDate], [ModifiedBy], [ModifyDate], [EditInits], [LastMappedDate], [LastMapperInits], [CouponIndicator], [CreativeSignature], [AuditBy], [AuditDate], [AdvertiserNameSuggestion], [FormatCode])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[PatternID],  I.[CreativeID],  I.[AdID],  I.[MediaStream],  I.[Exception],  I.[Priority],  I.[ExceptionText],  I.[Query],  I.[QueryCategory],  I.[QueryText],  I.[QueryAnswer],  I.[TakeReasonCode],  I.[NoTakeReasonCode],  I.[Status],  I.[EventID],  I.[ThemeID],  I.[SalesStartDT],  I.[SalesEndDT],  I.[FlashInd],  I.[NationalIndicator],  I.[CreateBy],  I.[CreateDate],  I.[ModifiedBy],  I.[ModifyDate],  I.[EditInits],  I.[LastMappedDate],  I.[LastMapperInits],  I.[CouponIndicator],  I.[CreativeSignature],  I.[AuditBy],  I.[AuditDate],  I.[AdvertiserNameSuggestion],  I.[FormatCode]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into PatternLog for 
any record insert into Pattern*/
GO

 CREATE TRIGGER mt_trUpdateTriggerToLogOnPattern ON Pattern
	FOR UPDATE AS 
SET NOCOUNT ON
insert into PatternLog(LogTimeStamp, LogDMLOperation, LoginUser, [PatternID],[OldValue_PatternID], [CreativeID],[OldValue_CreativeID], [AdID],[OldValue_AdID], [MediaStream],[OldValue_MediaStream], [Exception],[OldValue_Exception], [Priority],[OldValue_Priority], [ExceptionText],[OldValue_ExceptionText], [Query],[OldValue_Query], [QueryCategory],[OldValue_QueryCategory], [QueryText],[OldValue_QueryText], [QueryAnswer],[OldValue_QueryAnswer], [TakeReasonCode],[OldValue_TakeReasonCode], [NoTakeReasonCode],[OldValue_NoTakeReasonCode], [Status],[OldValue_Status], [EventID],[OldValue_EventID], [ThemeID],[OldValue_ThemeID], [SalesStartDT],[OldValue_SalesStartDT], [SalesEndDT],[OldValue_SalesEndDT], [FlashInd],[OldValue_FlashInd], [NationalIndicator],[OldValue_NationalIndicator], [CreateBy],[OldValue_CreateBy], [CreateDate],[OldValue_CreateDate], [ModifiedBy],[OldValue_ModifiedBy], [ModifyDate],[OldValue_ModifyDate], [EditInits],[OldValue_EditInits], [LastMappedDate],[OldValue_LastMappedDate], [LastMapperInits],[OldValue_LastMapperInits], [CouponIndicator],[OldValue_CouponIndicator], [CreativeSignature],[OldValue_CreativeSignature], [AuditBy],[OldValue_AuditBy], [AuditDate],[OldValue_AuditDate], [AdvertiserNameSuggestion],[OldValue_AdvertiserNameSuggestion], [FormatCode],[OldValue_FormatCode])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[PatternID], D.[PatternID],  I.[CreativeID], D.[CreativeID],  I.[AdID], D.[AdID],  I.[MediaStream], D.[MediaStream],  I.[Exception], D.[Exception],  I.[Priority], D.[Priority],  I.[ExceptionText], D.[ExceptionText],  I.[Query], D.[Query],  I.[QueryCategory], D.[QueryCategory],  I.[QueryText], D.[QueryText],  I.[QueryAnswer], D.[QueryAnswer],  I.[TakeReasonCode], D.[TakeReasonCode],  I.[NoTakeReasonCode], D.[NoTakeReasonCode],  I.[Status], D.[Status],  I.[EventID], D.[EventID],  I.[ThemeID], D.[ThemeID],  I.[SalesStartDT], D.[SalesStartDT],  I.[SalesEndDT], D.[SalesEndDT],  I.[FlashInd], D.[FlashInd],  I.[NationalIndicator], D.[NationalIndicator],  I.[CreateBy], D.[CreateBy],  I.[CreateDate], D.[CreateDate],  I.[ModifiedBy], D.[ModifiedBy],  I.[ModifyDate], D.[ModifyDate],  I.[EditInits], D.[EditInits],  I.[LastMappedDate], D.[LastMappedDate],  I.[LastMapperInits], D.[LastMapperInits],  I.[CouponIndicator], D.[CouponIndicator],  I.[CreativeSignature], D.[CreativeSignature],  I.[AuditBy], D.[AuditBy],  I.[AuditDate], D.[AuditDate],  I.[AdvertiserNameSuggestion], D.[AdvertiserNameSuggestion],  I.[FormatCode], D.[FormatCode]
 FROM INSERTED I 
join DELETED D on
 I.[PatternID]= D.[PatternID]
 where  ( (I.[CreativeID]<> D.[CreativeID] or (I.[CreativeID] is null and D.[CreativeID] is not null) or  (I.[CreativeID] is not null and D.[CreativeID] is null)) or  (I.[AdID]<> D.[AdID] or (I.[AdID] is null and D.[AdID] is not null) or  (I.[AdID] is not null and D.[AdID] is null)) or  (I.[MediaStream]<> D.[MediaStream] or (I.[MediaStream] is null and D.[MediaStream] is not null) or  (I.[MediaStream] is not null and D.[MediaStream] is null)) or  (I.[Exception]<> D.[Exception] or (I.[Exception] is null and D.[Exception] is not null) or  (I.[Exception] is not null and D.[Exception] is null)) or  (I.[Priority]<> D.[Priority] or (I.[Priority] is null and D.[Priority] is not null) or  (I.[Priority] is not null and D.[Priority] is null)) or  (I.[ExceptionText]<> D.[ExceptionText] or (I.[ExceptionText] is null and D.[ExceptionText] is not null) or  (I.[ExceptionText] is not null and D.[ExceptionText] is null)) or  (I.[Query]<> D.[Query] or (I.[Query] is null and D.[Query] is not null) or  (I.[Query] is not null and D.[Query] is null)) or  (I.[QueryCategory]<> D.[QueryCategory] or (I.[QueryCategory] is null and D.[QueryCategory] is not null) or  (I.[QueryCategory] is not null and D.[QueryCategory] is null)) or  (I.[QueryText]<> D.[QueryText] or (I.[QueryText] is null and D.[QueryText] is not null) or  (I.[QueryText] is not null and D.[QueryText] is null)) or  (I.[QueryAnswer]<> D.[QueryAnswer] or (I.[QueryAnswer] is null and D.[QueryAnswer] is not null) or  (I.[QueryAnswer] is not null and D.[QueryAnswer] is null)) or  (I.[TakeReasonCode]<> D.[TakeReasonCode] or (I.[TakeReasonCode] is null and D.[TakeReasonCode] is not null) or  (I.[TakeReasonCode] is not null and D.[TakeReasonCode] is null)) or  (I.[NoTakeReasonCode]<> D.[NoTakeReasonCode] or (I.[NoTakeReasonCode] is null and D.[NoTakeReasonCode] is not null) or  (I.[NoTakeReasonCode] is not null and D.[NoTakeReasonCode] is null)) or  (I.[Status]<> D.[Status] or (I.[Status] is null and D.[Status] is not null) or  (I.[Status] is not null and D.[Status] is null)) or  (I.[EventID]<> D.[EventID] or (I.[EventID] is null and D.[EventID] is not null) or  (I.[EventID] is not null and D.[EventID] is null)) or  (I.[ThemeID]<> D.[ThemeID] or (I.[ThemeID] is null and D.[ThemeID] is not null) or  (I.[ThemeID] is not null and D.[ThemeID] is null)) or  (I.[SalesStartDT]<> D.[SalesStartDT] or (I.[SalesStartDT] is null and D.[SalesStartDT] is not null) or  (I.[SalesStartDT] is not null and D.[SalesStartDT] is null)) or  (I.[SalesEndDT]<> D.[SalesEndDT] or (I.[SalesEndDT] is null and D.[SalesEndDT] is not null) or  (I.[SalesEndDT] is not null and D.[SalesEndDT] is null)) or  (I.[FlashInd]<> D.[FlashInd] or (I.[FlashInd] is null and D.[FlashInd] is not null) or  (I.[FlashInd] is not null and D.[FlashInd] is null)) or  (I.[NationalIndicator]<> D.[NationalIndicator] or (I.[NationalIndicator] is null and D.[NationalIndicator] is not null) or  (I.[NationalIndicator] is not null and D.[NationalIndicator] is null)) or  (I.[CreateBy]<> D.[CreateBy] or (I.[CreateBy] is null and D.[CreateBy] is not null) or  (I.[CreateBy] is not null and D.[CreateBy] is null)) or  (I.[CreateDate]<> D.[CreateDate] or (I.[CreateDate] is null and D.[CreateDate] is not null) or  (I.[CreateDate] is not null and D.[CreateDate] is null)) or  (I.[ModifiedBy]<> D.[ModifiedBy] or (I.[ModifiedBy] is null and D.[ModifiedBy] is not null) or  (I.[ModifiedBy] is not null and D.[ModifiedBy] is null)) or  (I.[ModifyDate]<> D.[ModifyDate] or (I.[ModifyDate] is null and D.[ModifyDate] is not null) or  (I.[ModifyDate] is not null and D.[ModifyDate] is null)) or  (I.[EditInits]<> D.[EditInits] or (I.[EditInits] is null and D.[EditInits] is not null) or  (I.[EditInits] is not null and D.[EditInits] is null)) or  (I.[LastMappedDate]<> D.[LastMappedDate] or (I.[LastMappedDate] is null and D.[LastMappedDate] is not null) or  (I.[LastMappedDate] is not null and D.[LastMappedDate] is null)) or  (I.[LastMapperInits]<> D.[LastMapperInits] or (I.[LastMapperInits] is null and D.[LastMapperInits] is not null) or  (I.[LastMapperInits] is not null and D.[LastMapperInits] is null)) or  (I.[CouponIndicator]<> D.[CouponIndicator] or (I.[CouponIndicator] is null and D.[CouponIndicator] is not null) or  (I.[CouponIndicator] is not null and D.[CouponIndicator] is null)) or  (I.[CreativeSignature]<> D.[CreativeSignature] or (I.[CreativeSignature] is null and D.[CreativeSignature] is not null) or  (I.[CreativeSignature] is not null and D.[CreativeSignature] is null)) or  (I.[AuditBy]<> D.[AuditBy] or (I.[AuditBy] is null and D.[AuditBy] is not null) or  (I.[AuditBy] is not null and D.[AuditBy] is null)) or  (I.[AuditDate]<> D.[AuditDate] or (I.[AuditDate] is null and D.[AuditDate] is not null) or  (I.[AuditDate] is not null and D.[AuditDate] is null)) or  (I.[AdvertiserNameSuggestion]<> D.[AdvertiserNameSuggestion] or (I.[AdvertiserNameSuggestion] is null and D.[AdvertiserNameSuggestion] is not null) or  (I.[AdvertiserNameSuggestion] is not null and D.[AdvertiserNameSuggestion] is null)) or  (I.[FormatCode]<> D.[FormatCode] or (I.[FormatCode] is null and D.[FormatCode] is not null) or  (I.[FormatCode] is not null and D.[FormatCode] is null)))