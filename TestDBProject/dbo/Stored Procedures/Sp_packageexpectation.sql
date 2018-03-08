-- ====================================================================================================================================
-- Author                :   Ganesh Prasad  
-- Create date           :   01/19/2016  
-- Description           :   This stored procedure is used to Get Data for "Package Expectation - Package Received" Report Dataset
-- Execution Process     : [dbo].[sp_PackageExpectation]  '2/1/2016','2/29/2016', '-1','-1','Jamaica, New York'  
-- Updated By            :   
-- =====================================================================================================================================
CREATE PROCEDURE [dbo].[Sp_packageexpectation] (@DateFrom VARCHAR(max),@DateTo 
VARCHAR(max),@Sender VARCHAR(max),@Market VARCHAR(max),@Location VARCHAR (max)) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
          IF Object_id('tempdb..#temporaryPackage') IS NOT NULL 
            DROP TABLE #temporarypackage 

          ----- Creating Temporary table to store the result set generated from Dyanmic Sql statement  
          CREATE TABLE #temporarypackage 
            ( 
               envelopeid INT,[week] VARCHAR(50),senderid INT, 
               sender VARCHAR(max), 
               recievedby VARCHAR(max),userlocation VARCHAR(max), 
               location VARCHAR(max) 
               , 
               reciveddate DATETIME,shippingcompany VARCHAR(100), 
               shippingmethod VARCHAR(100),trackingnumber VARCHAR(100), 
               printedweight INT, 
               actualweight INT,marketcode INT,market VARCHAR(max), 
               locationid INT, 
               occurrencecount INT 
            ) 

          DECLARE @Stmnt1 AS VARCHAR(max) 
          DECLARE @Stmnt2 AS VARCHAR(max) 
          DECLARE @Where1 AS VARCHAR(max) 
          DECLARE @Where2 AS VARCHAR(max) 
          DECLARE @Groupby1 AS VARCHAR(max)='' 
          DECLARE @Groupby2 AS VARCHAR(max)='' 
          DECLARE @SelectStmnt AS NVARCHAR(max) 
          DECLARE @SenderTemp AS VARCHAR(max) 
          DECLARE @MarketTemp AS VARCHAR(max) 
          DECLARE @LocationTemp AS VARCHAR(max)
		 

          SET @Sender=Replace(( @Sender ), ',', ''',''') 
          SET @Sender= '''' + @Sender + '''' 
          SET @Market=Replace(( @Market ), ',', ''',''') 
          SET @Market= '''' + @Market + '''' 
          SET @Location=Replace((@Location), ', ', ''', ''') 
          SET @Location= '''' +(@Location) + '''' 
          SET @SenderTemp='''-1''' 
          SET @MarketTemp='''-1''' 
          SET @LocationTemp='''-1''' 
          SET @Stmnt1 = 
			'Select  Distinct Envelope.PK_EnvelopeId ,     Convert(VARCHAR(5),datepart(year,Envelope.ReceivedDt))  +''-''+ 
			 Convert(VARCHAR(2),datepart(Week,Envelope.ReceivedDt)) as [Week], SENDER.PK_SenderID, sender.Name, [User].FName + '' '' +[User].LName as RecievedBy,
			 Configurationmaster.Valuetitle, Configurationmaster.Value, Envelope.ReceivedDt, Shipper.Descrip as ShippingCompany, shippingMethod.ShipmentMethodName,
			 Envelope.TrackingNo, Envelope.ListedWeight,  Envelope.ActualWeight, MarketMaster.MarketCode, MarketMaster.[Description],
			  [User].LocationId, Count(OccurrencedetailsCIR.PK_OccurrenceID) as CircularCount from Envelope  
			  Inner Join [User] ON envelope.ReceivedById=[User].Userid Inner Join sender ON Envelope.SenderId = sender.PK_SenderID 
			  Inner Join Configurationmaster ON Configurationmaster.value = [User].Location Inner Join shippingMethod ON shippingMethod.PK_ShippingMethodID = Envelope.ShippingMethodId 
			  Inner Join Shipper ON Shipper.PK_ShipperID = Envelope.ShipperId Inner Join OccurrencedetailsCIR ON OccurrencedetailsCIR.FK_EnvelopeID = Envelope.PK_EnvelopeId 
			  Inner Join MarketMaster ON OccurrencedetailsCIR.FK_MarketID = MarketMaster.MarketCode'

			SET @Where1=' WHERE (1=1)  AND   Envelope.ReceivedDt  BETWEEN ''' 
						+ CONVERT(VARCHAR, Cast(@DateFrom AS DATE), 101) 
						+ '''  AND  ''' 
						+ CONVERT(VARCHAR, Cast(@DateTo AS DATE), 101) 
						+ '''' 

				IF ( @sender <> @SenderTemp ) 
				  BEGIN 
					  SET @Where1 = @Where1 + ' AND  sender.PK_SenderID IN ('+@Sender+')' 
				  END 

				IF( @Market <> @MarketTemp ) 
				  BEGIN 
					  SET @Where1 = @Where1 
									+ ' AND MarketMaster.MarketCode IN ('+@Market +')' 
				  END 

				IF( @Location <> @LocationTemp ) 
				  BEGIN 
					  SET @Where1 = @Where1 
									+ ' AND Configurationmaster.Valuetitle IN ('+@Location+')' 
				  END 

				SET @Groupby1= 
							'Group By envelope.PK_EnvelopeID,Envelope.ReceivedDt,sender.PK_SenderID,  sender.Name, [User].FName + '' '' + [User].LName, 
							Configurationmaster.Valuetitle, Configurationmaster.Value,Envelope.ReceivedDt,SENDER.PK_SenderID,sender.Name,  Shipper.Descrip, 
							shippingMethod.ShipmentMethodName,Envelope.TrackingNo,Envelope.ListedWeight,  
							Envelope.ActualWeight,MarketMaster.MarketCode,MarketMaster.[Description],[User].LocationId ' 
                SET @Stmnt2= 
				' UNION Select  Envelope.PK_EnvelopeId ,              Convert(VARCHAR(5),datepart(year,Envelope.ReceivedDt))  + ''-''+ 
				 Convert(VARCHAR(2),datepart(Week,Envelope.ReceivedDt)) as [Week],    SENDER.PK_SenderID,sender.Name,[User].FName +'' '' +[User].LName as RecievedBy,   
				 Configurationmaster.Valuetitle,Configurationmaster.Value,Envelope.ReceivedDt,     Shipper.Descrip, shippingMethod.ShipmentMethodName,
				 Envelope.TrackingNo, Envelope.ListedWeight, Envelope.ActualWeight,MarketMaster.MarketCode, MarketMaster.Description,
				 [User].LocationId ,Count(OccurrencedetailsPUB.PK_OccurrenceID) as PubCount from Envelope  
				 Inner Join [User] ON envelope.ReceivedById=[User].Userid Inner Join sender ON Envelope.SenderId = sender.PK_SenderID 
				 Inner Join Configurationmaster ON Configurationmaster.value = [User].Location 
				 Inner Join shippingMethod ON shippingMethod.PK_ShippingMethodID = Envelope.ShippingMethodId 
				 Inner Join Shipper ON Shipper.PK_ShipperID = Envelope.ShipperId 
				 Inner Join PubIssue ON PubIssue.FK_EnvelopeID = Envelope.PK_EnvelopeId 
				 Inner Join PubEdition ON PubEdition.PK_PubEditionID = PubIssue.FK_PubEditionID 
				 Inner Join OccurrencedetailsPUB ON OccurrencedetailsPUB.FK_PubIssueID = PubIssue.PK_PubIssueID
				  Inner Join MarketMaster ON OccurrencedetailsPUB.FK_MarketID = MarketMaster.MarketCode'



				SET @Where2=' WHERE (1=1) AND   Envelope.ReceivedDt   BETWEEN ''' 
							+ CONVERT(VARCHAR, Cast(@DateFrom AS DATE), 101) 
							+ '''    AND  ''' 
							+ CONVERT(VARCHAR, Cast(@DateTo AS DATE), 101) 
							+ '''' 

				IF( @sender <> @SenderTemp ) 
				  BEGIN 
					  SET @Where2 = @Where2 + ' AND  SENDER.PK_SenderID IN (' 
									+ @Sender + ')' 
				  END 

				IF( @Market <> @MarketTemp ) 
				  BEGIN 
					  SET @Where2 = @Where2 
									+ ' AND MarketMaster.MarketCode IN (' 
									+ @Market + ')' 
				  END 

				IF( @Location <> @LocationTemp ) 
				  BEGIN 
					  SET @Where2 = @Where2 
									+ ' AND Configurationmaster.Valuetitle IN (' 
									+ @Location + ')' 
				  END 



 SET @SelectStmnt=@Stmnt1 + @Where1 + @Groupby1 + @Stmnt2 + @Where2  + @Groupby1 

INSERT INTO #temporarypackage 
			EXECUTE Sp_executesql 
				    @SelectStmnt 
			PRINT   @SelectStmnt

    SELECT    envelopeid,[week],senderid,sender,recievedby,userlocation,location, 
              reciveddate,shippingcompany,shippingmethod,trackingnumber,printedweight, 
              actualweight, locationid, Sum(occurrencecount) AS totalcount FROM   #temporarypackage 
    GROUP  BY envelopeid,[week],sender,senderid,recievedby,userlocation,location ,reciveddate,shippingcompany,
	          shippingmethod,trackingnumber,printedweight, actualweight,locationid 
	
END try 

    BEGIN catch 
        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT 

        SELECT @error = Error_number(),@message = Error_message(), 
               @lineNo = Error_line() 

        RAISERROR ('[sp_PackageExpectation]: %d: %s',16,1,@error,@message, 
                   @lineNo); 
    END catch 
END