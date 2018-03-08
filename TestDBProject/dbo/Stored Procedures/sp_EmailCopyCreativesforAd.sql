  -- =========================================================================================
-- Author			: KARUNAKAR
-- Create date		: 5th Nov 2015
-- Description		: This stored procedure is used to create a new  creative/Updating Creatives  for Email
-- Execution Process: sp_EmailCopyCreativesforAd 7228,'jpg' 
-- Updated By		:
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailCopyCreativesforAd]
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
	
	BEGIN TRY
	BEGIN TRANSACTION
				--Checking Creative Master Record Exists or not		

				Select @PrimaryOccurrenceID=[PrimaryOccurrenceID] from Ad where [AdID]=@AdId
				Select @PatternMasterId=[PatternID] from [OccurrenceDetailEM] where [OccurrenceDetailEMID]=@PrimaryOccurrenceID
				select @OldCreativeMasterID=[CreativeID] from [Pattern] where [PatternID]=@PatternMasterId
				if exists(select 1 from [Creative] where PK_Id=@OldCreativeMasterID)
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
				newcreativemasterid int			
				)
				SELECT @MediaStream = value FROM   [Configuration]  WHERE  systemname = 'All'  AND componentname = 'Media Stream'  AND value = 'EM'				
				if(@IsCreativeExists=1)
				Begin
				--Inserting data into creativemaster
				insert into [Creative] 
					([AdId],[SourceOccurrenceId],[EnvelopId],PrimaryIndicator,[PrimaryQuality],[CreativeType],[StatusID]
				,[PullPageCount],[Weight],[FormName],[CheckInOccrncs],[SPReviewStatusId],[EntryInd],[ParentVehicleId]
				,[FilterMatches],[SourceMatchInd],[TypeId],[FlashInd],[CouponInd],[Priority],[NationalInd],[DistDate]
				,[CINI],[ERIN],[INIT],[AssetThmbnlName],[ThmbnlRep],[LegacyThmbnlAssetName],[ThmbnlFileType])				
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
				FROM [Creative] where PK_Id=@OldCreativeMasterID
				select @NewCreativeMasterID=scope_identity();

				--Updating PrimaryCreativeIndicator in CreativeMaster   
				Update [Creative] Set PrimaryIndicator=0 where PK_Id=@OldCreativeMasterID

				--Updating FK_CreativeId in PATTERNMASTER 
				update [Pattern] set [CreativeID]=@NewCreativeMasterID where [PatternID]=@PatternMasterId
				--Print(@OldCreativeMasterID)
				--Print(@NewCreativeMasterID)
		
				insert into @oldCreativeDetailrecords(oldcreativedetailid,oldassetname,oldrepository,creativeFileType,newcreativemasterid) 
				select [CreativeDetailsEMID],creativeassetname,creativerepository,creativeFileType,@NewCreativeMasterID from CreativeDetailEM
				where CreativeMasterID=@OldCreativeMasterID and deleted=0

							
				set @CreativeRepository=(select top 1 CreativeRepository from CreativeDetailEM where CreativeMasterID=@OldCreativeMasterID) --

				Set @CreativeFileRepository=(Replace(@CreativeRepository,@OldCreativeMasterID,@NewCreativeMasterID))

				select @NumRecords= count(*) from @oldCreativeDetailrecords

				--Print(@NumRecords)
				print 'passed creative insert'
				-- Updating Old Creative Master Records into New Creative Master Records in CreativeDetailEM
				DECLARE @NumCounter INT=1					
				WHILE  @NumCounter<=@NumRecords
				BEGIN 							
					select @OldCreativeDetailID= oldcreativedetailid from @oldCreativeDetailrecords where rownum=@NumCounter
					insert into CreativeDetailEM(CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,Deleted,PageNumber,PageTypeId,PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],[PageEndDT],PageName,EmailPageNumber)
					select @NewCreativeMasterID,'',@CreativeFileRepository,LegacyAssetName,CreativeFileType,0,@NumCounter,PageTypeId,PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],[PageEndDT],PageName,EmailPageNumber	from CreativeDetailEM 
					where [CreativeDetailsEMID]=@OldCreativeDetailID	
							 		
					Select @NewCreativedetailId=scope_identity();							
					Update CreativeDetailEM set CreativeAssetName=@NewCreativedetailId+'.'+CreativeFileType Where [CreativeDetailsEMID]=@NewCreativedetailId 
					and CreativeMasterID=@NewCreativeMasterID

					update @oldCreativeDetailrecords set newassetname=@NewCreativedetailId+'.'+CreativeFileType,newrepository=@CreativeFileRepository where
					rownum=@NumCounter

					SET @NumCounter = @NumCounter+1
				END 
				--Print 'Inserted'
				--Print(@NumCounter)

				-- Updating New Creative Master Records in CreativeDetailEM

				--IF (@FileType<>'')
				IF Exists (select top 1 * FROM [Configuration] where Componentname='Creative File Type' and ValueGroup='EM' and value =@FileType) -- L.E. 3.8.17 - ADD NEW FILES VALID FOR MEDIA STREAM
				Begin
						Set @MaxCount=(Select Max(Pagenumber) from CreativeDetailEM where CreativeMasterID=@OldCreativeMasterID and deleted=0)
						insert into CreativeDetailEM (CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,Deleted,PageNumber, pagetypeid)
						select @NewCreativeMasterID,'',@CreativeFileRepository,Null,@FileType,0,@MaxCount+1	, 'B'			
						Select @NewCreativedetailId=scope_identity();
						--Updating 	CreativeDetailEM						
						Update CreativeDetailEM set CreativeAssetName=@NewCreativedetailId+'.'+@FileType Where [CreativeDetailsEMID]=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID)
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
						INSERT INTO [dbo].[CreativeDetailEM]
						( creativemasterid, creativeassetname, creativerepository, creativefiletype, pagenumber, deleted ) 
						VALUES 
						( 
						@NewCreativeMasterID, 
						Null, 
						null, 
						@FileType, 
						1, 
						0 
						) 
						SET @NewCreativedetailId=Scope_identity(); 
						--Updating 	CreativeDetailEM	With Creative Files data
						UPDATE [dbo].[CreativeDetailEM] SET creativeassetname=Cast(@NewCreativedetailId AS VARCHAR)+'.'+@FileType, 
						creativerepository=@MediaStream+'\'+Cast(@NewCreativeMasterID AS VARCHAR)+'\Original\' WHERE [CreativeDetailsEMID]=@NewCreativedetailId

						Select @CreativeFileRepository=creativerepository from [dbo].[CreativeDetailEM] WHERE [CreativeDetailsEMID]=@NewCreativedetailId
						insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID)
						select * from @oldCreativeDetailrecords
			    End
						

	COMMIT TRANSACTION
	END TRY
	

	 BEGIN CATCH 

        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_EmailCopyCreativesforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 
    
END