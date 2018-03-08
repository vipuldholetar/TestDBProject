
--[dbo].[sp_InsertScanData]'<ScanData>
--  <OccurrenceImage ID="1" OccurrenceID="30059" CreativeMasterID="0" OldImageName="001.jpg" NewImageName="" PageNumber="1" OldPath="D:\Scantracker\30059\001.jpg" NewPath="" RecordStatus="Unprocessed" FileType="jpg" />
--  <OccurrenceImage ID="2" OccurrenceID="30059" CreativeMasterID="0" OldImageName="002.jpg" NewImageName="" PageNumber="2" OldPath="D:\Scantracker\30059\002.jpg" NewPath="" RecordStatus="Unprocessed" FileType="jpg" />
--  <OccurrenceImage ID="3" OccurrenceID="30059" CreativeMasterID="0" OldImageName="003.jpg" NewImageName="" PageNumber="3" OldPath="D:\Scantracker\30059\003.jpg" NewPath="" RecordStatus="Unprocessed" FileType="jpg" />
--</ScanData>','30059'


-- Author		: RP    

-- Create date  : May 30, 2015   

-- Description  : Process Scanned Files 

CREATE PROCEDURE [dbo].[sp_InsertScanData]
(
@parameter   AS XML,
@occurrenceID as nvarchar(max)
) 

AS 
	
  BEGIN 
  		
	  SET NOCOUNT ON ;
	  Declare @Stream as nvarchar(max)=''
	  --Declare @OccurrenceID as BigInt=0      

      BEGIN TRANSACTION 
      BEGIN TRY
			 CREATE TABLE #tempScanData 
			 (
			 ID int, 
             OccurrenceID BIGINT, 
             CreativeMasterID int, 
             OldImageName nvarchar(max), 
             NewImageName nvarchar(max), 
             PageNumber nvarchar(max), 
             OldPath nvarchar(max), 
             RecordStatus nvarchar(max), 
             FileType nvarchar(max), 
             NewPath nvarchar(max)
			 )

				  -- Read XML and insert into Temporary table  
			  --- Get Media stream of OccurrenceID
			  SET @Stream=(SELECT dbo.fn_GetMediaStream(CONVERT(BIGINT,@OccurrenceID)));
			  PRINT @OccurrenceID
			  PRINT @Stream
			  --- Call individual Scan method as per media stream
			  if @Stream='CIR'
			  begin
			  -- Execute Scan process for Circular media stream
			  insert into #tempScanData Exec [sp_CircularScanData] @parameter
			  end
			  else if @Stream='PUB'
			  begin
			  -- Execute Scan process for Publication media stream
			  insert into #tempScanData Exec [sp_PublicationScanData] @parameter
			  end
			  else if @Stream='SOC'
			  begin
			  -- Execute Scan process for Social media stream
			  insert into #tempScanData Exec [sp_SocialScanData] @parameter
			  end
			  else if @Stream='EM'
			  begin
			  -- Execute Scan process for Email media stream
			  insert into #tempScanData Exec [sp_EmailScanData] @parameter
			  end
			  else if @Stream='WEB'
			  begin
			  -- Execute Scan process for Website media stream
			  insert into #tempScanData Exec [sp_WebsiteScanData] @parameter
			  end
			  --- Return back new Image Path after insertion so that images are moved as per CreativeDetail Record
			  select * from #tempScanData
			  COMMIT TRANSACTION 

      END TRY 

      BEGIN CATCH 
          ROLLBACK TRANSACTION 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_InsertScanData: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 



  END
