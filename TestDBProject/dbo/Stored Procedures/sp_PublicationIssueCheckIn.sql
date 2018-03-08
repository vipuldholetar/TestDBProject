-- ========================================================================================
-- Author		: Arun Nair  
-- Create date  : 01 June 2015  
-- Description  : CheckIn Data for Pub Issue 
-- Updated By	: Arun Nair on 08/19/2015 for Query Queue Changes
--				  Arun Nair on 11/27/2015 - MI-306 -For Removing Query Fields On Insert
--=========================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationIssueCheckIn] 
(
@EnvelopeID             AS INT, 
@SenderID               AS INT, 
@PubEditionID           AS INT, 
@ShippingMethodID       AS INT,    
@PkgTypeID              AS INT, 
@IssueDate              AS NVARCHAR(max), 
@TrackingNumber         AS NVARCHAR(max), 
@PrintedWeight          AS float, 
@ActualWeight           AS float, 
@PackageAssignment      AS NVARCHAR(max), 
@NoTakeReason           AS NVARCHAR(max), 
@CpnOccurrenceID        AS INT, 
@ReceiveOn              AS DATETIME, 
@ReceiveBy              AS NVARCHAR(max), 
@IssueCompleteIndicator AS BIT, 
@IssueAuditedIndicator  AS BIT, 
@Status                 AS NVARCHAR(max), 
@IsQuery                AS BIT, 
@QueryCategory          AS NVARCHAR(max), 
@QueryText              AS NVARCHAR(max), 
@QryRaisedBy            AS NVARCHAR(max), 
@QryRaisedOn            AS DATETIME, 
@QueryAnswer            AS NVARCHAR(max), 
@QryAnsweredBy          AS NVARCHAR(max), 
@QryAnsweredOn          AS DATETIME, 
@AuditBy                AS NVARCHAR(max), 
@AuditDTM               AS NVARCHAR(max), 
@CreateDTM              AS DATETIME, 
@CreateBy               AS INT, 
@ModifiedDTM            AS DATETIME,
@ModifiedBy             AS INT,
@AssignedTo				AS INT,
@FileType				AS NVARCHAR(MAX)
) 
AS 
  IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 

          BEGIN TRANSACTION

          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
		  DECLARE @pubissuedate as Date
		  DECLARE @PubIssueId AS INT 
          DECLARE @PubIssueStatus AS NVARCHAR(max) 
		  declare @PubIssueIdList as nvarchar(100)
		  declare @PubQuery as nVarchar(MAX)
		  declare @PubIssueIDValue as nvarchar(15)

		    CREATE TABLE #pubissueId 
				( 
				   rowid        INT IDENTITY(1, 1), 
				   issueId  nvarchar(20)
				) 

			  CREATE TABLE #pubissuedates 
				( 
				   rowid        INT IDENTITY(1, 1), 
				   issuedate date 
				) 
			  INSERT INTO #pubissuedates 
			  SELECT * FROM   Splitstring(@issuedate, ',') 

          SELECT @NumberRecords = Count(*)  FROM   #pubissuedates 
          SET @RowCount = 1 
          WHILE @RowCount <= @NumberRecords 
            BEGIN 
				SELECT @pubissuedate = issuedate FROM   #pubissuedates WHERE  rowid = @RowCount 

                INSERT INTO [dbo].[pubissue] 
                            ([EnvelopeID], 
                             [SenderID], 
                             [PubEditionID], 
                             [ShippingMethodID], 
                             [PackageTypeID], 
                             [issuedate], 
                             [trackingnumber], 
                             [printedweight], 
                             [actualweight], 
                             [packageassignment], 
                             [notakereason], 
                             [cpnoccurrenceid], 
                             [receiveon], 
                             [receiveby], 
                             [issuecompleteindicator], 
                             [issueauditedindicator], 
                             [status], 
                             [isquery],                             
                             [auditby], 
                             [auditdtm], 
                             [createdtm], 
                             [createby], 
                             [modifieddtm], 
                             [modifiedby]) 
                VALUES      ( @EnvelopeID, 
                              @SenderID, 
                              @PubEditionID, 
                              @ShippingMethodID, 
                              @PkgTypeID, 
                              @pubissuedate, 
                              @TrackingNumber, 
                              @PrintedWeight, 
                              @ActualWeight, 
                              @PackageAssignment, 
                              @NoTakeReason, 
                              @CpnOccurrenceID, 
                              @ReceiveOn, 
                              @ReceiveBy, 
                              @IssueCompleteIndicator, 
                              @IssueAuditedIndicator, 
                              @Status, 
                              @IsQuery,
                              @AuditBy, 
                              @AuditDTM, 
                              @CreateDTM, 
                              @CreateBy, 
                              @ModifiedDTM, 
                              @ModifiedBy
						    ) 
							
					set @PubIssueIDValue = CAST(Scope_identity() AS nvarchar)
					 
					  INSERT INTO #pubissueId(issueId) values( @PubIssueIDValue)
								  								  
								
                IF ( @RowCount = 1 ) 
					  BEGIN 
						  SET @PubIssueId=Scope_identity(); 
					  END 

					  ---Update PubissueId For Query 
					  DECLARE @PubIssueQry AS INT 
					  DECLARE @QueryId AS INT
					  DECLARE @QueryPath AS NVARCHAR(100)
				      DECLARE @QueryDetailFolder AS NVARCHAR(100)='Query'
				      DECLARE @QueryAssetname AS NVARCHAR(100)

					  SET @PubIssueQry =Scope_identity(); 
						IF(@IsQuery=1) 
							BEGIN
								INSERT INTO [dbo].[QueryDetail]
								(
									[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
									[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
									[CreatedDT],[CreatedByID],[AssignedToID]
								)
								VALUES
								(
									NULL,NULL,@PubIssueQry,NULL,NULL,'PUB','I&O','PUB',@QueryCategory,@QueryText,@QryRaisedBy,getdate(),NULL,NULL,NULL,NULL,getdate(),@CreateBy,@AssignedTo
								)  
								Set @QueryId=Scope_identity();
								IF(@FileType<>'')
								BEGIN
									SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
									SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'
									UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
									--SELECT PK_QueryID,QryCreativeRepository,QryCreativeAssetName FROM QueryDetails WHERE PK_QueryID=@QueryId
								END

							END

					SET @RowCount=@RowCount + 1 
            END 
			drop table #pubissuedates
          COMMIT TRANSACTION 

		    SELECT @PubIssueIdList = ISNULL(@PubIssueIdList + ',' + issueId , issueId) FROM #pubissueId

     --  set @PubQuery ='  SELECT [dbo].[pubissue].[PubIssueID], 
     --            [dbo].[pubissue].[EnvelopeID], 
     --            [dbo].[pubissue].[SenderID], 
     --            [dbo].[pubissue].[PubEditionID], 
     --            [dbo].[pubissue].[ShippingMethodID], 
     --            [dbo].[pubissue].[PackageTypeID], 
     --            [dbo].[pubissue].[issuedate], 
     --            [dbo].[pubissue].[trackingnumber], 
     --            [dbo].[pubissue].[printedweight], 
     --            [dbo].[pubissue].[actualweight], 
     --            [dbo].[pubissue].[packageassignment], 
     --            [dbo].[pubissue].[notakereason], 
     --            [dbo].[pubissue].[cpnoccurrenceid], 
     --            [dbo].[pubissue].[receiveon], 
     --            [dbo].[pubissue].[receiveby], 
     --            [dbo].[pubissue].[issuecompleteindicator], 
     --            [dbo].[pubissue].[issueauditedindicator], 
     --            [dbo].[pubissue].[status], 
     --            [dbo].[pubissue].[isquery], 
     --            [dbo].[pubissue].[querycategory], 
     --            [dbo].[pubissue].[querytext], 
     --            [dbo].[pubissue].[qryraisedby], 
     --            [dbo].[pubissue].[qryraisedon], 
     --            [dbo].[pubissue].[queryanswer], 
     --            [dbo].[pubissue].[qryansweredby], 
     --            [dbo].[pubissue].[qryansweredon], 
     --            [dbo].[pubissue].[auditby], 
     --            [dbo].[pubissue].[auditdtm], 
     --            [dbo].[pubissue].[createdtm], 
     --            [dbo].[pubissue].[createby], 
     --            [dbo].[pubissue].[modifieddtm], 
     --            [dbo].[pubissue].[modifiedby] ,
				 --[dbo].[QueryDetail].[QueryID],
				 --[dbo].[QueryDetail].QryCreativeRepository,
				 --[dbo].[QueryDetail].QryCreativeAssetName
     --     FROM   [dbo].[pubissue] LEFT JOIN [dbo].[QueryDetail] ON [dbo].[QueryDetail].[PubIssueID]= [dbo].[pubissue].[PubIssueID]
     --     WHERE  pubissue.[PubIssueID] in (' + @PubIssueIdList + ')'

	      set @PubQuery ='  SELECT [dbo].[pubissue].[PubIssueID],[EnvelopeID],[SenderID],[PubEditionID], [ShippingMethodID], [PackageTypeID],[issuedate],[trackingnumber], '
          set @PubQuery = @PubQuery + '[printedweight], [actualweight], [packageassignment],[notakereason], [cpnoccurrenceid],[receiveon], [receiveby], [issuecompleteindicator],' 
          set @PubQuery = @PubQuery + '[issueauditedindicator], [status], [isquery],pubissue.[querycategory], pubissue.[querytext],pubissue.[qryraisedby], pubissue.[qryraisedon], 
                 pubissue.[queryanswer], 
                 pubissue.[qryansweredby], 
                 pubissue.[qryansweredon], 
                 pubissue.[auditby], 
                 pubissue.[auditdtm], 
                 pubissue.[createdtm], 
                 pubissue.[createby], 
                 pubissue.[modifieddtm], 
                 pubissue.[modifiedby] ,
				 [dbo].[QueryDetail].[QueryID],
				 [dbo].[QueryDetail].QryCreativeRepository,
				 [dbo].[QueryDetail].QryCreativeAssetName
          FROM   [dbo].[pubissue] LEFT JOIN [dbo].[QueryDetail] ON [dbo].[QueryDetail].[PubIssueID]= [dbo].[pubissue].[PubIssueID]
          WHERE  pubissue.[PubIssueID] in (' + @PubIssueIdList + ')'


		  EXEC(@PubQuery)

          drop table #pubissueId

      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('sp_PublicationIssueCheckIn: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END