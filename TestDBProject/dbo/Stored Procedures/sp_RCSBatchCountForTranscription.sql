-- =============================================

-- Author:		Monika. J

-- Create date: 09/01/2015

-- Description:	Procedure for Cinema Ingestion -- To get batch count for Ingestion

-- =============================================

CREATE PROCEDURE [dbo].[sp_RCSBatchCountForTranscription] 

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

	SET @Count = (SELECT count(*) FROM [CreativeDetailStagingRA] T1 INNER JOIN [PatternStaging] T2 ON T1.[CreativeStgID]=T2.[CreativeStgID]
	INNER JOIN [Speaker] T3 ON T2.[LanguageID]=T3.LanguageID WHERE T1.AudioTranscription IS NULL)

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