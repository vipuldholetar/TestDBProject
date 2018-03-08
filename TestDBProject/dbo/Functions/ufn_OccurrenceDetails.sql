-- =============================================
-- Author:		Monika. J
-- Create date: 10-19-2015
-- Description:	Function to get OccurrenceDetails
-- =============================================
CREATE FUNCTION [dbo].[ufn_OccurrenceDetails]
(	
	-- Add the parameters for the function here
	@OccurrenceID int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	--Cinema Occurrence
	SELECT a.[OccurrenceDetailCINID] as PK_ID,
		a.[AdID],
		a.[AirDT] as AdDate,	
		a.[PatternID] as FK_PatternMasterID,
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode as NoTakeReason,
		'' as IsQuery,	
		c.CreatedBY as CreateBY,
		a.[CreatedDT] as CreateDate,
		c.ModifiedBy as ModifiedBy,
		a.[ModifiedDT] as ModifiedDate
	FROM [OccurrenceDetailCIN] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailCINID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailCINID] = c.[PrimaryOccurrenceID]

	UNION ALL

	--Circular Occurrence
	SELECT a.[OccurrenceDetailCIRID],
		a.[AdID],
		a.AdDate as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		a.NoTakeReason,
		a.[Query] as IsQuery,	
		a.[CreatedByID],
		a.[CreatedDT],
		a.[ModifiedByID],
		a.[ModifiedDT]
	FROM [OccurrenceDetailCIR] a, [Pattern] b	
	WHERE a.[OccurrenceDetailCIRID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--EM Occurrence
		SELECT a.[OccurrenceDetailEMID],
		a.[AdID],
		a.[AdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		a.NoTakeReason,
		a.[Query] as IsQuery,	
		a.[CreatedByID],
		a.[CreatedDT],
		a.[ModifiedByID],
		a.[ModifiedDT]
	FROM [OccurrenceDetailEM] a, [Pattern] b	
	WHERE a.[OccurrenceDetailEMID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--MOB Occurrence
	SELECT a.[OccurrenceDetailMOBID],
		a.[AdID],
		c.[CommonAdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		c.CreatedBY,
		a.[CreatedDT],
		c.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailMOB] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailMOBID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailMOBID] = c.[PrimaryOccurrenceID]

	UNION ALL

	--ODR Occurrence
	SELECT a.[OccurrenceDetailODRID],
		a.[AdID],
		c.[CommonAdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		c.CreatedBY,
		a.[CreatedDT],
		c.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailODR] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailODRID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailODRID] = c.[PrimaryOccurrenceID]
	
	UNION ALL

	--OND Occurrence	
	SELECT a.[OccurrenceDetailONDID],
		a.[AdID],
		c.[CommonAdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		c.CreatedBY,
		a.[CreatedDT],
		c.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailOND] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailONDID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailONDID] = c.[PrimaryOccurrenceID]

	UNION ALL

	--ONV Occurrence
	SELECT a.[OccurrenceDetailONVID],
		a.[AdID],
		c.[CommonAdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		c.CreatedBY,
		a.[CreatedDT],
		c.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailONV] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailONVID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailONVID] = c.[PrimaryOccurrenceID]

	UNION ALL

	--PUB Occurrence
	SELECT a.[OccurrenceDetailPUBID],
		a.[AdID],
		a.[AdDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		a.NoTakeReason,
		a.[Query] as IsQuery,			
		a.[CreatedByID],
		a.[CreatedDT],
		a.[ModifiedByID],
		a.[ModifiedDT]
	FROM [OccurrenceDetailPUB] a, [Pattern] b	
	WHERE a.[OccurrenceDetailPUBID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--RA Occurrence
	SELECT a.[OccurrenceDetailRAID],
		a.[AdID],
		a.[AirDT] as AdDate,	
		a.[PatternID] as FK_PatternMasterID,
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		a.[CreatedByID],
		a.[CreatedDT],
		a.[ModifiedByID],
		a.[ModifiedDT]
	FROM [OccurrenceDetailRA] a, [Pattern] b	
	WHERE a.[OccurrenceDetailRAID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--TV Occurrence		
	SELECT a.[OccurrenceDetailTVID],--a.PK_ID,
		a.[AdID],
		a.[AirDT] as AdDate,	
		a.[PatternID] as FK_PatternMasterID,
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		c.CreatedBY,
		a.[CreatedDT] as CreateDate,
		c.ModifiedBy,
		b.ModifyDate
	FROM [OccurrenceDetailTV] a, [Pattern] b,Ad c	
	WHERE a.[OccurrenceDetailTVID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]
	AND a.[OccurrenceDetailTVID] = c.[PrimaryOccurrenceID]
)