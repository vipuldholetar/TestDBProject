

 
 -- =========================================================================================
-- Author			: ARUN NAIR
-- Create date		: 06/02/2015
-- Description		: This stored procedure is used to create a creative for Publication
-- Execution Process: sp_CopyCreativeAdForCircular 7228,'jpg' 
-- Updated By		: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--					: Karunakar on 7th Sep 2015
--					: L.E on 3/8/17 - Changes for ImageEditor Load All CreativeData and file type 
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_CopyCreativeAdForPublication]
	(
	@AdId As Int,
	@FileType As Varchar(max)
	)
AS
IF 1 = 0
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	SET NOCOUNT ON;
	Declare @PrimaryOccurrenceID  BIGINT
	Declare @PatternMasterId INT
	DECLARE @OldCreativeMasterID INT
	Declare @NewCreativeMasterID INT 
	Declare @OldCreativedetailId INT
	Declare @NewCreativedetailId VARCHAR(max)
	Declare @CreativeRepository VARCHAR(max)
	Declare @CreativeFileRepository VARCHAR(max)
	Declare @MaxCount INT
	Declare @NumRecords INT
	Declare @IsCreativeExists As Int
	Declare @MediaStream As VARCHAR(max)
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
	

	BEGIN TRY
	BEGIN TRANSACTION
				--Checking Creative Master Record Exists or not		
				if exists(select 1 from [Creative] where [AdId]=@adid)
				begin
				set @IsCreativeExists=1
				end
				else
				begin
				set @IsCreativeExists=0
				end
				----Creating @oldCreativeDetailrecords temp variable table
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
				SELECT @MediaStream = value FROM   [Configuration]  WHERE  systemname = 'All'  AND componentname = 'Media Stream'  AND value = 'PUB'

				Select @PrimaryOccurrenceID=[PrimaryOccurrenceID] from Ad where [AdID]=@AdId
				Select @PatternMasterId=[PatternID] from [OccurrenceDetailPUB] where [OccurrenceDetailPUBID]=@PrimaryOccurrenceID
				select @OldCreativeMasterID=[CreativeID] from [Pattern] where [PatternID]=@PatternMasterId
					
				if(@IsCreativeExists=1)
				Begin
				--Inserting data into creativemaster
				insert into [Creative] SELECT [AdId]
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
					,getDate()
				FROM [Creative] where PK_Id=@OldCreativeMasterID
				select @NewCreativeMasterID=scope_identity();

				--Updating PrimaryCreativeIndicator in CreativeMaster   
				Update [Creative] Set PrimaryIndicator=0 where PK_Id=@OldCreativeMasterID

				--Updating FK_CreativeId in PATTERNMASTER 
				update [Pattern] set [CreativeID]=@NewCreativeMasterID where [PatternID]=@PatternMasterId
				--Print(@OldCreativeMasterID)
				--Print(@NewCreativeMasterID)
			
				insert into @oldCreativeDetailrecords
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
				select 
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
			[FK_SizeID],
			FormName,
			[PageStartDT] ,
			[PageEndDT] ,
			PageName,
			PubPageNumber
			from CreativeDetailPUB 	where CreativeMasterID=@OldCreativeMasterID

							
				set @CreativeRepository=(select Distinct CreativeRepository from CreativeDetailPUB where CreativeMasterID=@OldCreativeMasterID)

				Set @CreativeFileRepository=(Replace(@CreativeRepository,@OldCreativeMasterID,@NewCreativeMasterID))

				select @NumRecords= count(*) from @oldCreativeDetailrecords

				--Print(@NumRecords)

				-- Updating Old Creative Master Records into New Creative Master Records in CreativeDetailPUB
				DECLARE @NumCounter INT=1					
				WHILE  @NumCounter<=@NumRecords
				BEGIN 							
					select @OldCreativeDetailID= oldcreativedetailid from @oldCreativeDetailrecords where rownum=@NumCounter
					insert into CreativeDetailPUB(CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyCreativeAssetName,CreativeFileType,Deleted,PageNumber,
					[PageTypeID],	PixelHeight,PixelWidth ,[FK_SizeID],FormName,[PageStartDT] ,[PageEndDT] ,	PageName,PubPageNumber)
					select @NewCreativeMasterID,'',@CreativeFileRepository,'',CreativeFileType,0,@NumCounter	,[PageTypeID],	PixelHeight,PixelWidth ,[FK_SizeID],FormName,[PageStartDT] ,
				[PageEndDT] ,	PageName,PubPageNumber	FROM CreativeDetailPUB 	where Creativedetailid=@OldCreativeDetailID	
							 		
					Select @NewCreativedetailId=scope_identity();							
					Update CreativeDetailPUB set CreativeAssetName=@NewCreativedetailId+'.'+CreativeFileType Where CreativeDetailID=@NewCreativedetailId 
					and CreativeMasterID=@NewCreativeMasterID

					update @oldCreativeDetailrecords set newassetname=@NewCreativedetailId+'.'+CreativeFileType,newrepository=@CreativeFileRepository where
					rownum=@NumCounter

					SET @NumCounter = @NumCounter+1
				END 
				--Print 'Inserted'
				--Print(@NumCounter)

				-- Updating New Creative Master Records in CreativeDetailPUB

				--IF (@FileType<>'')
				IF Exists (select top 1 * FROM [Configuration] where Componentname='Creative File Type' and ValueGroup='PUB' and value =@FileType) -- L.E. 3.8.17 - ADD NEW FILES VALID FOR MEDIA STREAM
				Begin
						Set @MaxCount=(Select Max(Pagenumber) from CreativeDetailPUB where CreativeMasterID=@OldCreativeMasterID)
						insert into CreativeDetailPUB (CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyCreativeAssetName,CreativeFileType,Deleted,PageNumber,[PageTypeID],PixelHeight,PixelWidth ,[FK_SizeID],FormName,	[PageStartDT] ,[PageEndDT] ,PageName,PubPageNumber)
						select @NewCreativeMasterID,'',@CreativeFileRepository,'',@FileType,0,@MaxCount+1	,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt,@PageEndDt,@PageName,@PubPageNumber				
						Select @NewCreativedetailId=scope_identity();
						--Updating 	CreativeDetailPUB						
						Update CreativeDetailPUB set CreativeAssetName=@NewCreativedetailId+'.'+@FileType Where CreativeDetailID=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID,@deleted,
				@PageNumber,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt ,@PageEndDt ,@PageName,@PubPageNumber)
						End			
						select * from @oldCreativeDetailrecords
						--Print 'Inserted'
				End
				Else   --  If No Creative Master Found
				Begin
						INSERT INTO [Creative] 
						( 
						[AdId],
						[SourceOccurrenceId], 
						PrimaryIndicator, 
						CreativeType 
						) 
						VALUES 
						( 
						@adid,
						@PrimaryOccurrenceID, 
						1, 
						@FileType 
						) 
						SET @NewCreativeMasterID=Scope_identity(); 
						--print @NewCreativeMasterID

						--Updating PATTERNMASTER
						update [Pattern] set [CreativeID]=@NewCreativeMasterID where [PatternID]=@PatternMasterId

						-- Insert new creativedetailCIR record
						INSERT INTO [dbo].[CreativeDetailPUB]
						( creativemasterid, creativeassetname, creativerepository, creativefiletype, pagenumber, deleted,[PageTypeID],PixelHeight,PixelWidth ,[FK_SizeID],FormName,	[PageStartDT] ,[PageEndDT] ,PageName,PubPageNumber) 
						VALUES 
						( 
						@NewCreativeMasterID, 
						Null, 
						null, 
						@FileType, 
						1, 
						0 
						,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt,@PageEndDt,@PageName,@PubPageNumber
						) 
						SET @NewCreativedetailId=Scope_identity(); 
						--Updating 	CreativeDetailPUB	With Creative Files data
						UPDATE [dbo].[CreativeDetailPUB] SET creativeassetname=Cast(@NewCreativedetailId AS VARCHAR)+'.'+@FileType, 
						creativerepository=@MediaStream+'\'+Cast(@NewCreativeMasterID AS VARCHAR)+'\Original\' WHERE creativedetailid=@NewCreativedetailId

						Select @CreativeFileRepository=creativerepository from [dbo].[CreativeDetailPUB] WHERE creativedetailid=@NewCreativedetailId
						insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID,@deleted,
				@PageNumber,@PageTypeId,@PixelHeight,@PixelWidth ,@FK_SizeID,@FormName,@PageStartDt ,@PageEndDt ,@PageName,@PubPageNumber)
						select * from @oldCreativeDetailrecords


			    End
						

	COMMIT TRANSACTION
	END TRY
	

	 BEGIN CATCH 

        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_CopyCreativeAdForPublication: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 
    
END