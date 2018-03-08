
-- ====================================================================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   02/10/2016  
-- Description           :   This stored procedure is used to Get Data for " ROP & NON-ROP  " Reports Datasets
-- Execution Process     : [dbo].[sp_ROP_NonROPAds] '2015-02-11',1
-- Updated By            :   
-- =============================================================================================================

CREATE PROCEDURE [dbo].[Sp_ROP_NonROPAds] 
(
	@CutOffDate DATE,
	@RopType Bit
)  
As
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQLStmntCIR VARCHAR(MAX)
	DECLARE @SQLStmntPUB VARCHAR(MAX)
	DECLARE @FinalSQLStmnt NVARCHAR(MAX)
	DECLARE @WhereCIR AS VARCHAR(MAX)
	DECLARE @WherePUB AS VARCHAR(MAX)
	DECLARE @search_term INTEGER = 0

	BEGIN TRY
		If(@RopType = 0) 
		BEGIN
			SET @search_term=8
		END
		SET @SQLStmntCIR='SELECT OccurrenceDetailsCIR.PK_OccurrenceID,
				OccurrenceDetailsCIR.FK_AdID,
				OccurrenceDetailsCIR.AdDate,
				Advertisermaster.Descrip,
				Marketmaster.Description as Market, 
				Publication.Descrip as Publication,
				PubEdition.EditionName as Edition,
				PatternMaster.SalesStartDate,
				PatternMaster.SalesEndDate,
				MediaType.Descrip as MediaType,
				(CASE 
				WHEN OccurrenceDetailsCIR.OccurrenceStatus = ''Completed'' THEN ''Completed''
				WHEN OccurrenceDetailsCIR.OccurrenceStatus = ''In Progress'' THEN
				CASE 
				WHEN OccurrenceDetailsCIR.QCStatus = ''Completed'' THEN ''QC Completed''
				WHEN OccurrenceDetailsCIR.IndexStatus = ''Completed'' THEN ''Indexed''
				ELSE ''Not Indexed''
				END
				WHEN OccurrenceDetailsCIR.OccurrenceStatus = ''No Take'' THEN OccurrenceDetailsCIR.NoTakeReason
				END) as Status,
				Sender.Name as Sender,
				OccurrenceDetailsCIR.FlyerID
				FROM OccurrenceDetailsCIR 
				Inner Join Ad On Ad.PK_Id = OccurrenceDetailsCIR.FK_AdID
				Inner Join  Envelope On Envelope.PK_EnvelopeID = OccurrenceDetailsCIR.FK_EnvelopeID
				Inner Join Sender on Sender.PK_SenderID = Envelope.SenderId
				Inner Join Marketmaster On Marketmaster.MarketCode = OccurrenceDetailsCIR.FK_MarketID
				Inner Join PubEdition on PubEdition.PK_PubEditionID = OccurrenceDetailsCIR.FK_PubEditionID
				Inner Join Publication on Publication.PK_PublicationId = PubEdition.FK_PublicationID
				Inner Join MediaType on MediaType.PK_MediaTypeID = OccurrenceDetailsCIR.FK_MediaTypeID
				Inner Join Advertisermaster On Advertisermaster.AdvertiserID = Ad.AdvId
				Inner Join PatternMaster On PatternMaster.PK_Id = OccurrenceDetailsCIR.FK_PatternMasterID '
			SET @WhereCIR ='Where  1=1'
			IF( @RopType = 1 ) 
			BEGIN 
				SET @WhereCIR = @WhereCIR 
				+ ' AND OccurrenceDetailsCIR.FK_MediaTypeID >= ''' 
				+ Convert(VARCHAR,@search_term) 
				+ ''' AND (OccurrenceDetailsCIR.QCStatus = ''Completed'' OR OccurrenceDetailsCIR.OccurrenceStatus = ''Completed'') OR OccurrenceDetailsCIR.CreateDTM >= ''' 
				+ convert(VARCHAR,DATEADD(DAY, -30, @CutoffDate))+''' AND OccurrenceDetailsCIR.ModifiedDTM IS NULL'
			END
					
			ELSE
			BEGIN 
				SET @WhereCIR = @WhereCIR 
				+ ' AND Convert(VARCHAR,OccurrenceDetailsCIR.FK_MediaTypeID) ='''
				+ Convert(VARCHAR, @search_term) +''' AND (OccurrenceDetailsCIR.ModifiedDTM >= '''
				+ convert(VARCHAR,dateADD(day, -30, @CutoffDate)) + ''' OR OccurrenceDetailsCIR.CreateDTM >= '''	
				+ convert(VARCHAR,dateADD(day, -30, @CutoffDate)) + ''') AND OccurrenceDetailsCIR.ModifiedDTM IS NULL'
			END
			SET @SQLStmntPUB = ' UNION SELECT OccurrenceDetailsPUB.PK_OccurrenceID, OccurrenceDetailsPUB.FK_AdID,
				OccurrenceDetailsPUB.AdDate,Advertisermaster.Descrip,
				MarketMaster.Description as Market,Publication.Descrip as Publication,
				PubEdition.EditionName as Edition,
				PatternMaster.SalesStartDate,PatternMaster.SalesEndDate,
				MediaType.Descrip as MediaType,
				(CASE WHEN OccurrenceDetailsPUB.OccurrenceStatus = ''Completed'' THEN ''Completed''
						WHEN OccurrenceDetailsPUB.OccurrenceStatus = ''In Progress'' THEN
					CASE WHEN OccurrenceDetailsPUB.QCStatus = ''Completed'' THEN ''QC Completed''
						WHEN OccurrenceDetailsPUB.IndexStatus = ''Completed'' THEN ''Indexed''
						ELSE ''Not Indexed''
					END
						WHEN OccurrenceDetailsPUB.OccurrenceStatus = ''No Take'' THEN OccurrenceDetailsPUB.NoTakeReason
						END) as Status,
						Sender.Name as Sender,
						OccurrenceDetailsPUB.FlyerID
				FROM OccurrenceDetailsPUB 
				Inner Join Ad On Ad.PK_Id = OccurrenceDetailsPUB.FK_AdId
				Inner Join PubIssue On PubIssue.PK_PubIssueID = OccurrenceDetailsPUB.FK_PubIssueID
				Inner Join Sender On Sender.PK_SenderID = PubIssue.FK_SenderID
				Inner Join MarketMaster On MarketMaster.MarketCode = OccurrenceDetailsPUB.FK_MarketID
				Inner Join PubEdition On PubEdition.PK_PubEditionID = PubIssue.FK_PubEditionID
				Inner Join Publication On Publication.PK_PublicationID = PubEdition.FK_PublicationID
				Inner Join MediaType On MediaType.PK_MediaTypeID = OccurrenceDetailsPUB.FK_MediaTypeID
				Inner Join Advertisermaster On Advertisermaster.AdvertiserID = Ad.AdvId
				Inner Join PatternMaster On PatternMaster.PK_Id = OccurrenceDetailsPUB.FK_PatternMasterID '
			SET @WherePUB ='Where  1=1'
				
			IF( @RopType = 1 ) 
			BEGIN 
			SET @WherePUB = @WherePUB 
			+ ' AND OccurrenceDetailsPUB.FK_MediaTypeID >= ''' 
			+ Convert(VARCHAR,@search_term) 
			+ ''' AND (OccurrenceDetailsPUB.QCStatus = ''Completed'' OR OccurrenceDetailsPUB.OccurrenceStatus = ''Completed'') OR OccurrenceDetailsPUB.CreateDTM >= ''' 
			+ convert(VARCHAR,DATEADD(DAY, -30, @CutoffDate))+''' AND OccurrenceDetailsPUB.ModifiedDTM IS NULL'
			END 
			ELSE
			BEGIN 
				SET @WherePUB = @WherePUB 
				+ ' AND Convert(VARCHAR,OccurrenceDetailsPUB.FK_MediaTypeID) ='''
				+ Convert(VARCHAR, @search_term) +''' AND (OccurrenceDetailsPUB.ModifiedDTM >= '''
				+ convert(VARCHAR,dateADD(day, -30, @CutoffDate)) + ''' OR OccurrenceDetailsPUB.CreateDTM >= '''	
				+ convert(VARCHAR,dateADD(day, -30, @CutoffDate)) + ''') AND OccurrenceDetailsPUB.ModifiedDTM IS NULL'
			END
		SET @FinalSQLStmnt = @SQLStmntCIR + @WhereCIR +  @SQLStmntPUB + @WherePUB
		Print (@FinalSQLStmnt)
		EXECUTE (@FinalSQLStmnt)
		
	END TRY

	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[Sp_ROP_NonROPAds]: %d: %s',16,1,@error,@message,@lineNo)
	END CATCH 
END