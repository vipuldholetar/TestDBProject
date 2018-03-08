



-- ===============================================================================================================
-- Author		:	Arun Nair 
-- Create date	:	12th Dec 2015
-- Description	:	
-- Execute		:	
-- Updated By	:   
--					
-- ===============================================================================================================

CREATE Procedure [dbo].[sp_CheckMapStatusForOccurrence]
(
@OccurrenceId As BigInt
)
AS
BEGIN
	   DECLARE @MediaStream VARCHAR(20)
       DECLARE @Result INTEGER =0
	   DECLARE @MapStatus AS NVARCHAR(20)
	    DECLARE @IndexStatus AS NVARCHAR(20)
       SET NOCOUNT ON;
              BEGIN TRY              
				SET @MediaStream=(SELECT dbo.fn_GetMediaStream(@OccurrenceID));
                IF @MediaStream='CIR' 
					BEGIN
						SELECT 
						@MapStatus=b.[Status],
						@IndexStatus=c.[Status] 
						from [dbo].[OccurrenceDetailCIR] a
						inner join MapStatus b on a.MapStatusID = b.MapStatusID
						inner join IndexStatus c on a.IndexStatusID = c.IndexStatusID
						WHERE [OccurrenceDetailCIRID]=@OccurrenceId						 
					END
				IF @MediaStream='PUB' 
					BEGIN
						SELECT 
						@MapStatus=b.[Status],
						@IndexStatus=c.[Status] 
						from [dbo].[OccurrenceDetailPUB] a
						inner join MapStatus b on a.MapStatusID = b.MapStatusID
						inner join IndexStatus c on a.IndexStatusID = c.IndexStatusID
						 WHERE [OccurrenceDetailPUBID]=@OccurrenceId
					END
				IF @MediaStream='EM' 
					BEGIN
						SELECT 
						@MapStatus=b.[Status],
						@IndexStatus=c.[Status] 
						from [dbo].[OccurrenceDetailEM] a
						inner join MapStatus b on a.MapStatusID = b.MapStatusID
						inner join IndexStatus c on a.IndexStatusID = c.IndexStatusID
						WHERE [OccurrenceDetailEMID]=@OccurrenceId
					END
				IF @MediaStream='WEB' 
					BEGIN
						SELECT 
						@MapStatus=b.[Status],
						@IndexStatus=c.[Status] 
						from [dbo].[OccurrenceDetailWEB] a
						inner join MapStatus b on a.MapStatusID = b.MapStatusID
						inner join IndexStatus c on a.IndexStatusID = c.IndexStatusID
						WHERE [OccurrenceDetailWEBID]=@OccurrenceId
					END
				IF @MediaStream='SOC' 
					BEGIN
						SELECT 
						@MapStatus=b.[Status],
						@IndexStatus=c.[Status] 
						from [dbo].[OccurrenceDetailSOC] a
						inner join MapStatus b on a.MapStatusID = b.MapStatusID
						inner join IndexStatus c on a.IndexStatusID = c.IndexStatusID
						WHERE [OccurrenceDetailSOCID]=@OccurrenceId
					END

				IF(@MapStatus='Complete' AND  @IndexStatus ='Complete')
					BEGIN
						SET @Result=1
					END
					
					SELECT @Result

			  END TRY
			  BEGIN CATCH 
					 DECLARE @error   INT, @message VARCHAR(4000),  @lineNo  INT 
                     SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_CheckMapStatusForOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 
			  END CATCH          


END