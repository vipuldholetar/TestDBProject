  -- =========================================================================================
-- Description		: This stored procedure is used to create a new  creative/Updating Creatives  for Email
-- Execution Process: sp_EmailAddCreativesforAd 7228,'jpg' 
-- Updated By		:
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailAddCreativesforAd]
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
	DECLARE @CreativeMasterID INT
	DECLARE @NewCreativeMasterID INT
	Declare @NewCreativedetailId VARCHAR(max)
	Declare @CreativeFileRepository VARCHAR(max)
	Declare @MaxCount INT
	Declare @IsCreativeExists As Int
	Declare @MediaStream As VARCHAR(max)
	
	BEGIN TRY
	BEGIN TRANSACTION
				--Checking Creative Master Record Exists or not		

				Select @PrimaryOccurrenceID=[PrimaryOccurrenceID] from Ad where [AdID]=@AdId
				Select @PatternMasterId=[PatternID] from [OccurrenceDetailEM] where [OccurrenceDetailEMID]=@PrimaryOccurrenceID
				select @CreativeMasterID=[CreativeID] from [Pattern] where [PatternID]=@PatternMasterId
				IF EXISTS(select 1 from [Creative] where PK_Id=@CreativeMasterID)
				BEGIN
				set @IsCreativeExists=1
				END 
				ELSE
				BEGIN
				set @IsCreativeExists=0
				END
				----Creating @oldCreativeDetailrecords temp variable table
				Declare  @oldCreativeDetailrecords Table 
				(
				rownum int identity(1,1),
				oldcreativedetailid int,
				oldassetname nvarchar(max),
				newassetname nvarchar(max),
				oldrepository nvarchar(max),
				newrepository nvarchar(max),
				newcreativemasterid int,
				creativeFileType nvarchar(max)
				)

				SELECT @MediaStream = value FROM   [Configuration]  WHERE  systemname = 'All'  AND componentname = 'Media Stream'  AND value = 'EM'				
				if(@IsCreativeExists=1)
				BEGIN
				
				insert into @oldCreativeDetailrecords(oldcreativedetailid,oldassetname,oldrepository,creativeFileType,newcreativemasterid) 
				select [CreativeDetailsEMID],creativeassetname,creativerepository,creativeFileType,@CreativeMasterID from CreativeDetailEM
				where CreativeMasterID=@CreativeMasterID and Deleted=0

				set @CreativeFileRepository=(select top 1 CreativeRepository from CreativeDetailEM where CreativeMasterID=@CreativeMasterID)  			

					IF Exists (select top 1 * FROM [Configuration] where Componentname='Creative File Type' and ValueGroup='EM' and value =@FileType) -- L.E. 3.8.17 - ADD NEW FILES VALID FOR MEDIA STREAM
					BEGIN
							Set @MaxCount=(Select Max(Pagenumber) from CreativeDetailEM where CreativeMasterID=@CreativeMasterID and deleted=0)

							insert into CreativeDetailEM (CreativeMasterID,CreativeAssetName,CreativeRepository,LegacyAssetName,CreativeFileType,Deleted,PageNumber, pagetypeid)
							select @CreativeMasterID,'',@CreativeFileRepository,Null,@FileType,0,@MaxCount+1, 'B'			
							Select @NewCreativedetailId=scope_identity();

							--Updating 	CreativeDetailEM						
							Update CreativeDetailEM set CreativeAssetName=@NewCreativedetailId+'.'+@FileType 
							Where [CreativeDetailsEMID]=@NewCreativedetailId and CreativeMasterID=@CreativeMasterID	

							insert into @oldCreativeDetailrecords 
							values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@CreativeMasterID,@FileType)
					END	
							
						select * from @oldCreativeDetailrecords

				END
				ELSE   --  If No Creative Master Found
				BEGIN
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

						Select @CreativeFileRepository=creativerepository 
						from [dbo].[CreativeDetailEM]
						WHERE [CreativeDetailsEMID]=@NewCreativedetailId

						insert into @oldCreativeDetailrecords 
						values(@NewCreativedetailId,'',@NewCreativedetailId+'.'+@FileType,'',@CreativeFileRepository,@CreativeMasterID,@FileType)
												
						select * from @oldCreativeDetailrecords

			    END
						
	COMMIT TRANSACTION
	END TRY
	

	 BEGIN CATCH 

        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_EmailAddCreativesforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 
    
END