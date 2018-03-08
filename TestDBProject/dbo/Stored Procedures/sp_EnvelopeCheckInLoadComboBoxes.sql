
-- =============================================  
-- Author		: Arun Nair  
-- Create date  : 24 June 2015  
-- Description  : This Procedure is used to getting data from sender ,shipper,shippingmethod and user Info
-- Execution	: sp_EnvelopeCheckInLoadComboBoxes
-- Updated By	: Karunakar on 7th Sep 2015
--===================================================  
CREATE PROCEDURE [dbo].[sp_EnvelopeCheckInLoadComboBoxes] 
AS 
  BEGIN 
      SET NOCOUNT ON; 
      BEGIN TRY 
          ---Sender---------------------------------------------- 
          SELECT [SenderID],NAME FROM   sender ORDER  BY NAME 

          ---Shipping Company------------------------------------ 
          SELECT [ShipperID],descrip FROM   shipper ORDER BY Descrip ASC


          ----Shipping Method ----------------------------------- 
          SELECT [ShippingMethodID],shipmentmethodname,[ShipperID] ,IndNeedTrackingNo,IndWeightBasedCost FROM   shippingmethod ORDER BY shipmentmethodname ASC

          ----Package Type -------------------------------------- 
          SELECT [PackageTypeID],packagetypename,[ShipperID] FROM   packagetype ORDER BY packagetypename ASC

          ---Package Assignment----------------------------------       
          SELECT userid,fname + ' ' + lname AS USERNAME FROM   [user] WHERE  activeind = 1 ORDER  BY username 

      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_EnvelopeCheckInLoadComboBoxes: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END
