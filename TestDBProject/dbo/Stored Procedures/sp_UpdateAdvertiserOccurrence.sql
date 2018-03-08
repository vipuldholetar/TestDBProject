CREATE PROCEDURE [dbo].[sp_UpdateAdvertiserOccurrence] (

	@OccurrenceListID Nvarchar(max),
	@AdvertiserEmailId int,
	@MediaType as Nvarchar(12),
	@UserId as int,
	@AdvertiserID int out
)
AS
		  Declare @OccurrenceID as integer = 0
		  DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @MediaStream AS INT=0 
		  DECLARE @Counter AS INTEGER
		  DECLARE @RecordsCount AS INTEGER
begin
SET nocount ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

DECLARE @TableOccurrence
				TABLE (			
						ID INT IDENTITY(1,1),			
						OccurrenceIDTemp NVARCHAR(MAX) NOT NULL
					  )	

			    INSERT INTO @TableOccurrence(OccurrenceIDTemp)
				SELECT ITEM From SplitString(''+ @AdvertiserEmailId +'',',')
							
				
				SELECT @RecordsCount =Count(OccurrenceIDTemp) FROM @TableOccurrence		

				Update AdvertiserEmail set AdvertiserID=@AdvertiserID,ModifiedDT=getdate(),ModifiedByID=@UserId where AdvertiserEmailID=@AdvertiserEmailId

				SET @Counter=1
				WHILE @Counter<=@RecordsCount
					BEGIN 
						SELECT @OccurrenceID=OccurrenceIDTemp FROM @TableOccurrence WHERE ID =@Counter

						if @MediaType ='EM'
						BEGIN
					
						update OccurrenceDetailEm set Advertiserid=@AdvertiserID where OccurrenceDetailEMID = @OccurrenceID and AdvertiserEmailID =@AdvertiserEmailId
						END
					 SET @Counter=@Counter+1
				END
		   COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_UpdateAdvertiserOccurrence]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
END