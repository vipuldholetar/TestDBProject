-- =============================================
-- Author			:	Rupinderjit Singh Batra
-- Create date		:	02/06/2015
-- Description		:	Insert Thumbnails for Ad
-- Execution Process: sp_InsertAdOtherThumbnail 5202,'D:\Users\Public\Pictures\Sample Pictures\Penguins.jpg','D:\MT_Assets\','penguins.jpg','*.jpg'
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertAdOtherThumbnail]
(
@AdID AS INT,
@BasePath as nvarchar(max),
@CreativeRepository as nvarchar(max),
@creativeAssetname as nvarchar(150),
@CreativeFileType as nvarchar(max)
)
AS
BEGIN
		BEGIN TRY
		begin transaction
					if exists(select 1 from [Creative] where [AdId]=@AdID and PrimaryIndicator=1 and [SourceOccurrenceId] is null)
					begin
					insert into [Creative]([AdId],PrimaryIndicator,AssetThmbnlName,ThmbnlRep,ThmbnlFileType) 
					values(@adid,0,@creativeAssetname,cast(@AdID as varchar(50))+'\OtherThumbnails\',@CreativeFileType)
					end
					else
					begin
					insert into [Creative]([AdId],PrimaryIndicator,AssetThmbnlName,ThmbnlRep,ThmbnlFileType) 
					values(@adid,1,@creativeAssetname,cast(@AdID as varchar(50))+'\Thumbnail\',@CreativeFileType)
					end

					commit transaction	
		
		END TRY

		BEGIN CATCH
		rollback transaction
				 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_InsertAdOtherThumbnail: %d: %s',16,1,@error,@message,@lineNo); 		
		END CATCH
		
END
