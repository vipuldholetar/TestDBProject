-- ====================================================================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   01/19/2016  
-- Description           :   This stored procedure is used to Get Data for " Envelope Page Count " Report Dataset
-- Execution Process     : [dbo].[Sp_EnvelopePageCount]  '1,10,13142'  
-- Updated By            :   
-- =============================================================================================================
CREATE PROCEDURE [dbo].[Sp_EnvelopePageCount] 
(
@EnvelopeId varchar(max)
) 
AS 
IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
   
  BEGIN 
      SET NOCOUNT ON; 
	  	  
      BEGIN TRY
		  IF Object_id('tempdb..#Envelopepagecount') IS NOT NULL 
			DROP TABLE #Envelopepagecount 
			Create table #Envelopepagecount
			(
			 OccurrenceID int,		
			 [PageCount] int
			)
			DECLARE @FinalSQLStmnt AS NVARCHAR(MAX)
			DECLARE @EnvelopeIdTemp AS VARCHAR(MAX)
		  SET @EnvelopeId =Replace(( @EnvelopeId ), ',', ''',''') 
		  SET @EnvelopeId= ''''+@EnvelopeId+''''
		  SET @EnvelopeIdTemp='''-1'''

	------------------------Circular-----------------------------------------------------------

			 
			DECLARE @WhereCIR  AS VARCHAR(MAX)
			DECLARE @SQLStmntCIR AS VARCHAR(MAX)
			DECLARE @GroupByCIR AS VARCHAR(MAX)
			
			

		SET  @SQLStmntCIR = 'SELECT PK_OccurrenceID, COUNT(*) as [PageCount] FROM OccurrenceDetailsCIR 
							  Inner Join PatternMaster 
							  ON PatternMaster.PK_Id = OccurrenceDetailsCIR.FK_PatternMasterID 
						      Inner Join CreativeDetailCIR 
							  ON CreativeDetailCIR.CreativeMasterID = PatternMaster.FK_CreativeId '
	
		SET @WhereCIR= ' Where 1=1 '

		IF ( @EnvelopeId <> @EnvelopeIdTemp ) 
		 BEGIN 
			 SET @WhereCIR = @WhereCIR + ' AND Convert(varchar (max),OccurrenceDetailsCIR.FK_EnvelopeID) 
			 IN ('+@EnvelopeID+') 
			 AND OccurrenceDetailsCIR.OccurrenceStatus <> ''No Take'' 
			 AND PatternMaster.PK_Id = OccurrenceDetailsCIR.FK_PatternMasterID 
			 AND CreativeDetailCIR.Deleted = 0' 
		 END 
		SET  @GroupByCIR=' GROUP BY OccurrenceDetailsCIR.PK_OccurrenceID UNION '
	
	------------------------Email----------------------------------------------------------------

	         
			DECLARE @WhereEmail  AS VARCHAR(MAX)
			DECLARE @SQLStmntEmail AS VARCHAR(MAX)
			DECLARE @GroupByEmail AS VARCHAR(MAX)

			SET  @SQLStmntEmail ='SELECT OccurrenceDetailsEM.PK_Id, COUNT(*) as [PageNumber] 
			FROM OccurrenceDetailsEM
			 Inner Join  PatternMaster ON PatternMaster.PK_Id = OccurrenceDetailsEM.FK_PatternMasterID
             Inner Join CreativeDetailEM ON CreativeDetailEM.CreativeMasterID = PatternMaster.FK_CreativeId'

           SET @WhereEmail= ' Where 1=1'
		   IF ( @EnvelopeId <> @EnvelopeIdTemp )
		   BEGIN 
			 SET @WhereEmail = @WhereEmail + ' AND convert(varchar (max),OccurrenceDetailsEM.FK_EnvelopeID) 
			 = '+@EnvelopeID+'
             AND OccurrenceDetailsEM.OccurrenceStatus <> ''No Take''
             AND PatternMaster.PK_Id = OccurrenceDetailsEM.FK_PatternMasterID
             AND CreativeDetailEM.Deleted = 0 '
			 END
			SET  @GroupByEmail=' Group By OccurrenceDetailsEM.PK_Id UNION  '
  ------------------------Social----------------------------------------------------------------
               
			  DECLARE @WhereSocial  AS VARCHAR(MAX)
			  DECLARE @SQLStmntSocial AS VARCHAR(MAX)
			  DECLARE @GroupBySocial AS VARCHAR(MAX)

			  SET @SQLStmntSocial = 'SELECT PK_OccurrenceID, COUNT(*) as [PageNumber] 
			  FROM OccurrenceDetailsSOC
              Inner Join  PatternMaster  ON PatternMaster.PK_Id = OccurrenceDetailsSOC.FK_PatternMasterID
              Inner Join CreativeDetailSOC ON CreativeDetailSOC.CreativeMasterID = PatternMaster.FK_CreativeId'
			   SET @WhereSocial= ' Where 1=1'
			   IF ( @EnvelopeId <> @EnvelopeIdTemp )
			   BEGIN 
			 SET @WhereSocial = @WhereSocial + ' AND convert(varchar (max),OccurrenceDetailsSOC.FK_EnvelopeID)
			 = '+@EnvelopeID+'
            AND OccurrenceDetailsSOC.OccurrenceStatus <> ''In Progress''
            AND PatternMaster.PK_Id = OccurrenceDetailsSOC.FK_PatternMasterID
            AND CreativeDetailSOC.Deleted = 0'
			   END
			 SET  @GroupBySocial=' Group By OccurrenceDetailsSOC.PK_OccurrenceID UNION '
  ------------------------Website----------------------------------------------------------------
              DECLARE @WhereWebsite  AS VARCHAR(MAX)
			  DECLARE @SQLStmntWebsite AS VARCHAR(MAX)
			  DECLARE @GroupByWebsite AS VARCHAR(MAX)
     
	    SET @SQLStmntWebsite = 'SELECT OccurrenceDetailsWEB.PK_Id, COUNT(*) as [PageNumber] 
		FROM OccurrenceDetailsWEB
        Inner Join  PatternMaster ON PatternMaster.PK_Id = OccurrenceDetailsWEB.FK_PatternMasterID
        Inner Join CreativeDetailweb ON OccurrenceDetailsWEB.FK_PatternMasterID = PatternMaster.PK_Id'

		SET @WhereWebsite = ' Where 1 = 1'
		IF ( @EnvelopeId <> @EnvelopeIdTemp )
		BEGIN
		SET @WhereWebsite = @WhereWebsite + ' AND convert(varchar (max),OccurrenceDetailsWEB.FK_EnvelopeID) 
		= '+@EnvelopeID+'
        AND OccurrenceDetailsWEB.OccurrenceStatus <> ''No Take''
        AND PatternMaster.PK_Id = OccurrenceDetailsWEB.FK_PatternMasterID 
        AND CreativeDetailweb.Deleted = 0'
		END
		SET @GroupByWebsite = ' Group By OccurrenceDetailsWEB.PK_Id UNION '
 ------------------------Publication----------------------------------------------------------------
             DECLARE @WherePublication AS VARCHAR(MAX)
			 DECLARE @SQLStmntPublication AS VARCHAR(MAX)
			 DECLARE @GroupByPublication AS VARCHAR(MAX)


		 SET @SQLStmntPublication = 'SELECT PK_OccurrenceID, COUNT(*) as [PageCount] FROM OccurrenceDetailsPUB 
         Inner Join Patternmaster ON  Patternmaster.PK_Id = OccurrenceDetailsPUB.FK_PatternMasterID
         Inner Join  CreativeDetailPUB ON  CreativeDetailPUB.CreativeMasterID = Patternmaster.FK_CreativeId
		 Inner Join PubIssue ON PubIssue.PK_PubIssueID = OccurrenceDetailsPUB.FK_PubIssueID'

		 SET @WherePublication = ' Where 1 = 1'
		 IF ( @EnvelopeId <> @EnvelopeIdTemp )
		 BEGIN
		 SET @WherePublication = @WherePublication + ' AND convert(varchar(max), PubIssue.FK_EnvelopeID) 
		 = '+@EnvelopeID+'
         AND PubIssue.NoTakeReason IS NULL AND OccurrenceDetailsPUB.OccurrenceStatus <> ''No Take''
         AND CreativeDetailPUB.Deleted = 0'
		 END
		 SET @GroupByPublication  = ' Group By OccurrenceDetailsPUB.PK_OccurrenceID'


	  SET @FinalSQLStmnt    =    @SQLStmntCIR + @WhereCIR + @GroupByCIR + 
								 @SQLStmntEmail + @WhereEmail + @GroupByEmail +
								 @SQLStmntSocial + @WhereSocial + @GroupBySocial + 
								 @SQLStmntWebsite + @WhereWebsite + @GroupByWebsite +
								 @SQLStmntPublication + @WherePublication + @GroupByPublication 
	   PRINT @FinalSQLStmnt

	   Insert into #Envelopepagecount 
	   EXECUTE Sp_executesql @FinalSQLStmnt
       
	   select OccurrenceID , [PageCount]  from  #Envelopepagecount order by [PageCount] 
	END TRY 
	BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
        SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
        RAISERROR ('[Sp_EnvelopePageCount]: %d: %s',16,1,@error,@message,@lineNo); 
    END CATCH 
END