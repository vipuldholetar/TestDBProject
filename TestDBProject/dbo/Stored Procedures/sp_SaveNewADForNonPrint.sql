-- =================================================================   
-- Author            :  RP  
-- Create date       :  01/14/2016   
-- Execution		 :  [sp_SaveNewADForNonPrint]
-- Description       :  Map to AD  
-- Updated By		 :  
-- =================================================================   
CREATE PROCEDURE [dbo].[sp_SaveNewADForNonPrint]
 @leadaudioheadline AS NVARCHAR( max)='',
@leadtext AS NVARCHAR(max)='',
@visual AS NVARCHAR(max)='',
@description AS NVARCHAR(max)='',
@advertiser AS INT=0,
@taglineid AS NVARCHAR(max)=Null, 
@languageid AS INT=0,
@commondaddate AS DATETIME,
@internalnotes AS NVARCHAR(max)= '',
@notakereason AS INTEGER=0,
@mediastream AS INT,
@length AS INT=0, 
@creativeassetquality AS INT,
@tradeclass AS NVARCHAR(max)='', 
@coresupplementalstatus AS NVARCHAR(max)='',
@distributiontype AS NVARCHAR(max)= '',
@originaladid AS INT=0,
@revisiondetail AS NVARCHAR(max)='',
@firstrundate AS DATETIME,
@lastrundate AS DATETIME,
@firstrundma AS NVARCHAR(max)='',
@breakdate AS DATETIME,
@startdate AS DATETIME,
@enddate AS DATETIME,
@sessiondate AS DATETIME, 
@isunclassified AS BIT,
@creativesignature AS NVARCHAR(max)='',
@userid AS INT,
@originaladDescription as nvarchar(max),
@originaladRecutDetail as nvarchar(max),
@MediaStreamName       VARCHAR(50)
AS 
  BEGIN 
      SET NOCOUNT ON; 

	    If @TagLineID='' 
		set @TagLineID=null

	  DECLARE @MediaStreamValue As NVARCHAR(50)
	  SELECT @MediaStreamValue = Value FROM [Configuration] WHERE SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamName

				
      BEGIN TRY 
          IF ( @MediaStreamValue = 'RAD') 
            BEGIN 
				EXEC [Sp_RadioSaveAdDetails]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@creativesignature,@sessiondate, @isunclassified,@userid,@originaladDescription,@originaladRecutDetail               
            END 
			IF ( @MediaStreamValue = 'CIN' ) 
            BEGIN 
              EXEC [Sp_CinemaSaveAdDetails]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail       
            END 
			IF ( @MediaStreamValue = 'OD' ) 
            BEGIN 
                EXEC [Sp_OutdoorSaveAdData]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail
            END 
			IF ( @MediaStreamValue = 'TV' ) 
            BEGIN 
                  EXEC [Sp_TelevisionSaveAdDetails]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail
            END 
			IF ( @MediaStreamValue = 'OND' ) 
            BEGIN 
               	EXEC [Sp_OnlineDisplaySaveAdData]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail 
            END 
			IF ( @MediaStreamValue = 'ONV' ) 
            BEGIN 
              	EXEC [Sp_OnlineVideoSaveAdData]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail 
            END 
			IF ( @MediaStreamValue = 'MOB' ) 
            BEGIN 
                EXEC [Sp_MobileSaveAdData]
				@leadaudioheadline,@leadtext,@visual,@description,@advertiser,@taglineid, @languageid,@commondaddate,@internalnotes,@notakereason,@mediastream,
				@length, @creativeassetquality,@tradeclass, @coresupplementalstatus,@distributiontype,@originaladid,@revisiondetail,@firstrundate,@lastrundate,@firstrundma,
				@breakdate,@startdate,@enddate,@sessiondate, @isunclassified,@creativesignature,@userid,@originaladDescription,@originaladRecutDetail
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_SaveNewADForNonPrint]: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END
