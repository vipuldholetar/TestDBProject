﻿-- =============================================
-- Author:		Monika. J
-- Create date: 10-19-2015
-- Description:	Function to get OccurrenceDetails
-- =============================================
CREATE FUNCTION ufn_CPOccurrenceDetails --select * from ufn_OccurrenceDetails(1)
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
		b.CreateBY as CreateBY,
		a.[CreatedDT] as CreateDate,
		b.ModifiedBy as ModifiedBy,
		a.[ModifiedDT] as ModifiedDate
	FROM [OccurrenceDetailCIN] a, [Pattern] b	
	WHERE a.[OccurrenceDetailCINID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

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
		a.[OccurrenceDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		b.CreateBY,
		a.[CreatedDT],
		b.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailMOB] a, [Pattern] b	
	WHERE a.[OccurrenceDetailMOBID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--ODR Occurrence
	SELECT a.[OccurrenceDetailODRID],
		a.[AdID],
		'' as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		b.CreateBY,
		a.[CreatedDT],
		b.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailODR] a, [Pattern] b	
	WHERE a.[OccurrenceDetailODRID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--OND Occurrence	
	SELECT a.[OccurrenceDetailONDID],
		a.[AdID],
		a.[OccurrenceDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		b.CreateBY,
		a.[CreatedDT],
		b.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailOND] a, [Pattern] b	
	WHERE a.[OccurrenceDetailONDID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

	UNION ALL

	--ONV Occurrence
	SELECT a.[OccurrenceDetailONVID],
		a.[AdID],
		a.[OccurrenceDT] as AdDate,	
		a.[PatternID],
		b.[CreativeID],
		b.MediaStream,
		b.NoTakeReasonCode,		
		'' as IsQuery,
		b.CreateBY,
		a.[CreatedDT],
		b.ModifiedBy,
		a.[ModifiedDT]
	FROM [OccurrenceDetailONV] a, [Pattern] b	
	WHERE a.[OccurrenceDetailONVID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

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
		b.CreateBY,
		a.[CreatedDT] as CreateDate,
		b.ModifiedBy,
		b.ModifyDate
	FROM [OccurrenceDetailTV] a, [Pattern] b	
	WHERE a.[OccurrenceDetailTVID] = @OccurrenceID
	AND b.[PatternID] = a.[PatternID]

)