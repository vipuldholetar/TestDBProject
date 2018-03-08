
-- ===========================================================================================================================   
-- Author				: KARUNAKAR   
-- Create date			: 6th October 2015   
-- Description			: This Procedure is Used to Save Mobile  Ad Data   
-- Execution Process	: Sp_MobileSaveAdData 'New Test Ad','','','',29710681,'',2,'07/13/2014','',0,150,1,91,'','','',Null,'','07/13/2014','07/13/2014','','07/13/2014','07/13/2014','07/13/2014','07/13/2014',0,'09442f2cc9d1d56d19bcbcdaa7ce690b8fae94c4',29712040   
-- Updated By			: Karunakar on 20th Oct 2015,Removing Creative File Type Check in CreativeDetailStagingMOB 
--						: Karunakar on 17th Nov 2015,Returning Generated Ad ID Value       
-- ===========================================================================================================================   
CREATE PROCEDURE [dbo].[Sp_MobileSaveAdData] 
(
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
@originaladRecutDetail as nvarchar(max)
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
 
  SET nocount ON; 
      BEGIN try 
         
          DECLARE @adid INT 
          DECLARE @occurrenceid AS BIGINT=0 
          DECLARE @creativemasterid AS INT=0 
          DECLARE @patternmasterid AS INT=0 
          DECLARE @CreativeStagingID AS INT=0 
          DECLARE @mtoreason AS VARCHAR(100) 
          DECLARE @numberrecords AS INT=0 
          DECLARE @rowcount AS INT=0 
          DECLARE @creativedetailid AS INT=0 
          DECLARE @primaryoccurrenceid AS BIGINT 
		  Declare @Patternmasterstgid as int=0

		  If @taglineid='' 
		  set @taglineid=null

		   BEGIN TRANSACTION; 
          --- Inserting data from [Ad]     
            INSERT INTO [dbo].[ad] 
                      (
					  [OriginalAdID],[PrimaryOccurrenceID],[AdvertiserID],[BreakDT],
					  [StartDT], [LanguageID], [FamilyID],
					  [CommonAdDT],[FirstRunMarketID],firstrundate, 
                       lastrundate,adname,advisual,adinfo,
					   coop1advid,coop2advid,coop3advid,comp1advid, 
                       comp2advid,taglineid,leadtext,leadavheadline,
					   recutdetail, recutadid, ethnicflag,addlinfo,
					   adlength,internalnotes,productid, description, 
                       notakeadreason,sessiondate,unclassified,createdate, 
                       createdby
					   ) 
          VALUES      ( 
						@originaladid,NULL,@advertiser,@breakdate,
						@startdate, @languageid,NULL, 
						@commondaddate,@firstrundma,@firstrundate,
						@lastrundate, NULL, @visual,NULL,
						NULL,NULL,NULL,NULL,
						NULL,@taglineid, @leadtext, @leadaudioheadline,
						@revisiondetail,NULL,0,NULL,
						@length, @internalnotes,NULL,@description,
						@notakereason, @sessiondate, @isunclassified,Getdate(),
						@userid
						) 

          SELECT @adid = Scope_identity(); 

          -- Retrieve Primary occurrence ID     
          SELECT @primaryoccurrenceid = Min([OccurrenceDetailMOB].[OccurrenceDetailMOBID]) 
          FROM   [dbo].[OccurrenceDetailMOB] 
                 INNER JOIN [CreativeStaging] 
                         ON [OccurrenceDetailMOB].CreativeSignature = 
                            [CreativeStaging].CreativeSignature 
          WHERE  [CreativeStaging].creativesignature = @creativesignature 

          IF EXISTS(SELECT 1 
                    FROM   [CreativeStaging] a 
                           INNER JOIN [PatternStaging] b 
                                   ON a.[CreativeStagingID] = b.[CreativeStgID] 
                    WHERE  a.CreativeSignature = @creativesignature
					) 
            BEGIN 
                --- Get data from [CREATIVEMASTER]     
                INSERT INTO [Creative] 
                            ([AdId],[SourceOccurrenceId],checkinoccrncs, 
                             primaryquality, 
                             primaryindicator) 
                SELECT @adid,@primaryoccurrenceid,1,@creativeassetquality,1 

                SELECT @creativemasterid = Scope_identity() 

                ---Retreive @CreativeStagingID  

				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]
                    FROM   [CreativeStaging] a 
                           INNER JOIN [PatternStaging] b 
                                   ON a.[CreativeStagingID] = b.[CreativeStgID] 
                    WHERE  a.CreativeSignature = @creativesignature

                --- Moving Data from CreativeDetailStagingMOB to [creativedetailMob]     
                INSERT INTO creativedetailMob 
                            (
							[CreativeMasterID],
							CreativeAssetName, 
                             CreativeRepository, 
                             LegacyAssetName, 
                             CreativeFileType,
							 CreativeFileSize,
							 [CreativeFileDT]
							 ) 
                SELECT	TOP 1 @creativemasterid,
						[dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingMOB].CreativeFileType, 
						CreativeRepository, 
						Null, 
                       CreativeFileType,
					   FileSize,
					   GETDATE() 
                FROM   [dbo].[CreativeDetailStagingMOB]
                WHERE  CreativeStagingID = @CreativeStagingID 
			    and CreativeDownloaded=1 and FileSize>0 
				ORDER BY CreativeDetailStagingID

                SET @creativedetailid=Scope_identity(); 
            END 

          --- Moving data from patternmasterstg to [PatternMaster]     
          INSERT INTO [Pattern] 
                      (
					  [CreativeID],[AdID],mediastream,[Exception],[Query], 
                       status, 
                       createby,createdate, 
                       modifiedby,modifydate,creativesignature,[Priority]
					   ) 
          SELECT @creativemasterid,@adid,@mediastream,[Exception],[Query], 
                 'Valid',  -- Status Value HardCoded   
                 @userid, Getdate(),
				 NULL,NULL,@creativesignature,[Priority]
          FROM   [PatternStaging] 
		  where [PatternStaging].[PatternStagingID]=@Patternmasterstgid

          SET @patternmasterid=Scope_identity(); 

          ----Update PatternMasterID and Ad into [dbo].[OccurrenceDetailsMOB]  Table       
          UPDATE [dbo].[OccurrenceDetailMOB] 
          SET    [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null
          WHERE  CreativeSignature=@creativesignature

          -- Update Occurrenceid in Ad Table     
          UPDATE ad 
          SET    [PrimaryOccurrenceID] = @primaryoccurrenceid 
          WHERE  [AdID] = @adid 
                 AND [PrimaryOccurrenceID] IS NULL 
			

		--Returning Generated Ad ID Value
					IF EXISTS(SELECT 1 FROM  ad where ad.[AdID]=@AdID) 
					BEGIN 
					SELECT @AdID AS AdId
					END
   
          --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster                  
          EXEC [dbo].[sp_MobileDeleteStagingRecords]   @CreativeStagingID 
	 Commit Transaction  
			   
      END try 
      BEGIN catch 
          DECLARE @error   INT,@message VARCHAR(4000), @lineno  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line()
          RAISERROR ('Sp_MobileSaveAdData: %d: %s',16,1,@error,@message,@lineno );
		  ROLLBACK TRANSACTION; 		
      END catch 	  
  END