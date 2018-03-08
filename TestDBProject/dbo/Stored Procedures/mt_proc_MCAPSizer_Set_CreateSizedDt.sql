

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[mt_proc_MCAPSizer_Set_CreateSizedDt]
	-- Add the parameters for the stored procedure here
	@VehicleId int
AS
BEGIN
	
	Declare @AssetThmbnlName as varchar(1000)
	Declare @ThmbnlRep  as varchar(1000)
	Declare @ThmbnlFileType  as varchar(50)



	select @ThmbnlRep= replace(CreativeRepository, 'Original', 'Thumb'), 
		@AssetThmbnlName = CreativeAssetName, @ThmbnlFileType = 
		CreativeFileType
	 from [CreativeDetailEM]
	where CreativeRepository like '\EML\%'
	and CreativeMasterID = @VehicleId
	and PageNumber=1


	If @AssetThmbnlName is null
	begin
		select @ThmbnlRep= replace(CreativeRepository, 'Original', 'Thumb'), 
		@AssetThmbnlName = CreativeAssetName, 
		@ThmbnlFileType = CreativeFileType
		from [CreativeDetailODR]
		where CreativeRepository like '\OD\%'
		and CreativeMasterID = @VehicleId
	end
	

	Update Creative set
	AssetThmbnlName =@AssetThmbnlName, 
	 ThmbnlRep  = @ThmbnlRep,
	 ThmbnlFileType =@ThmbnlFileType
	from  [Creative] 
	where Creative.PK_Id = @VehicleId


END


