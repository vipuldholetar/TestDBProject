
-- =============================================
-- Author:		Karunakar
-- Create date: 01/11/2016
-- Description:	This Procedure is used to getting Media Type for Print Media	
-- Execution Process: sp_GetPrintMediaType 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPrintMediaType] 
AS 
BEGIN
create table #tempMediaTypeID
(
PK_MediaTypeID int,
Descrip nvarchar(max)
)
INSERT INTO #tempMediaTypeID VALUES(-1,'ALL')

INSERT INTO #tempMediaTypeID
Select Distinct [MediaTypeID],Descrip  from Mediatype where Mediastream in('CIR','PUB','EM','WEB','SOC')


select  * from #tempMediaTypeID
END
