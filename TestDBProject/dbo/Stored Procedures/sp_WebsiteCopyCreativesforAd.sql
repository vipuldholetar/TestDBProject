  -- =========================================================================================

-- Author			: Arun Nair

-- Create date		: 11/13/2015

-- Description		: Create New Creative/Updating Creatives  for Websites

-- Execution Process: sp_WebsiteCopyCreativesforAd 10469,'' 

-- Updated By		:

-- ==============================================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteCopyCreativesforAd]

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

				Select @PatternMasterId=[PatternID] from [OccurrenceDetailWEB] where [OccurrenceDetailWEBID]=@PrimaryOccurrenceID

				select @OldCreativeMasterID=[CreativeID] from [Pattern] where [PatternID]=@PatternMasterId

				if exists(select 1 from [Creative] where PK_Id=@OldCreativeMasterID)

				begin

				set @IsCreativeExists=1

				end

				else

				begin

				set @IsCreativeExists=0

				end



				Print N'Is Creative Exists'

				Print(@IsCreativeExists)



				Print(@OldCreativeMasterID)

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

				SELECT @MediaStream = value FROM   [Configuration]  WHERE  systemname = 'All'  AND componentname = 'Media Stream'  AND value = 'WEB'				

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

				FROM [Creative] where PK_Id=@OldCreativeMasterID

				select @NewCreativeMasterID=scope_identity();



				--Updating PrimaryCreativeIndicator in CreativeMaster   

				Update [Creative] Set PrimaryIndicator=0 where PK_Id=@OldCreativeMasterID



				--Updating FK_CreativeId in PATTERNMASTER 

				update [Pattern] set [CreativeID]=@NewCreativeMasterID where [PatternID]=@PatternMasterId

				--Print(@OldCreativeMasterID)

				Print N'New CreativeMasterID'

				Print(@NewCreativeMasterID)

			

				insert into @oldCreativeDetailrecords(oldcreativedetailid,oldassetname,oldrepository,creativeFileType,newcreativemasterid) 

				select [CreativeDetailWebID],creativeassetname,creativerepository,creativeFileType,@NewCreativeMasterID from CreativeDetailWeb

				where CreativeMasterID=@OldCreativeMasterID



								Print N'AFter Insert'

								Print(@OldCreativeMasterID)

				set @CreativeRepository=(select Distinct CreativeRepository from CreativeDetailweb where CreativeMasterID=@OldCreativeMasterID and CreativeRepository is not null )



				Set @CreativeFileRepository=(Replace(@CreativeRepository,@OldCreativeMasterID,@NewCreativeMasterID))



				select @NumRecords= count(*) from @oldCreativeDetailrecords



				Print(@NumRecords)



				-- Updating Old Creative Master Records into New Creative Master Records in CreativeDetailweb

				DECLARE @NumCounter INT=1					

				WHILE  @NumCounter<=@NumRecords

				BEGIN 							

					select @OldCreativeDetailID= oldcreativedetailid from @oldCreativeDetailrecords where rownum=@NumCounter

					insert into CreativeDetailWeb(CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,Deleted,PageNumber,[PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],[PageEndDT],PageName,PubPageNumber)

					select @NewCreativeMasterID,'',@CreativeFileRepository,LegacyAssetName,CreativeFileType,0,@NumCounter,[PageTypeID],PixelHeight,PixelWidth,[SizeID],FormName,[PageStartDT],[PageEndDT],PageName,PubPageNumber	from CreativeDetailweb 

					where [CreativeDetailWebID]=@OldCreativeDetailID	

							 		

					Select @NewCreativedetailId=scope_identity();							

					Update CreativeDetailWeb set CreativeAssetName=@NewCreativedetailId+'.'+CreativeFileType Where [CreativeDetailWebID]=@NewCreativedetailId 

					and CreativeMasterID=@NewCreativeMasterID



					update @oldCreativeDetailrecords set newassetname=@NewCreativedetailId+'.'+CreativeFileType,newrepository=@CreativeFileRepository where

					rownum=@NumCounter



					SET @NumCounter = @NumCounter+1

				END 

				--Print 'Inserted'

				--Print(@NumCounter)



				-- Updating New Creative Master Records in CreativeDetailweb

				Print(@FileType)

					IF (@FileType<>'')

					Begin

					--Print(@FileType)

							sELECT @CreativeFileRepository=@MediaStream+'\'+Cast(@NewCreativeMasterID AS VARCHAR)+'\Original\'

							--Print(@CreativeFileRepository)

							Set @MaxCount=(Select Max(Pagenumber) from CreativeDetailWeb where CreativeMasterID=@OldCreativeMasterID)



							insert into CreativeDetailWeb (CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,Deleted,PageNumber)



							select @NewCreativeMasterID,'',@CreativeFileRepository,Null,@FileType,0,@MaxCount+1				

							Select @NewCreativedetailId=scope_identity();

							--Updating 	CreativeDetailweb						

							Update CreativeDetailWeb set CreativeAssetName=@NewCreativedetailId+'.'+@FileType,creativerepository=@CreativeFileRepository Where [CreativeDetailWebID]=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	

							insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID)							

							--Print 'Inserted'

					End

					select * from @oldCreativeDetailrecords

		End

Else

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

						print @NewCreativeMasterID



						--Updating PATTERNMASTER

						update [Pattern] set [CreativeID]=@NewCreativeMasterID where [PatternID]=@PatternMasterId



						-- Insert new creativedetailCIR record

						INSERT INTO [dbo].[CreativeDetailWeb]

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



						sELECT @CreativeFileRepository=@MediaStream+'\'+Cast(@NewCreativeMasterID AS VARCHAR)+'\Original\'

						--Updating 	CreativeDetailweb	With Creative Files data

						UPDATE [dbo].[CreativeDetailWeb] SET creativeassetname=Cast(@NewCreativedetailId AS VARCHAR)+'.'+@FileType, 

						creativerepository=@CreativeFileRepository WHERE [CreativeDetailWebID]=@NewCreativedetailId

						Select @CreativeFileRepository=creativerepository from [dbo].[CreativeDetailWeb] WHERE [CreativeDetailWebID]=@NewCreativedetailId

						insert into @oldCreativeDetailrecords values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@FileType,@NewCreativeMasterID)

						select * from @oldCreativeDetailrecords

 End

		

	COMMIT TRANSACTION

	END TRY

	 BEGIN CATCH 



        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT

        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

		RAISERROR ('sp_WebsiteCopyCreativesforAd: %d: %s',16,1,@error,@message,@lineNo);

		ROLLBACK TRANSACTION

    END CATCH 

    

END
