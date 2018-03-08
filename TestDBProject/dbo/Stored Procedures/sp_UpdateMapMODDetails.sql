-- ==========================================================
-- Author		:	Arun Nair 
-- Create date	:	01/18/2016
-- Execution	:	
-- Description	:	Update MapMOD Details 
-- Updated By	:	
-- ===========================================================
CREATE PROCEDURE [dbo].[sp_UpdateMapMODDetails] --'Test Description Detail','Test Revision Detail','CIR',27751,1,1
(
@Description AS NVARCHAR(MAX),
@RecutDetail AS NVARCHAR(MAX),
@MediaStream AS NVARCHAR(10),
@AdId AS INTEGER,
@IsScanReqd AS Bit,
@UserId AS INTEGER,
@IsMapAD as Bit
)
AS
BEGIN
	SET NOCOUNT ON; 	
		 
      BEGIN TRY 

	  if (@IsMapAD=1)
	  begin
				-- Update Original Ad description and RecutDetail
				DECLARE @originalAdDescription AS NVARCHAR(MAX) 
				DECLARE @originalAdRecutDetail AS NVARCHAR(MAX)
				

				SELECT @originalAdDescription= Description,@originalAdRecutDetail=RecutDetail FROM AD WHERE  [AdID] = @AdId


				IF(@originalAdDescription<>'')
					BEGIN
						UPDATE Ad SET    description =@originalAdDescription+Char(13) + Char(10) +@Description ,ModifiedDate=getdate(),ModifiedBy=@UserId  WHERE  [AdID] = @AdId
					END 
				ELSE
					BEGIN
						UPDATE Ad SET    description =@Description ,ModifiedDate=getdate(),ModifiedBy=@UserId  WHERE  [AdID] = @AdId
					END 

                IF @originalAdRecutDetail<>''
					BEGIN  
						UPDATE Ad SET    RecutDetail =@originalAdRecutDetail +Char(13) + Char(10)+ @RecutDetail,ModifiedDate=getdate(),ModifiedBy=@UserId  WHERE  [AdID] = @AdId
					END                                    
				ELSE
					BEGIN  
						UPDATE Ad SET    RecutDetail =@RecutDetail,ModifiedDate=getdate(),ModifiedBy=@UserId  WHERE  [AdID] = @AdId
					END 
		end

				DECLARE @WaitingScanStatusID INT
				DECLARE @CompleteScanStatusID INT
				
				select @WaitingScanStatusID = os.[ScanStatusID] 
				from ScanStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.ComponentName = 'Scan Status' AND c.Value = 'W' 
				
				select @CompleteScanStatusID = os.[ScanStatusID] 
				from ScanStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where c.ComponentName = 'Scan Status' AND c.Value = 'C' 
				
				IF(@IsScanReqd=1) 
					BEGIN
						IF(@MediaStream='CIR')
							BEGIN
								UPDATE 	[dbo].[OccurrenceDetailCIR] SET ScanStatusID = @WaitingScanStatusID WHERE [AdID] = @AdId  AND   ScanStatusID <> @CompleteScanStatusID
							END
						IF(@MediaStream='PUB')
							BEGIN
								UPDATE 	[dbo].[OccurrenceDetailPUB] SET ScanStatusID = @WaitingScanStatusID WHERE [AdID] = @AdId   AND   ScanStatusID <> @CompleteScanStatusID
							END
						IF(@MediaStream='EM')
							BEGIN
								UPDATE 	[dbo].[OccurrenceDetailEM] SET ScanStatusID = @WaitingScanStatusID WHERE [AdID] = @AdId   AND   ScanStatusID <> @CompleteScanStatusID
							END						
						IF(@MediaStream='SOC')
							BEGIN
								UPDATE 	[dbo].OccurrenceDetailSOC SET ScanStatusID=@WaitingScanStatusID WHERE AdId =@AdId   AND   ScanStatusID<>@CompleteScanStatusID
							END
						--IF(@MediaStream='WEB') 
						--	BEGIN
						--		UPDATE 	[dbo].OccurrenceDetailsWEB SET ScanStatus=@WaitingScanStatus WHERE FK_AdId =@AdId   AND   ScanStatus<>@CompleteScanStatus)
						--	END
					END 

	  END TRY
	  BEGIN CATCH		
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
	  END CATCH

END