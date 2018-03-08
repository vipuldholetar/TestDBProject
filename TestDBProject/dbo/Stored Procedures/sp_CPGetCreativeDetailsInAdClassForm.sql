-- ============================================================================================================= 
-- Author    : Govardhan.R 
-- Create date  : 10/09/2015 
-- Description  : This stored procedure is used to get the CREATIVE DETAILS FOR AN AD . 
-- Execution  : [sp_CPGetCreativeDetailsInAdClassForm] 'Online Display','5239' 
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[sp_CPGetCreativeDetailsInAdClassForm] (@MediaStream AS 
NVARCHAR(max), 
                                                               @AdID        AS 
INT) 
AS 
  BEGIN 
      DECLARE @MediaStreamValue AS NVARCHAR(max) = '' 
      DECLARE @MediaStreamBasePath AS NVARCHAR(max) = '' 

      SELECT @MediaStreamValue = value 
      FROM   [dbo].[Configuration] 
      WHERE  valuetitle = @MediaStream 

      SELECT @MediaStreamBasePath = value 
      FROM   [Configuration] 
      WHERE  systemname = 'All' 
             AND componentname = 'Creative Repository' 

      BEGIN try 
          IF( @MediaStreamValue = 'RAD' ) 
            BEGIN 
                SELECT TOP 1 CD.rep + CD.assetname + '.' + filetype AS 
                             [PrimarySource] 
                             , 
                             @MediaStreamBasePath 
                             [BasePath], 
      CM.pk_id                               [CREATIVEMASTERID], 
      @MediaStreamValue                      [MediaStream] 
	  , pm.CreativeSignature
      FROM   [Creative] CM 
      INNER JOIN [CreativeDetailRA] CD 
        ON CM.pk_id = CD.[CreativeID] 
      INNER JOIN [Pattern] PM 
        ON PM.[CreativeID] = CM.pk_id 
      WHERE  CM.[AdId] = @AdID 
      AND CM.primaryindicator = 1 
      END 

          IF( @MediaStreamValue = 'TV' ) 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream] ,
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN creativedetailtv CD 
                               ON CM.pk_id = CD.creativemasterid 
				INNER JOIN [Pattern] PM 
                ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'OD' ) 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream] ,
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN creativedetailodr CD 
                               ON CM.pk_id = CD.creativemasterid 
					INNER JOIN [Pattern] PM 
							ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'CIN' ) 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN creativedetailcin CD 
                               ON CM.pk_id = CD.[CreativeMasterID] 
						INNER JOIN [Pattern] PM 
								ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'OND' ) --Online Display 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature 
                FROM   [Creative] CM 
                       INNER JOIN creativedetailond CD 
                               ON CM.pk_id = CD.[CreativeMasterID] 
						INNER JOIN [Pattern] PM 
							ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'ONV' ) --Online Video 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN creativedetailonv CD 
                               ON CM.pk_id = CD.[CreativeMasterID] 
					   INNER JOIN [Pattern] PM 
								ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'MOB' ) --Mobile 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN creativedetailmob CD 
                               ON CM.pk_id = CD.[CreativeMasterID] 
						INNER JOIN [Pattern] PM 
								ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'CIR' ) --Mobile 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN [dbo].[creativedetailcir] CD 
                               ON CM.pk_id = CD.creativemasterid 
					   INNER JOIN [Pattern] PM 
							  ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'PUB' ) --Mobile 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN [dbo].[creativedetailpub] CD 
                               ON CM.pk_id = CD.creativemasterid 
						INNER JOIN [Pattern] PM 
							  ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'WEB' ) --Web 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature
                FROM   [Creative] CM 
                       INNER JOIN [dbo].[creativedetailweb] CD 
                               ON CM.pk_id = CD.creativemasterid 
					   INNER JOIN [Pattern] PM 
							ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'SOC' ) --Social 
            BEGIN 
                SELECT CD.creativerepository 
                       + CD.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath   [BasePath], 
                       CM.pk_id               [CREATIVEMASTERID], 
                       @MediaStreamValue      [MediaStream],
					   pm.CreativeSignature 
                FROM   [Creative] CM 
                       INNER JOIN [dbo].[creativedetailsoc] CD 
                               ON CM.pk_id = CD.creativemasterid 
					   INNER JOIN [Pattern] PM 
							   ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 

          IF( @MediaStreamValue = 'EM' ) --Email 
            BEGIN 
                SELECT TOP 1 CD.creativerepository 
                             + CD.creativeassetname AS [PrimarySource], 
                             @MediaStreamBasePath   [BasePath], 
                             CM.pk_id               [CREATIVEMASTERID], 
                             @MediaStreamValue      [MediaStream],
							 pm.CreativeSignature 
                FROM   [Creative] CM 
                       INNER JOIN [dbo].[creativedetailem] CD 
                               ON CM.pk_id = CD.creativemasterid 
					INNER JOIN [Pattern] PM 
							ON PM.[CreativeID] = CM.pk_id
                WHERE  CM.[AdId] = @AdID 
                       AND CM.primaryindicator = 1 
            END 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_CPGetCreativeDetailsInAdClassForm: %d: %s',16,1,@error, 
                     @message,@lineNo) 
      END catch 
  END
