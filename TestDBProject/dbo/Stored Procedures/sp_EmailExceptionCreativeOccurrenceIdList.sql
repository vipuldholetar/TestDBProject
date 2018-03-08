

-- ====================================================================================================================== 
-- Author			: Karunakar
-- Create date		: 06th July 2015
-- Description		: This Procedure is Used to Mapping  on Ad to CreativeSignature
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--					  Arun Nair on 10/12/2015 - Append Description with MODReason
--					:Mark Marshall modify to make update for staging Tables
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailExceptionCreativeOccurrenceIdList] 
(

 @Adid              INT, 
 @UserID            AS INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

          DECLARE @SingleOccurrenceID AS INT=0 
		  DECLARE @RecordsCount AS INTEGER
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0           
          DECLARE @NumberRecords AS INT=0 
          DECLARE @RowCount AS INT=0 
          DECLARE @MediaStream AS INT=0 
		  DECLARE @Counter AS INTEGER
		  Declare @PrimaryParentOccurrenceID as NVARCHAR(Max)

          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Email' 

          PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

 
	   DECLARE @TableOccurrence
				TABLE (			
						ID INT IDENTITY(1,1),			
						OccurrenceIDTemp NVARCHAR(MAX) NOT NULL
					  )	

			    INSERT INTO @TableOccurrence(OccurrenceIDTemp)
				SELECT OccurrenceDetailEMID From [dbo].[OccurrenceDetailEM] where AdID =@Adid


				SET @PrimaryParentOccurrenceID=(SELECT OccurrenceIDTemp from @TableOccurrence WHERE ID=1)

			
				SELECT * from @TableOccurrence
				SELECT @RecordsCount =Count(OccurrenceIDTemp) FROM @TableOccurrence		

				SET @Counter=1
				WHILE @Counter<=@RecordsCount
					BEGIN 
						SELECT @SingleOccurrenceID=OccurrenceIDTemp FROM @TableOccurrence WHERE ID =@Counter
												 

						 exec [dbo].[sp_EmailOccurrenceMarkAsException] @OccurrenceId =@SingleOccurrenceID,@IsException =1,@ExceptionType ='UI',@UserId=@UserID,@AssignedTo = null
						 

		  			   SET @Counter=@Counter+1
					END	
					
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_EmailExceptionCreativeOccurrenceIdList]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END