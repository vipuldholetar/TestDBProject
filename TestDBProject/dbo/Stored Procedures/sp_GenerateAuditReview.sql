/****** Object:  StoredProcedure [dbo].[sp_GenerateAuditReview]    Script Date: 6/7/2016 12:39:26 PM ******/
CREATE procedure [dbo].[sp_GenerateAuditReview]
@GenerateDT datetime = null
AS

--declare @GenerateDT datetime
if (@GenerateDT is null)
	set @GenerateDT = GETDATE()

DECLARE user_cursor CURSOR FOR   
select 
	e.UserID, (e.TotalNeeded - (e.TotalOccurrences - e.NonReviewOccurrences)) totalNeeded
FROM (
	select c.UserID, c.TotalOccurrences, [User].AuditRate,  (c.TotalOccurrences * ([User].AuditRate/100)) TotalNeeded, d.NonReviewOccurrences FROM (
		select a.UserID, count(*) TotalOccurrences FROM (
			SELECT DISTINCT b.UserID, b.OccurrenceID FROM AuditLogging b 
			WHERE b.CreatedDT >= DATEADD(day, -7, @GenerateDT)) a
		GROUP BY a.UserID) c
		INNER JOIN [User] on [User].UserID = c.UserID
		INNER JOIN (
			select a.UserID, count(*) NonReviewOccurrences
			FROM (
				SELECT DISTINCT b.UserID, b.OccurrenceID
				FROM AuditLogging b 
				WHERE b.CreatedDT >= DATEADD(day, -7, @GenerateDT)
				and not exists (select * from AuditReview c where c.UserID = b.UserID and c.OccurrenceID = b.OccurrenceID 
				and c.CreatedDT >= DATEADD(day, -7, @GenerateDT))) a
		GROUP BY a.UserID) d
		on d.UserID = c.UserID) e
  
OPEN user_cursor  
  
declare 
	@userID int, 
	@totalNeeded decimal(21, 4), 
	@occurrenceID int, 
	@occurrenceMediaType int

FETCH NEXT FROM user_cursor   
INTO @userID, @totalNeeded  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	--print 'Looping for user ' + cast(@userID as varchar(10))

	DECLARE audit_cursor CURSOR FOR  
		select OccurrenceID, MediaType from AuditLogging a
		where a.UserID = @userID and 
		a.CreatedDT >= DATEADD(day, -7, @GenerateDT)
		and not exists (
		select * from AuditReview b 
		where UserID = @userID and a.OccurrenceID = b.OccurrenceID
		and b.CreatedDT >= DATEADD(day, -7, @GenerateDT))
		order by NEWID()

		--print '@userID = ' + cast(@userID as varchar(20))
		--print '@GenerateDT = ' + cast(@GenerateDT as varchar(20))
		--print cast(@@rowcount as varchar(10)) + ' records found'
	
	OPEN audit_cursor  

	FETCH NEXT FROM audit_cursor   
	INTO @occurrenceID, @occurrenceMediaType
	  
	declare @remaining int

	set @remaining = @totalNeeded
	--print '@remaining = ' + cast(@remaining as varchar(20))

	WHILE @@FETCH_STATUS = 0  --and @remaining <> 0
	BEGIN  
		--print 'Looping audit records'
		--print '@occurrenceID = ' + cast(@occurrenceID as varchar(10))
		--print '@userID = ' + cast(@userID as varchar(10))
		--print '@occurrenceMediaType = ' + cast(@occurrenceMediaType as varchar(20))
		insert into AuditReview(OccurrenceID, UserID, OccurrenceMediaType, [Action], CreatedDT)
		values (@occurrenceID,@userID, @occurrenceMediaType, '', GETDATE())
		
		--set @remaining = @remaining - 1

		FETCH NEXT FROM audit_cursor   
		INTO @occurrenceID , @occurrenceMediaType 
	END
	CLOSE audit_cursor;  
	DEALLOCATE audit_cursor;  
	
	FETCH NEXT FROM user_cursor   
	INTO @userID, @totalNeeded  
END   
CLOSE user_cursor;  
DEALLOCATE user_cursor; 

--END 