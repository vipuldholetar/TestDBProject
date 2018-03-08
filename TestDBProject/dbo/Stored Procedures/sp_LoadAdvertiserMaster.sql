-- ===========================================================================
-- Author			:Arun Nair 
-- Create date		:12 Aug 2015
-- Description		:Get  AdvertiserMaster Values
-- Updated By		:Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadAdvertiserMaster]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY
			SELECT AdvertiserID, Descrip, Descrip + CASE WHEN NOT ([state] IS null) then ' ('+[state]+')'else '' END AS MergedDescrip
			FROM [Advertiser]
			where isnull(Advertiser.EndDT,'31 DEC 2099') > SYSDATETIME ( )
			order by descrip asc
		END TRY
		
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadAdvertiserMaster]: %d: %s',16,1,@error,@message,@lineNo); 			  
		END CATCH 
END