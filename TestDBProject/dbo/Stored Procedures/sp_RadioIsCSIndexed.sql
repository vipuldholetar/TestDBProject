
-- ===========================================================================
-- Author:		Arun Nair 
-- Create date: 25 April 2015
-- Description:	Check If Creative Signature Already Mapped to an Ad
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=============================================================================
CREATE PROCEDURE [dbo].[sp_RadioIsCSIndexed] -- 'M2776967-20685019'
	(@CreativeSignature AS NVARCHAR(20))
AS
BEGIN
	--BEGIN TRY
		IF NOT EXISTS (
				SELECT creativesignature
				FROM PatternStaging
				WHERE creativesignature= @CreativeSignature
				--SELECT occurrenceid
				--FROM [vw_OccurencesBySessionDate]
				--WHERE RCSCREATIVEID = @CreativeSignature
				)
			SELECT 'Yes' AS Result
		ELSE
			SELECT 'No' AS Result
	--END TRY

	--BEGIN CATCH
	--	DECLARE @error INT
	--		,@message VARCHAR(4000)
	--		,@lineNo INT

	--	SELECT @error = Error_number()
	--		,@message = Error_message()
	--		,@lineNo = Error_line()

	--	RAISERROR (
	--			'[sp_RadioIsCSIndexed]: %d: %s'
	--			,16
	--			,1
	--			,@error
	--			,@message
	--			,@lineNo
	--			);
	--END CATCH
END
