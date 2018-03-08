
-- =============================================
-- Author		:   Murali Jaganathan
-- Create date	:	17/06/2015
-- Description	:   Load Publication Review Queue
-- Updated By	:
--===================================================
CREATE PROCEDURE  [dbo].[sp_PublicationReviewQueue] 
(
@AdDate AS  VARCHAR(50)='',
@UserID AS INT,
@MarketID AS INT,
@EXPECTEDFORAUDIT AS BIT
)
AS
BEGIN
		SET NOCOUNT ON;--Load Publish Review Queue Data	

				DECLARE @Stmnt AS NVARCHAR(max)='' 
				DECLARE @SelectStmnt AS NVARCHAR(max)='' 
				DECLARE @Where AS NVARCHAR(max)=''      
				DECLARE @Orderby AS NVARCHAR(max)='' 

		BEGIN TRY
				
					IF(@EXPECTEDFORAUDIT=1)
						BEGIN
							--Change 0.1 to required Value to change Total Value Records Taken By Auditor

							DECLARE @AuditCount AS INTEGER
							DECLARE @AuditRecords AS INTEGER
							SELECT @AuditCount=Count(*) FROM [dbo].[vw_PublicationReviewQueue]
							SET @AuditRecords= @AuditCount*0.1

							SET @SelectStmnt ='SELECT TOP '+CONVERT(VARCHAR,@AuditRecords)+'PUBISSUEID, ISSUEDATE,ISSUECOMPLETE, ISSUEAUDITED, ISSUESTATUS, QUERYCATEGORY, 
							QUERYTEXT,QUERYANSWER,PUBLICATION, PRIORITY,PUBCOMMENTS,SENDER, MARKET ,(AuditBy +''/''+ AuditDTM) AS AuditedByOn FROM [dbo].[vw_PublicationReviewQueue]'
						END	
					ELSE
						BEGIN
							SET @SelectStmnt ='SELECT PUBISSUEID, ISSUEDATE,ISSUECOMPLETE, ISSUEAUDITED, ISSUESTATUS, QUERYCATEGORY, 
							QUERYTEXT,QUERYANSWER,PUBLICATION, PRIORITY,PUBCOMMENTS,SENDER, MARKET ,(AUDITBY +''/''+ AUDITDTM) AS AuditedByOn FROM [dbo].[vw_PublicationReviewQueue]'
						END

				SET @Orderby=' ORDER BY Priority DESC, PUBLICATION,ISSUEDATE, PUBISSUEID'

				SET @Where=' WHERE (1=1) and ISQUERY<>-1'

				IF(@AdDate <> '')
					BEGIN
						SET @Where =@Where + ' AND ISSUEDATE ='''  + convert(VARCHAR,cast(@AdDate as DATE),110) + ''''
					END

				IF(@UserID <> -1)
					BEGIN
						SET @Where =@Where + ' AND MODIFIEDBY ='''+Convert(VARCHAR,@UserID)+''' AND MODIFIEDBY IS NOT NULL'
					END

				IF(@MarketID <> -1)
					BEGIN
						SET @Where =@Where + ' AND MARKETID ='''+Convert(VARCHAR,@MarketID)+''' AND MARKETID IS NOT NULL '
					END

			
					
				SET @Stmnt=@SelectStmnt + @Where + @Orderby
				PRINT @Stmnt 
				EXECUTE Sp_executesql @Stmnt 
		END TRY

		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_PublicationReviewQueue]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH


END