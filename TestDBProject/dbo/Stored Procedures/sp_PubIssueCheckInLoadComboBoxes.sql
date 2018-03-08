-- =============================================  
-- Author		: Arun Nair  
-- Create date  : 01 June 2015  
-- Description  : LoadIntial Data for Pub Issue Combos 
-- Updated By	:  Arun Nair on 17/06/2015
--===================================================  
CREATE PROCEDURE [dbo].[sp_PubIssueCheckInLoadComboBoxes] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          ---Sender---------------------------------------------- 
          SELECT s.[SenderID], 
                 s.NAME 
          FROM   sender s
		  where exists (select 1 from SenderPublication sp where sp.SenderId = s.SenderID)
          ORDER  BY s.NAME 

          ---Publication----------------------------------------- 
          SELECT p.[PublicationID], 
                 p.descrip, comments,
                 senderpublication.[SenderID], p.MarketID, m.Descrip as Market
          FROM   [dbo].[publication] p
                 INNER JOIN senderpublication 
                         ON senderpublication.[PublicationID] = 
                            p.[PublicationID] 
			  LEFT JOIN Market m on m.MarketID=p.MarketID  ORDER BY p.descrip

          SELECT [PublicationID], 
                 p.descrip,comments, p.MarketID, m.Descrip as Market
          FROM   publication p
			  LEFT JOIN Market m on m.MarketID=p.MarketID 
          WHERE  p.[StartDT] <= Getdate() 
                 AND ( p.[EndDT] >= Getdate() 
                        OR p.[EndDT] IS NULL ) ORDER BY p.descrip

          ---Publication Edition -------------------------------- 
          SELECT [PubEditionID], 
                 [PublicationID], 
                 editionname, 
                 [DefaultInd] 
          FROM   [dbo].[pubedition]  ORDER BY editionname

          ---Shipping Company------------------------------------ 
          SELECT [ShipperID], 
                 descrip 
          FROM   shipper ORDER BY Descrip ASC


          ----Shipping Method ----------------------------------- 
          SELECT [ShippingMethodID], 
                 shipmentmethodname, 
                 [ShipperID] ,IndNeedTrackingNo,IndWeightBasedCost
          FROM   shippingmethod ORDER BY shipmentmethodname ASC

          ----Package Type -------------------------------------- 
          	SELECT distinct [PackageTypeID], 
                 packagetypename + ' (' + Shipper.Descrip + ')' packagetypename, 
                 packagetype.[ShipperID] 
          FROM   packagetype inner join Shipper on packagetype.ShipperID = Shipper.ShipperID  ORDER BY packagetypename ASC

          ---Package Assignment----------------------------------       
          SELECT userid, 
                 fname + ' ' + lname AS USERNAME 
          FROM   [user] 
          WHERE  activeind = 1 
          ORDER  BY username 
      END try 

      BEGIN catch 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_PubIssueCheckInLoadComboBoxes: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 
      END catch 
  END