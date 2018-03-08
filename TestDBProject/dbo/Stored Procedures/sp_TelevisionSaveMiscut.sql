-- =============================================
-- Author:		Ashanie Cole
-- Create date:	November 2016
-- Description:	Mark PR code as Miscut
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionSaveMiscut]
	@PRCode VARCHAR(50),
	@QCdBy INT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @AdID INT
    DECLARE @PatternMasterID INT
    DECLARE @Mediastreamid INT
    DECLARE @OccurrenceID INT
    DECLARE @CreativeMasterID AS INT=0 
    DECLARE @CreativeStagingID AS INT=0 
    DECLARE @NumberRecords AS INT=0 
    DECLARE @RowCount AS INT=0
    DECLARE @IndexedBy INT 
    DECLARE @IndexedOn DATETIME 

    BEGIN TRY

	   BEGIN TRANSACTION;

	   --CREATE TABLE TVMiscut(
		  --TVMiscutID INT IDENTITY(1,1),
		  --PRCode VARCHAR(50) NOT NULL,
		  --IndexedBy INT NULL,
		  --IndexedOn DATETIME NULL,
		  --QCdBy INT NOT NULL,
		  --QCdOn DATETIME NOT NULL)
	   
	   Select @Mediastreamid=ConfigurationID  from   [dbo].[Configuration] Where Value='TV'
		            
	   CREATE TABLE #tempoccurencesforcreativesignature 
	   ( 
		  rowid        INT IDENTITY(1, 1), 
		  occurrenceid INT 
	   ) 

	   INSERT INTO #tempoccurencesforcreativesignature 
		  SELECT  OccurrenceDetailTVID FROM    [dbo].[OccurrenceDetailTV] inner join  [Pattern] on [Pattern].[CreativeSignature]=[OccurrenceDetailTV].[PRCODE] 
			 Where [OccurrenceDetailTV].[PRCODE]= @PRCode 

	   -- Retrieve Primary occurrence ID     
	   SELECT @OccurrenceID = Min(occurrenceid) FROM #tempoccurencesforcreativesignature

	   IF EXISTS(SELECT [CreativeSignature] FROM [dbo].[PatternStaging] WHERE  [CreativeSignature] = @PRCode)
	   BEGIN

		  INSERT INTO [Creative] 
				    (
					   [AdId], 
					   [SourceOccurrenceId], 
					   CheckInOccrncs
				    ) 
		  SELECT null,@OccurrenceID,1 

		  PRINT( 'creativemster - inserted' ) 

		  SELECT @CreativeMasterID = Scope_identity() 

		  PRINT( 'creativemasterid-' + Cast(@CreativeMasterID AS VARCHAR) ) 

		  SELECT @CreativeStagingID = [CreativeStgID] 
			 from   [PatternStaging] 		    
				Where [CreativeSignature] = @PRCode

		  INSERT INTO creativedetailTV 
				(
				    creativemasterid, 
				    creativeassetname, 
				    creativerepository, 
				    legacycreativeassetname, 
				    creativefiletype
				) 
		  SELECT @CreativeMasterID, 
			 MediaFileName, 
			 MediaFilepath, 
			 null, 
			 MediaFormat 
		  FROM   [CreativeDetailStagingTV] 
		  WHERE  [CreativeStgMasterID]= @CreativeStagingID and [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed

		  PRINT ( 'creativedetailtv - inserted' ) 

		  INSERT INTO [Pattern] 
				([CreativeID], 
				[AdID], 
				MediaStream, 
				[Exception],  
				[Query], 
				Status,
				CreateBy,  
				CreateDate,
				CreativeSignature) 
		  SELECT @CreativeMasterID, 
			 null, 
			 @Mediastreamid, 
			 [Exception], 
			 [Query],  
			 'Miscut', -- Status Value HardCoded
			 @QCdBy,                        
			 Getdate(),
			 @PRCode
		  FROM  [dbo].[PatternStaging]
		  WHERE  [CreativeSignature] = @PRCode

		  PRINT( 'patternmaster - inserted' ) 

		  SET @PatternMasterID=Scope_identity(); 

		  PRINT( 'patternmasterid-' 
				+ Cast(@PatternMasterID AS VARCHAR) ) 

		  PRINT( 'creative signature-' + @PRCode ) 

		  --SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
		  --SET @RowCount = 1 
		  --WHILE @RowCount <= @NumberRecords 
		  --BEGIN			
			 ----- Get OccurrenceID's from Temporary table  
			 --SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount 
			 --PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) )  	
		  		    
			 --UPDATE [dbo].[OccurrenceDetailTV] SET    [PatternID] = @PatternMasterID WHERE  [OccurrenceDetailTVID] = @OccurrenceID 

			 --SET @RowCount=@rowcount + 1 
			 --PRINT ( '-----------' ) 
		  --END 


		  UPDATE a SET a.[PatternID] = @PatternMasterID 
		  FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]

		  --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 
		  DELETE FROM [dbo].[PatternStaging] WHERE [PatternStagingID] IN (SELECT [PatternStagingID]   FROM   [dbo].[PatternStaging]  WHERE  [CreativeStgID] = @CreativeStagingID ) 						
		  DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeDetailStagingTV] WHERE [CreativeStgMasterID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

	   END

	   SELECT @IndexedBy = CreateBy,@IndexedOn = CreateDate  FROM Pattern WHERE CreativeSignature = @PRCode

	   UPDATE Pattern SET [Status] = 'Miscut' WHERE [CreativeSignature] = @PRCode
	   UPDATE OccurrenceDetailTV SET AdID=NULL WHERE PRCODE = @PRCode

	   INSERT INTO TVMiscut(PRCode, IndexedBy,IndexedOn, QCdBy, QCdOn)
	   VALUES(@PRCode, @IndexedBy,@IndexedOn, @QCdBy, GETDATE())
	   
	   COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
	   IF (@@TRANCOUNT > 0)
	   BEGIN
		  ROLLBACK TRANSACTION;
	   END
	   DECLARE @Error   INT = ERROR_NUMBER(),@Message VARCHAR(4000) = ERROR_MESSAGE(),@LineNo  INT = ERROR_LINE() 
	   RAISERROR ('[dbo].[sp_TelevisionSaveMiscut]: %d: %s',16,1,@Error,@Message,@LineNo);   
    END CATCH

END