/****** Object:  StoredProcedure [dbo].[sp_ReviewQueue]    Script Date: 6/14/2016 1:01:09 PM ******/
CREATE PROCEDURE  [dbo].[sp_ReviewQueue] 
(
@MediaStream AS NVARCHAR(MAX),
@Advertiser AS INT,
@Sender AS INT,
@IndexFromDT AS nvarchar(50),
@IndexToDT AS nvarchar(50),
@DisplayNoTake AS BIT,
@CreativeSignature AS NVARCHAR(MAX),
@IsAuditRecord AS int = 0
)
AS
BEGIN
		BEGIN TRY
			DECLARE @Stmnt AS NVARCHAR(4000)='' 				
			DECLARE @SelectStmnt AS NVARCHAR(max)='' 
			DECLARE @Where AS NVARCHAR(max)='' 
			DECLARE @Orderby AS NVARCHAR(max)='' 
			Declare @MedialistTemp AS NVARCHAR(MAX)=' '
			Declare @MediaPrint as nvarchar(10)='Print'
			DECLARE @AuditMediaType AS VARCHAR(MAX)

			SET @AuditMediaType = @MediaStream

			--------Make Suitable Marketlist appending single quote-------------------------------------
				SET @MediaStream=REPLACE((@MediaStream), ',' , ''',''')
				SET @MediaStream= ''''+@MediaStream+''''
				PRINT @MediaStream
				-------------------------------------------------------------------
				SET @MedialistTemp='''-1'''
				PRINT @MedialistTemp

			set @IndexFromDT=@IndexFromDT+' '+'00:00:00'
			Set @IndexToDT=@IndexToDT+' '+'23:59:59'

			Print(@IndexFromDT)
			Print(@IndexToDT)
			

			SET @Orderby=' ORDER BY MTScore,IndexedOn'

			 SET @SelectStmnt= 'SELECT [dbo].[Pattern].MediaStream AS MediaStreamID,
					 [dbo].[Advertiser].Descrip   AS Advertiser,
					 [dbo].[Pattern].CreativeSignature AS CreativeSignature,
					 [dbo].[Ad].AdID AS AdId,
					 [dbo].[Ad].PrimaryOccurrenceID AS PrimaryOccurrenceId,'
					 If @IsAuditRecord = 1 
			   Begin
					SET @SelectStmnt= @SelectStmnt +  '  [dbo].[AuditReview].Action AS Action,  '
				End

					
				SET @SelectStmnt= @SelectStmnt + 	' (Convert(VARCHAR(10),[dbo].[Pattern].CreateDate,101)) AS IndexedOn,
					  dbo.[User].fname+'' ''+ [User].lname AS IndexedBy,
					 [dbo].[Pattern].NoTakeReasonCode AS NoTakeType,
					 '' NA '' AS MTScore,
					(convert(nvarchar(max),[Pattern].[AuditDate],110)+''/''+(select dbo.[User].fname+'' ''+ [User].lname from [user] where [user].userid=[dbo].[Pattern].[AuditBy])) AS AuditedOnBy,
					 Configuration.ValueTitle as MediaStream,
					 [dbo].[Advertiser].AdvertiserID,
					 Ad.LanguageID,
					 [dbo].[Pattern].PatternID as Patternmasterid ,
					 [User].userid AS IndexedByID,
					 Language.Description As Language
               FROM  [dbo].[Pattern] 
			   Left  JOIN [dbo].[Ad] ON  [dbo].[Pattern].AdID=[dbo].[Ad].AdID
			   lEFT JOIN [dbo].[Advertiser] ON [dbo].[Advertiser].AdvertiserID=[dbo].[Ad].AdvertiserId
			   Inner Join Configuration on Pattern.MediaStream=Configuration.ConfigurationID
			   inner join [User] on [user].UserID=[dbo].[Pattern].Createby 
			   Left Join [dbo].[Language] on Ad.LanguageID=Language.LanguageID '

			   If @IsAuditRecord = 1 
			   Begin
					SET @SelectStmnt= @SelectStmnt +  ' Left Join AuditReview ON (AuditReview.OccurrenceID = Ad.PrimaryOccurrenceID OR Ad.PrimaryOccurrenceID Is NULL) '
				End

			 --SET @Where=' where (1=1) AND (([dbo].[Pattern].CreateDate >='''+@IndexFromDT+CONVERT(DATETIME,'00:00:00')+''') AND ([dbo].[Pattern].CreateDate<='''+@IndexToDT+CONVERT(DATETIME,'23:59:59')+'''))' 
			 SET @Where=' where ([Status] <> ''Miscut'') '
			   IF(@CreativeSignature <> '')
				   BEGIN
					 SET @Where=  @Where + ' AND [dbo].[Pattern].CreativeSignature='''+Convert(NVARCHAR(max), @CreativeSignature)+''''
					 SET @Where=  @Where + ' AND Configuration.ValueGroup Not IN ('''+@MediaPrint+''') '
				   END
			   ELSE
					BEGIn
					   IF(@MediaStream=@MedialistTemp)
					     BEGIN
							SET @Where=  @Where + ' AND Configuration.ValueGroup Not IN ('''+@MediaPrint+''') ' 				 							 			    
					     END
						 Else
						 BEGIN
						  SET @Where=  @Where + ' AND [dbo].[Pattern].Mediastream IN ('+@MediaStream+') ' 
						 END	
				       IF((@Advertiser<>-1))
						  BEGIN
						     SET @Where=  @Where + ' AND [dbo].[Ad].AdvertiserID='+Cast(@Advertiser AS VARCHAR)
						  END
						IF(@DisplayNoTake<>0)
						  BEGIN
						     SET @Where=  @Where + ' AND  [dbo].[Pattern].NoTakeReasonCode Is Not NULL'
						  END
						 ELSE
						   BEGIN
						     SET @Where=  @Where + ' ' -- AND  [dbo].[Pattern].NoTakeReasonCode IS NULL
						   END 	
						IF(@IndexFromDT<>'')
						BEGIN
						  SET @Where=  @Where +' AND [dbo].[Pattern].CreateDate >='''+@IndexFromDT+''''
						END
						IF(@IndexToDT<>'')
						BEGIN
						  SET @Where=  @Where +' AND [dbo].[Pattern].CreateDate <='''+@IndexToDT+''''
						END
					  END

				 If @IsAuditRecord = 1 
			   Begin
					SET @Where= @Where +  ' AND (''' + @AuditMediaType + ''' = ''-1'' or AuditReview.OccurrenceMediaType in (select id from fn_CSVToTable(''' + @AuditMediaType +'''))) '
				End


				SET @Stmnt=@SelectStmnt + @Where + @Orderby 
				PRINT @Stmnt 
				EXECUTE SP_EXECUTESQL @Stmnt  	
		END TRY

		 BEGIN CATCH 
			  DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
			  SELECT @Error = ERROR_NUMBER(),@Message = ERROR_MESSAGE(),@LineNo = ERROR_LINE() 
			  RAISERROR ('[dbo].[sp_ReviewQueue]: %d: %s',16,1,@Error,@Message,@LineNo); 
		 END CATCH 

END