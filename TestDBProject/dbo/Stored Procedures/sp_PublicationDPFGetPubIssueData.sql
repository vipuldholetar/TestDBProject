-- =============================================
-- Author:		Karunakar 
-- Create date: 12th june 2015
-- Description:	This PRocedure is Used to Get the Publication and Edition Data
--Exec sp_PublicationDPFGetPubIssueData 9
-- =============================================
CREATE PROCEDURE sp_PublicationDPFGetPubIssueData
	@PubIssueId As Int
AS
BEGIN
	
	SET NOCOUNT ON;

   
						SELECT  Publication.[PublicationID], Publication.Descrip,PubEdition.[PubEditionID], PubEdition.EditionName
                         FROM            PubIssue INNER JOIN
                         PubEdition ON PubIssue.[PubEditionID] = PubEdition.[PubEditionID] INNER JOIN
                         Publication ON PubEdition.[PublicationID] = Publication.[PublicationID] where PubIssue.[PubIssueID]=@PubIssueId
END
