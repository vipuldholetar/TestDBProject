CREATE PROCEDURE [dbo].[sp_RadioGetAdPrimaryCreativeFile]
@pAdid int
AS
		BEGIN TRY
			SELECT [Creative].PK_Id As CreativeMasterId,[CreativeDetailRA].[CreativeDetailRAID] AS Creativedetailid,[Creative].PrimaryIndicator,
			[CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) As CreativeFilePath,
			CAST([CreativeDetailRA].[CreativeDetailRAID] as varchar)+'-'+[CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) AS DetailIDwithFilepath,
			[Creative].SourceOccurrenceId
			FROM [Creative] INNER JOIN [CreativeDetailRA] on [Creative].PK_Id=[CreativeDetailRA].[CreativeID] 
			AND [Creative].[AdId]=@pAdid	
			AND [Creative].PrimaryIndicator=1
		END TRY 
	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_RadioGetAdPrimaryCreativeFile]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH