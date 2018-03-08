CREATE PROCEDURE [dbo].[sp_DeleteCreative]  
(
@id AS INT ,
@MediaStream AS NVARCHAR(MAX),
@CreativeCropId INT
)
AS
BEGIN
              DECLARE @MediaStreamValue As Nvarchar(max)=''			   
              SELECT @MediaStreamValue=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaStream
			  DECLARE @MediaStreamBasePath As Nvarchar(max)=''
			  select @MediaStreamBasePath=VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository';
			  --SELECT @MediaStreamValue as MS,@MediaStreamBasePath as path
              BEGIN TRY
              
				   IF(@MediaStreamValue='EM') -- Email
					   BEGIN
							UPDATE [CreativeDetailEM] SET Deleted = 1 where CreativeDetailsEMID = @id
							UPDATE CompositeCropStaging SET Deleted = 1 WHERE CreativeCropStagingID = @CreativeCropId
					   END	
					   IF(@MediaStreamValue='CIR')             --Mobile
                     BEGIN
					  		UPDATE [CreativeDetailCIR] SET Deleted = 1 where CreativeDetailID = @id
							UPDATE CompositeCropStaging SET Deleted = 1 WHERE CreativeCropStagingID = @CreativeCropId
                     END     
              END TRY
              BEGIN CATCH
                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                                  RAISERROR ('sp_DeleteCreative: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH
END