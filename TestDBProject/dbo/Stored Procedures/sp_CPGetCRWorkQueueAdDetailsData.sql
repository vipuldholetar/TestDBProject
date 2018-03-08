CREATE PROCEDURE [dbo].[sp_CPGetCRWorkQueueAdDetailsData] -- [sp_CPGetCRWorkQueueAdDetailsData] 'Advertiser1','2015-10-1','2015-10-30','29712030',0,'',0
	-- Add the parameters for the stored procedure here
	@Advertiser nvarchar(max),
	@AdDateFrm nvarchar(250),
	@AdDateTo	nvarchar(250),
	@UserID nvarchar(50),
	@Include int,
	@AdOccurID nvarchar(50),
	@AdOccurStatus int,
	@MediaType nvarchar(max)
AS
BEGIN
	--BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
				DECLARE @Stmnt AS NVARCHAR(4000)='' 				
				DECLARE @SelectStmnt AS NVARCHAR(max)='' 
				DECLARE @Where AS NVARCHAR(max)='' 				
				DECLARE @Orderby AS NVARCHAR(max)=''				
				DECLARE @AdID AS INT
				DECLARE @MediaVal nvarchar(max)
				SELECT @MediaVal=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaType
				BEGIN TRY
					
					--SET @SelectStmnt='	Select [Priority],
					--	RecordID,
					--	Advertiser,
					--	FirstRunDate,
					--	CommonAdDate,
					--	IndustryGroup,
					--	Market,
					--	CONCAT(LastUpdatedBy ,SPACE(1), LastUpdatedOn) AS LastUpdatedBy,
					--	[Language],
					--	CONCAT((select DISTINCT a.FNAME from [User] a,vw_CropRouteWorkQueueMainData b where a.UserID=b.CompletedBy) ,SPACE(1), CompletedOn) AS CompletedOn,
					--	OccurrenceID,(select DISTINCT a.ValueTitle from CONFIGURATIONMASTER a,vw_CropRouteWorkQueueMainData b where a.Value=b.MediaStream) as MediaStream,
					--	CONCAT((CreateBy) ,SPACE(1), CreateOn) AS CreateOn,AdID
					--	 from vw_CropRouteWorkQueueMainData '					

					SET @SelectStmnt='	Select DISTINCT a.[Priority],
						a.RecordID,
						a.Advertiser,
						a.FirstRunDate,
						a.CommonAdDate,
						a.IndustryGroup,
						a.Market,
						CONCAT(e.fname+'' ''+e.LNAME ,SPACE(1), a.LastUpdatedOn) AS LastUpdatedBy,
						a.[Language],
						CONCAT(c.fname+'' ''+c.LNAME ,SPACE(1), CompletedOn) AS CompletedOn,
						OccurrenceID,b.ValueTitle as MediaStream,
						CONCAT(d.fname+'' ''+d.LNAME ,SPACE(1), CreateOn) AS CreateOn,AdID
						 from vw_CropRouteWorkQueueMainData a Left JOIN CONFIGURATION b ON b.Value=a.MediaStream Left JOIN [User] c ON c.UserID=a.CompletedBy
						 Left JOIN [User] d ON d.UserID=a.CreateBy Left JOIN [User] e ON e.UserID=a.LastUpdatedBy '
					
					SET @Where=' where 1=1 and cast(CommonAdDate as date) Between  ''' + convert(varchar,cast(@AdDateFrm as date),101) + ''' and  ''' 	+ convert(varchar,cast(@AdDateTo as date),101) + '''' 
					--' WHERE CommonAdDate>='''+CONVERT(VARCHAR, @AdDateFrm, 110)+''' AND CommonAdDate<= '''+CONVERT(VARCHAR, @AdDateTo, 110)+''''
					--+'' '' +a.LNAME  CONCAT((select DISTINCT a.FNAME from [User] a,vw_CropRouteWorkQueueMainData b where a.UserID=b.CreateBy) ,SPACE(1), CreateOn) AS CreateOn,
					--+'' ''+a.LNAME
					IF(@Advertiser<>'' AND @Advertiser<>'ALL')
					BEGIN
					   SET @Where= @Where +' AND [Advertiser]='''+Convert(NVARCHAR(MAX),@Advertiser)+''''
					END

					IF(@UserID<> '0')
					BEGIN
						SET @Where=  @Where + ' AND [CreateBy]='+Convert(NVARCHAR(MAX),@UserID)+''
					END

					IF(@Include=0)
					BEGIN
						SET @Where=  @Where + ' AND ([CompletedBy] IS NULL OR [CompletedBy] = 0)'
					END

					IF(@AdOccurID IS NOT NULL AND @AdOccurID <> '')
					BEGIN
						--
						IF(@AdOccurStatus=1)
							BEGIN
								IF EXISTS(Select * from vw_CropRouteWorkQueueMainData WHERE OccurrenceID=@AdOccurID)
									BEGIN
										SET @AdID = (Select AdID from vw_CropRouteWorkQueueMainData WHERE OccurrenceID=@AdOccurID AND MediaStream=@MediaVal)
										--select @AdID
										SET @Where =  @Where + ' AND [AdID]='+CONVERt(VARCHAR(MAX),@AdID)+' AND [OccurrenceID]='+Convert(VARCHAR(MAX),@AdOccurID)+''
									END
								ELSE
									BEGIN
										IF EXISTS(Select * from vw_CropRouteWorkQueueMainData WHERE AdID=@AdOccurID)
										BEGIN
											SET @Where =  @Where + ' AND [AdID]='+Convert(VARCHAR(MAX),@AdOccurID)+'AND [OccurrenceID] IS NULL'
										END
									END
							END
						ELSE IF(@AdOccurStatus=0)
							BEGIN
								--IF EXISTS(Select * from vw_CropRouteWorkQueueData WHERE PK_ID=@AdOccurID)
								BEGIN
									SET @Where =  @Where + ' AND [AdID]='+Convert(VARCHAR(MAX),@AdOccurID)+'AND [OccurrenceID] IS NULL'
								END
							END
					END
					Set @Orderby = ' Order BY [Priority], FirstRunDate, CommonAdDate'

					SET @Stmnt=@SelectStmnt + @Where + @Orderby
					PRINT @Stmnt
					EXECUTE SP_EXECUTESQL @Stmnt
				END TRY
              BEGIN CATCH
                           DECLARE @error  INT,@message VARCHAR(4000),@lineNo INT 
                           SELECT  @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                           RAISERROR ('[sp_CPGetCRWorkQueueAdDetailsData]: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH

		
END