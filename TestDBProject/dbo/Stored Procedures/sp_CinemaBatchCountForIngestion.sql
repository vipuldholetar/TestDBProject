-- =============================================

-- Author:		Monika. J

-- Create date: 09/01/2015

-- Description:	Procedure for Cinema Ingestion -- To get batch count for Ingestion

-- =============================================

CREATE PROCEDURE sp_CinemaBatchCountForIngestion 

	-- Add the parameters for the stored procedure here

	

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



    -- Insert statements for procedure here

	Declare @Count int

	Declare @Batch int	
	Declare @BatchRemainder int	

	SET @Count = (select count (*) from NCMRawData where ingestionstatus=0)

	SET @Batch = @Count / 500;
	set @BatchRemainder=@Count%500;

	if(@BatchRemainder>0)
		begin	
		     Select @Batch+1 as BatchCount
		end
	else
		begin
		     Select @Batch as BatchCount
		end

END
