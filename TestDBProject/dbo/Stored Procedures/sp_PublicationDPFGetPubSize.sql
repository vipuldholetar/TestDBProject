-- ===================================================================================================================
-- Author			: Karunakar		
-- Create date		: 30th December 2015
-- Description		: This Procedure is used for getting Publication Size from Size table
-- Updated By		: Arun Nair on 01/05/2016 - Changed Size Description as per Height X Width As discussed with RP
-- Execute			: [dbo].[sp_PublicationDPFGetPubSize] 1,3277,1
-- ====================================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFGetPubSize] 
	(
	@publicationid as Int,	
	@SizingMethod as int,
	@IsPubTypeCir as bit
	)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 
	--Selecting SizeDesc from Size
		IF(@IsPubTypeCir=0)
			BEGIN
				SELECT Distinct [SizeDescrip], [SizeID] FROM Size inner join Publication on Size.[PubTypeID]=Publication.PubType 
				WHERE [SizingMethodID] = @SizingMethod AND Publication.[PublicationID] = @publicationid
				ORDER BY [SizeDescrip]
			END
		ELSE
			BEGIN
				SELECT Distinct  [SizeDescrip], [SizeID] FROM Size WHERE  [SizingMethodID] = @SizingMethod ORDER BY [SizeDescrip]
			END
	END TRY
	 BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_PublicationDPFGetPubSize: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH
END
