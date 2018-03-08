CREATE PROCEDURE [dbo].[sp_EmailCopyCreativeforAd]
	@AdId INTEGER,
	@PageNumber INTEGER,
	@fileName VARCHAR(200)
AS
BEGIN
    DECLARE @oldcreativemasterid INTEGER
	DECLARE @newcreativemasterid INTEGER

       BEGIN TRY
			   BEGIN TRANSACTION
					   SELECT @oldcreativemasterid=PK_Id FROM [Creative] WHERE [AdId]=@AdId 
					   
				  INSERT INTO CreativeDetailEM(CreativeMasterID,CreativeAssetName,creativeRepository,LegacyAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,PageNumber,PageName) 
							 SELECT TOP 1 @oldcreativemasterid,@fileName
							 ,creativeRepository,LegacyAssetname,CreativeFileType,PageTypeId,Deleted,SizeID,@PageNumber,@PageNumber
				  FROM  CreativeDetailEM WHERE CreativeMasterID=@oldcreativemasterid order by CreativeDetailsEMID desc

			COMMIT TRANSACTION
	   END TRY 
     BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_EmailCopyCreativeforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 

END