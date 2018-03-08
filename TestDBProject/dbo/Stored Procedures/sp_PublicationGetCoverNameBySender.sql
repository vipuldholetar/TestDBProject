
CREATE PROCEDURE [dbo].[sp_PublicationGetCoverNameBySender]
(
@SenderId AS INTEGER
)
AS 
BEGIN
		  SET nocount ON; 

		  SELECT distinct p.PublicationID, p.CoverName FROM SenderPublication sp INNER JOIN Publication p ON sp.PublicationID = p.PublicationID
		  WHERE SenderID = @SenderId and p.CoverName is not null

END