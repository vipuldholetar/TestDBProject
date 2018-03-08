CREATE PROCEDURE [dbo].[sp_CopyCreativeforAd]
	@AdId INTEGER,
	@PageNumber INTEGER,
	@fileName VARCHAR(200),
	@mediaType varchar(10)
AS
BEGIN
    DECLARE @oldcreativemasterid INTEGER
	DECLARE @newcreativemasterid INTEGER

       BEGIN TRY
			   BEGIN TRANSACTION
					   SELECT top 1 @oldcreativemasterid=PK_Id FROM [Creative] WHERE [AdId]=@AdId 
			
			if @mediaType = 'Email'
			begin
				  INSERT INTO CreativeDetailEM(CreativeMasterID,CreativeAssetName,creativeRepository,LegacyAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,PageNumber,PageName) 
							 SELECT TOP 1 @oldcreativemasterid,@fileName
							 ,creativeRepository,LegacyAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,@PageNumber,@PageNumber
				  FROM  CreativeDetailEM WHERE CreativeMasterID=@oldcreativemasterid order by CreativeDetailsEMID desc
				  end

				  if @mediaType = 'Circular'
				  begin
				  INSERT INTO CreativeDetailCIR(CreativeMasterID,CreativeAssetName,creativeRepository,LegacyCreativeAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,PageNumber,PageName) 
							 SELECT TOP 1 @oldcreativemasterid,@fileName
							 ,creativeRepository,LegacyCreativeAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,@PageNumber,@PageNumber
				  FROM  CreativeDetailCIR WHERE CreativeMasterID=@oldcreativemasterid order by CreativeDetailID desc
				  end
				  
			COMMIT TRANSACTION
	   END TRY 
     BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_CopyCreativeforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 

END