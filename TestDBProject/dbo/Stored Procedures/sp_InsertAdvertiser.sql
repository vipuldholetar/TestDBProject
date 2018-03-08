CREATE PROCEDURE [dbo].[sp_InsertAdvertiser] (
	@Descrip varchar(100),--name
	@ShortName varchar(50), --new?
	@LanguageID int,
	@ParentAdvertiserID int,
	@TradeClassID int,
	@WWTIndustryID int,
	@StartDT datetime, --new? mentioned in Slack
	@EndDT datetime,
	@Comments varchar(250),
	@CreatedByID int,
	@CTLegacyINSTCOD varchar(50)='',
	@state varchar(2)=null,
	@AdvertiserID int out

)
AS
begin
SET XACT_ABORT OFF;
 BEGIN TRY 
         
			insert into Advertiser (
				Descrip, --Name,
				ShortName,
				LanguageID,
				ParentAdvertiserID,
				TradeClassID,
				IndustryID,
				StartDT,
				EndDT,
				AdvertiserComments,
				CreatedByID,
				CTLegacyINSTCOD,
				[State]
			)
			values (
				@Descrip,
				@ShortName,
				@LanguageID,
				@ParentAdvertiserID,
				@TradeClassID,
				@WWTIndustryID,
				@StartDT,
				@EndDT,
				@Comments,
				@CreatedByID,
				NULLIF(@CTLegacyINSTCOD, ''),
				NULLIF(UPPER(@state),'')
			)

			select @AdvertiserID = SCOPE_IDENTITY()

			--insert WWT join record
					insert into WWTIndustryAdvertiser
					values (
						@WWTIndustryId,
						@AdvertiserID
					)

					--insert take count
					if @LanguageID = 0 begin
						select @LanguageID = LanguageID from [Language] where [Description] = 'English'
					end
					insert into AdvertiserTakeCount
					values (
						@wwtIndustryID,
						@AdvertiserID,
						'',
						'',
						@LanguageID,
						0
					)
 END TRY 

	BEGIN CATCH 
		DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_InsertAdvertiser]: %d: %s',16,1,@error,  @message ,@lineNo); 		
	END CATCH 
END