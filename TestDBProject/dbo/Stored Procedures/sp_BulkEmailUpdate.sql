CREATE PROCEDURE [dbo].[sp_BulkEmailUpdate] 
(
@bulkEmailUpdate as XML,
@UserId INT
)
AS
BEGIN
	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 

				CREATE TABLE #tempBulkUpdate
								(
									id int identity(1,1),
									OccurrenceId int,
									EventId int NULL,
									ThemeId int NULL,
									DistributionDate DATETIME NULL,
									SaleStartDate DATETIME NULL,
									SaleEndDate DATETIME NULL,
									PromotionalInd BIT NULL
								)
				
				INSERT INTO  #tempBulkUpdate
				SELECT bulkUpdate.value('(OccurrenceID)[1]', 'int')		AS OccurrenceId,
			     	   bulkUpdate.value('(EventID)[1]', 'int')						AS EventId,
				       bulkUpdate.value('(ThemeID)[1]', 'int')						AS ThemeId,
								Convert(varchar(10),bulkUpdate.value('(DistributionDT)[1]', 'nvarchar(max)'),100)
													AS DistributionDate,
								Convert(varchar(10),bulkUpdate.value('(SalesStartDT)[1]', 'nvarchar(max)'),100)
													AS SaleStartDate,
								Convert(varchar(10),bulkUpdate.value('(SalesEndDT)[1]', 'nvarchar(max)'),100)
													AS SaleEndDate,
								bulkUpdate.value('(PromotionalInd)[1]','bit') as PromotionalInd
								FROM   @bulkEmailUpdate.nodes('DocumentElement/BulkUpdate') AS BulkUpdateValue(bulkUpdate)
			
				DECLARE @Count AS INT 
		        DECLARE @Index AS INT = 1
			    DECLARE @OccurrenceId  AS INT
				DECLARE @EventId AS INT
				DECLARE @ThemeId AS INT 
				DECLARE @DistributionDate AS DATETIME 
				DECLARE @SaleStartDate AS DATETIME 
				DECLARE @SaleEndDate AS DATETIME 
				DECLARE @PromotionalInd AS BIT 
				DECLARE @PatternMasterID AS INT

				SELECT @Count = Count(id) FROM #tempBulkUpdate
				
				WHILE @Index<=@Count
					BEGIN 

						SELECT      @OccurrenceId = OccurrenceId, 
									@EventId = EventId, 
									@ThemeId = ThemeId, 
									@DistributionDate = DistributionDate,
									@SaleStartDate = SaleStartDate,
									@SaleEndDate = SaleEndDate,
									@PromotionalInd = PromotionalInd
						FROM	    #tempBulkUpdate 
						WHERE	    id = @Index 

						
					 SELECT @PatternMasterID=[PatternID] FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceId
	
					 ---Updating OccurrenceDetailsEM Table----	
		 	
					 UPDATE [OccurrenceDetailEM] SET [OccurrenceDetailEM].[PatternID]=@PatternMasterID,
													[OccurrenceDetailEM].[DistributionDT]=@DistributionDate,
													[OccurrenceDetailEM].[ModifiedDT]= Getdate(),
													[OccurrenceDetailEM].[ModifiedByID]=@UserId,
													[OccurrenceDetailEM].PromotionalInd=@PromotionalInd 
													where [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceId

					---Updating Pattern Master Table----

					UPDATE [Pattern] SET [Pattern].[EventID]=@EventId,[Pattern].[ThemeID]=@ThemeId, 
											[Pattern].[SalesStartDT]=@SaleStartDate, [Pattern].[SalesEndDT]=@SaleEndDate
											WHERE [Pattern].[PatternID]=@PatternMasterID
					   SET @Index=@Index+1
				END 
				
		   COMMIT TRANSACTION
     END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_BulkEmailUpdate]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END