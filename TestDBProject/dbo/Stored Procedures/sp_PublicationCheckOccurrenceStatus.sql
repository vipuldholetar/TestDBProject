-- =============================================
-- Author:		Karunakar
-- Create date: 06/10/2015
-- Description:	This Procedure is Used to Check the Status of Occurrence
-- EXEc sp_PublicationCheckOccurrenceStatus 9
-- =============================================
CREATE PROCEDURE [dbo].[sp_PublicationCheckOccurrenceStatus] 
	@PubIssueId As Int
AS
BEGIN
	
	SET NOCOUNT ON;
	  Declare @isCompleted as BIT
	  Declare @isQuery as BIT=1


	   if Exists(Select [OccurrenceDetailPUBID] from [OccurrenceDetailPUB] Where [PubIssueID]=@PubIssueId)
	   BEGIN
		  if Exists(Select [OccurrenceDetailPUBID] from [OccurrenceDetailPUB] Where [PubIssueID]=@PubIssueId and [Query]=@isQuery)
		  Begin
		  --IF File is Exists in Record 
		  Set @isCompleted=0 
		  End
		  Else
		  BEGIN
		   --IF File is Not Exists in Record 
		  Set @isCompleted=1
		  End    
		  select  @isCompleted as isCompleted
	   END

      
END
