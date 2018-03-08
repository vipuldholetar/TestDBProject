-- =======================================================================================================================
-- Author		: Karunakar
-- Create date	: 25th June 2015
-- Execution	:
-- Description	: This Procedure is Used to Change the Thumbnail of CreativeMasterId Primary Creative Indicator  of Ad
-- Updated By	:
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateDefaultThumbnailPrimaryIndicatorforAd]
(
@CreativeMasterId As Int,
@AdId As Int, 
@LocationId AS INT,
@Filename as varchar(max),
@fileext as varchar(10),
@path as varchar(max)
)
AS
BEGIN	
	SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @IsCompleted As integer
			DECLARE @BasePath AS VARCHAR(MAX)	
			DECLARE @RemoteBasePath AS VARCHAR(MAX)
			DECLARE @SubFolder AS VARCHAR(Max)
			DECLARE @Mediatype AS VARCHAR(10)

			if (charindex('\EML\', @path) > 0)
			Begin
				set @SubFolder='EML'
				set @Mediatype='EM'
			End
			else if (charindex('\OD\', @path) > 0)
			Begin
				set @SubFolder='OD'
				set @Mediatype='OD'
			End

			select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'
			IF @LocationId = 58
			exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder=@SubFolder,@Mediatype=@Mediatype,@Ext=0
			ELSE IF @LocationId = 4126
			exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder=@SubFolder,@Mediatype=@Mediatype,@Ext=0
			ELSE	
			SET @BasePath = @RemoteBasePath
		
			IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 


			Set @BasePath= case when @BasePath like '%\' then SUBSTRING(@BasePath,1, DATALENGTH(@BasePath)-1) else @BasePath end

			Set @path =REPLACE(@path,@BasePath,'')
			Set @path =REPLACE(@path,@Filename,'')
			PRINT @path

			IF EXISTS(Select * from [Creative] Where [Creative].PK_Id=@CreativeMasterId and [Creative].[AdId]=@AdId)
				BEGIN
				   Update [Creative] SET PrimaryIndicator=0 WHERE [Creative].[AdId]=@AdId and [SourceOccurrenceId] is null
				   Update [Creative] SET PrimaryIndicator=1, AssetThmbnlName=@Filename, ThmbnlFileType=@fileext, ThmbnlRep=@path
				    WHERE [Creative].[AdId]=@AdId and [Creative].PK_Id=@CreativeMasterId
				   SET @IsCompleted=1
				END
			Else
				BEGIN
					SET @IsCompleted=0
				END   
			SELECT @IsCompleted AS IsCompleted
		END TRY

		BEGIN CATCH
				DECLARE @error  INT, @message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_UpdateDefaultThumbnailPrimaryIndicatorforAd]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH

END
