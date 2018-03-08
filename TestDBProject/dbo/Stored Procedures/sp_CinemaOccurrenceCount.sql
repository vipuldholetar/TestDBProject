-- =============================================
-- Author		: Imtiaz Khan
-- Create date	: 07/13/2015 
-- Description	: Procedure for Cinema Ingestion -- Inserting into tables OccurrenceDetailsCIN, PatternMasterStgCIN, CINPatterns
-- Updated By	: Imtiaz Khan on 07/16/2015 
-- Execute		:[sp_CinemaOccurrenceCount] 
--===================================================
CREATE PROCEDURE [dbo].[sp_CinemaOccurrenceCount]
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Customer VARCHAR(200)
		DECLARE @StartDate DATETIME
		DECLARE @EndDate DATETIME
		DECLARE @Rating VARCHAR(200)
		DECLARE @Length INT
		DECLARE @AdName VARCHAR(200)
		DECLARE @Result VARCHAR(MAX)
		DECLARE @Count INT
		DECLARE @DateCount DATETIME
		DECLARE @Worktype as int


			BEGIN TRANSACTION
			Select @Worktype = Value from [Configuration] where componentname='WorkType' and valuetitle='Ingestion'
			declare @tempTable table
			(
				RowId int identity(1,1),
				PK_Id int
			)
			insert into @tempTable(PK_Id) select [NCMRawDataID]  from  NCMRawData
			declare @TopCount int ,@Counter int
			set @TopCount=1
			select @Counter=count(RowId) from @tempTable
			while (@Counter>0)
			begin
				declare @id  int
				select @id = PK_Id from @tempTable where RowId=@TopCount
				select  @Customer = Customer, @StartDate = [StartDT], @EndDate = [EndDT], @Rating = Rating, @Length = [Length], @AdName = AdName 
				from NCMRawData where [NCMRawDataID]=@id
				
				
				SET @DateCount = @StartDate

					IF(@StartDate<>'' AND @EndDate<>'')
						BEGIN
							SET @Count = (DATEDIFF(day, @StartDate, @EndDate))+1
						END

				WHILE(@count<>0)
					BEGIN		
							Insert Into [OccurrenceDetailCIN]([PatternID], [AdID], [MarketID], WorkType, [CreativeID], [AirDT], Customer,
													Rating, [Length], [CreatedDT], [ModifiedDT])
								VALUES (Null, Null, Null, @Worktype, [dbo].fn_CINCreativeName(@AdName), @DateCount, @Customer, [dbo].fn_CINRatingString(@Rating),
								@Length, GetDate(), Null)

						SET @DateCount = @DateCount+1
						SET @count = @count-1
					END
				select @Counter=@Counter-1
				select @TopCount=@TopCount+1
			end
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_CinemaOccurrenceCount]: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
	END CATCH

END
