
-- ===========================================================================
-- Author			: RP
-- Create date		: 04/18/2015
-- Description		: This stored procedure is used to retreive creative details for Ad
-- Execution Process: [sp_RadioGetAdCreatives] 56
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
-- =============================================================================

CREATE PROCEDURE [dbo].[sp_RadioGetAdCreatives]
(
	@pADID int
)
AS
BEGIN
       BEGIN TRY
		  SELECT [Creative].PK_Id AS Creativemasterid,[CreativeDetailRA].[CreativeDetailRAID] AS Creativedetailid,[Creative].PrimaryIndicator AS Primarycreativeindicator,
		  [CreativeDetailRA].Rep + [CreativeDetailRA].AssetName +'.'+rtrim(ltrim([CreativeDetailRA].FileType)) As CreativeFilePath,
		  cast([CreativeDetailRA].[CreativeDetailRAID] as varchar)+'-'+[CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+rtrim(ltrim([CreativeDetailRA].FileType))  as DetailIDwithFilepath 
		  FROM [Creative] inner join [CreativeDetailRA] on [Creative].PK_Id=[CreativeDetailRA].[CreativeID] and [Creative].[AdId]=@pAdid
		  and PrimaryIndicator=1
	   END TRY 

     BEGIN CATCH 
        DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_RadioGetAdCreatives: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH 
END
