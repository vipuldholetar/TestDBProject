-- =================================================================================================
-- Author				: Karunakar
-- Create date			: 06/02/2015
-- Description			: This stored procedure is used to create a creative
-- Execution Process	: sp_CopyCreativeAdForCircular 19616,'jpg' 
-- Updated By			: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--						: Karunakar on 7th Sep 2015
--						: Arun Nair on 12/14/2015 - Changes for ImageEditor Load All CreativeData
--					: L.E on 3/8/17 - Changes for ImageEditor Load All CreativeData and file type 

-- ==================================================================================================
CREATE PROCEDURE [dbo].[sp_CopyCreativeAdForCircular]
	(
	@AdId As Int,
	@FileType As Varchar(max),
	@OccurrenceId AS BigInt
	)
AS
	  IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	SET NOCOUNT ON;
			DECLARE @PrimaryOccurrenceID  Bigint
			DECLARE @PatternMasterId Int
			DECLARE @OldCreativeMasterID int
			DECLARE @NewCreativeMasterID Int 
			DECLARE @OldCreativedetailId Int
			DECLARE @NewCreativedetailId Varchar(max)
			DECLARE @CreativeRepository Varchar(max)
			DECLARE @CreativeFileRepository Varchar(max)
			DECLARE @deleted  INT
			DECLARE @PageNumber  INT
			DECLARE @PageTypeId NVARCHAR(MAX)
			DECLARE @PixelHeight INT
			DECLARE @PixelWidth INT
			DECLARE @FK_SizeID INT
			DECLARE @FormName NVARCHAR(MAX)
			DECLARE @PageStartDt NVARCHAR(MAX)
			DECLARE @PageEndDt NVARCHAR(MAX)
			DECLARE @PageName NVARCHAR(MAX)
			DECLARE @PubPageNumber INT
			Declare @MaxCount int
			Declare @NumRecords Int
			BEGIN TRY
			BEGIN TRANSACTION
			--Creating @oldCreativeDetailrecords temp variable table
			Declare  @oldCreativeDetailrecords Table 
			(
			rownum int identity(1,1),
			oldcreativedetailid int,
			oldassetname nvarchar(max),
			newassetname nvarchar(max),
			oldrepository nvarchar(max),
			newrepository nvarchar(max),
			creativeFileType nvarchar(max),
			newcreativemasterid int,
			deleted  INT,
			PageNumber  INT,
			PageTypeId NVARCHAR(MAX),
			PixelHeight INT,
			PixelWidth INT,
			FK_SizeID INT,
			FormName NVARCHAR(MAX),
			PageStartDt NVARCHAR(MAX),
			PageEndDt NVARCHAR(MAX),
			PageName NVARCHAR(MAX),
			PubPageNumber INT
			)
			If(@OccurrenceId<>0)
			  BEGIN
				SET @PrimaryOccurrenceID=@OccurrenceId 
			  END 
			ELSE
			  BEGIN
				SELECT @PrimaryOccurrenceID=[PrimaryOccurrenceID] from Ad where Ad.[AdID]=@AdId
			  END 
			SELECT @PatternMasterId=[PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@PrimaryOccurrenceID
			SELECT @OldCreativeMasterID=[CreativeID] from [Pattern] where [Pattern].[PatternID]=@PatternMasterId
			--Inserting data into creativemaster
			INSERT into [Creative] 
			SELECT [AdId]
			,[SourceOccurrenceId]
			,[EnvelopId]
			,1
			,[PrimaryQuality]
			,[CreativeType]
			,[StatusID]
			,[PullPageCount]
			,[Weight]
			,[FormName]
			,[CheckInOccrncs]
			,[SPReviewStatusId]
			,[EntryInd]
			,[ParentVehicleId]
			,[FilterMatches]
			,[SourceMatchInd]
			,[TypeId]
			,[FlashInd]
			,[CouponInd]
			,[Priority]
			,[NationalInd]
			,[DistDate]
			,[CINI]
			,[ERIN]
			,[INIT]
			,[AssetThmbnlName]
			,[ThmbnlRep]
			,[LegacyThmbnlAssetName]
			,[ThmbnlFileType]
			, getdate()
			FROM [Creative] WHERE [Creative].PK_id=@OldCreativeMasterID
			SELECT @NewCreativeMasterID=scope_identity();
										
			--Updating PrimaryCreativeIndicator in CreativeMaster   
			Update [Creative] Set PrimaryIndicator=0 where [Creative].Pk_id=@OldCreativeMasterID
			--Updating FK_CreativeId in PATTERNMASTER 
			Update [Pattern] set [CreativeID]=@NewCreativeMasterID where [Pattern].[PatternID]=@PatternMasterId
			--Print(@OldCreativeMasterID)
			--Print(@NewCreativeMasterID)
			
			INSERT INTO @oldCreativeDetailrecords
			(
			oldcreativedetailid,
			oldassetname,
			oldrepository,
			creativeFileType,
			newcreativemasterid,
			deleted ,
			PageNumber,
			PageTypeId,
			PixelHeight,
			PixelWidth ,
			FK_SizeID,
			FormName,
			PageStartDt ,
			PageEndDt ,
			PageName,
			PubPageNumber 
			) 
			SELECT 
			CreativeDetailID,
			creativeassetname,
			creativerepository,
			creativeFileType,
			@NewCreativeMasterID ,
			deleted ,
			PageNumber,
			[PageTypeID],
			PixelHeight,
			PixelWidth ,
			[SizeID],
			FormName,
			[PageStartDT] ,
			[PageEndDT] ,
			PageName,
			PubPageNumber FROM CreativeDetailCIR WHERE CreativeMasterID=@OldCreativeMasterID
							
			SET @CreativeRepository=(SELECT DISTINCT CreativeRepository FROM CreativeDetailCIR WHERE CreativeMasterID=@OldCreativeMasterID)
			Set @CreativeFileRepository=(Replace(@CreativeRepository,@OldCreativeMasterID,@NewCreativeMasterID))
			select @NumRecords= count(*) from @oldCreativeDetailrecords
			--Print(@NumRecords)
			-- Updating Old Creative Master Records into New Creative Master Records in CreativeDetailCIR
			DECLARE @NumCounter INT=1
								
			WHILE  @NumCounter<=@NumRecords
			BEGIN 							
				SELECT @OldCreativeDetailID= oldcreativedetailid FROM @oldCreativeDetailrecords WHERE rownum=@NumCounter
				INSERT INTO CreativeDetailCIR(CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyCreativeAssetName,CreativeFileType,Deleted,PageNumber,
				[PageTypeID],	PixelHeight,PixelWidth ,[SizeID],FormName,[PageStartDT] ,[PageEndDT] ,	PageName,PubPageNumber)
				Select @NewCreativeMasterID,'',@CreativeFileRepository,'',CreativeFileType,0,@NumCounter,[PageTypeID],	PixelHeight,PixelWidth ,[SizeID],FormName,[PageStartDT] ,
				[PageEndDT] ,	PageName,PubPageNumber	FROM CreativeDetailCIR 	WHERE Creativedetailid=@OldCreativeDetailID	
												 		
				Select @NewCreativedetailId=scope_identity();		
									
				Update CreativeDetailCIR set CreativeAssetName=@NewCreativedetailId+'.'+CreativeFileType Where CreativeDetailID=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID
				Update @oldCreativeDetailrecords set newassetname=@NewCreativedetailId+'.'+CreativeFileType,newrepository=@CreativeFileRepository where	rownum=@NumCounter
				SET @NumCounter = @NumCounter+1
			END 
			--Print 'Inserted'
			--Print(@NumCounter)
			-- Updating New Creative Master Records in CreativeDetailCIR
			IF Exists (select top 1 * FROM [Configuration] where Componentname='Creative File Type' and ValueGroup='CIR' and value =@FileType) -- L.E. 3.8.17 - ADD NEW FILES VALID FOR MEDIA STREAM
			Begin
			print 'nofiltype'
				Set @MaxCount=(Select Max(Pagenumber) from CreativeDetailCIR where CreativeMasterID=@OldCreativeMasterID)
				INSERT INTO CreativeDetailCIR (CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyCreativeAssetName,CreativeFileType,Deleted,PageNumber,[PageTypeID],PixelHeight,PixelWidth ,[SizeID],FormName,	[PageStartDT] ,[PageEndDT] ,PageName,PubPageNumber)
				SELECT @NewCreativeMasterID,'',@CreativeFileRepository,'',@FileType,0,@MaxCount+1,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt,@PageEndDt,@PageName,@PubPageNumber				
				
				SELECT @NewCreativedetailId=scope_identity();	
										
				Update CreativeDetailCIR set CreativeAssetName=@NewCreativedetailId+'.'+@FileType Where CreativeDetailID=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
				insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID,@deleted,
				@PageNumber,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt ,@PageEndDt ,@PageName,@PubPageNumber)
			End			
			SELECT * from @oldCreativeDetailrecords
			--Print 'Inserted'
			COMMIT TRANSACTION
			END TRY
			BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('sp_CopyCreativeAdForCircular: %d: %s',16,1,@error,@message,@lineNo);
				ROLLBACK TRANSACTION
			END CATCH 
    
END