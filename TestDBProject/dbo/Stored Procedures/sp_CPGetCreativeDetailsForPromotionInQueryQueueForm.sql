
-- ============================================================================================================= 
-- Author    : Govardhan.R 
-- Create date  : 10/09/2015 
-- Description  : This stored procedure is used to get the CREATIVE DETAILS FOR AN AD . 
-- Execution  : [sp_CPGetCreativeDetailsForPromotionInQueryQueueForm] 'publication','4' 
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[sp_CPGetCreativeDetailsForPromotionInQueryQueueForm] ( 
@MediaStream AS NVARCHAR(max), 
@ProID       AS INT) 
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
                SELECT CDR.rep + CDR.assetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.[CreativeID]       [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[CreativeDetailRA] CDR 
                               ON CDR.[CreativeDetailRAID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'TV' ) 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName+'.'+CreativeFileType As [PrimarySource],@MediaStreamBasePath[BasePath] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailtv] CDR 
                               ON CDR.[CreativeDetailTVID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'OD' ) 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName+'.'+CreativeFileType As [PrimarySource],@MediaStreamBasePath[BasePath] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailodr] CDR 
                               ON CDR.[CreativeDetailODRID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'CIN' ) 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.[CreativeMasterID] [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --   SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailcin] CDR 
                               ON CDR.[CreativeDetailCINID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'OND' ) --Online Display 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.[CreativeMasterID]    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailond] CDR 
                               ON CDR.[CreativeDetailONDID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'ONV' ) --Online Video 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.[CreativeMasterID] [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailonv] CDR 
                               ON CDR.[CreativeDetailONVID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'MOB' ) --Mobile 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.[CreativeMasterID]    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailmob] CDR 
                               ON CDR.[CreativeDetailMOBID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'CIR' ) --Circular 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailcir] CDR 
                               ON CDR.creativedetailid = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'PUB' ) --Publication 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailpub] CDR 
                               ON CDR.creativedetailid = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'EM' ) --Email 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailem] CDR 
                               ON CDR.[CreativeDetailsEMID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'SOC' ) --Social 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailsoc] CDR 
                               ON CDR.[CreativeDetailSOCID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 

          IF( @MediaStreamValue = 'WEB' ) --Web 
            BEGIN 
                SELECT CDR.creativerepository 
                       + CDR.creativeassetname AS [PrimarySource], 
                       @MediaStreamBasePath    [BasePath], 
                       CDR.creativemasterid    [CREATIVEMASTERID], 
                       @MediaStreamValue       [MediaStream] 
                --SELECT  CDR.CreativeRepository+CDR.CreativeAssetName As [PrimarySource],@MediaStreamBasePath[BasePath] 
                FROM   [Promotion] PM 
                       INNER JOIN creativedetailinclude CDI 
                               ON PM.[CropID] = CDI.fk_cropid 
                       INNER JOIN [dbo].[creativecontentdetail] CCD 
                               ON CCD.[CreativeContentDetailID] = CDI.fk_contentdetailid 
                       INNER JOIN [dbo].[creativedetailweb] CDR 
                               ON CDR.[CreativeDetailWebID] = CCD.[CreativeDetailID] 
                WHERE  PM.[PromotionID] = @ProID 
            END 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ( 
          'sp_CPGetCreativeDetailsForPromotionInQueryQueueForm: %d: %s' 
          ,16, 
          1,@error, 
          @message,@lineNo); 
      END catch 
  END
