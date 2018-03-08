

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[mt_proc_Email_GetVehicleBody]
@VehicleID as varchar(50),
@Operation as char(2)
AS
BEGIN
	

	if(@Operation = 'A')
	Begin

	-- get record base on vehicleID
	select [OccurrenceID] VehicleId, BodyHTML, Isnull( [Advertiser].Descrip, '') as Descrip
	 from OccurrenceEmail O
	 inner join [OccurrenceDetailEM] OD on OD.[OccurrenceDetailEMID] = O.[OccurrenceID]
	 left outer join [Advertiser] on OD.[AdvertiserID] = [Advertiser].AdvertiserID
	 where [OccurrenceID]=@VehicleID 

	END

	if(@Operation = 'B')
	BEGIN
	 -- select latest top 100 from vehicleBody
		SELECT    top 2000 Ret.Descrip, VehicleBody.VehicleId, VehicleBody.BodyHTML FROM MCAP..Ret 
					INNER JOIN
							  MCAP..Vehicle ON Ret.RetId = Vehicle.RetId INNER JOIN
							  MCAP..VehicleBody ON Vehicle.VehicleId = VehicleBody.VehicleId
					ORDER BY VehicleBody.VehicleId DESC
	END
	
	
END
