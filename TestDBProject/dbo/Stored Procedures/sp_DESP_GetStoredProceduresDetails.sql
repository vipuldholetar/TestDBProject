-- =============================================
-- Author:		Lisa East
-- Create date: 8.24.17
-- Description:	Gets the Paramter Details for the selected stored procedure
-- =============================================
CREATE PROCEDURE [dbo].[sp_DESP_GetStoredProceduresDetails]

	@StoredProcedureID int = 0
AS
BEGIN
	SET NOCOUNT ON;

	IF @StoredProcedureID > 0 
	BEGIN
		DECLARE @proc_name VARCHAR(50);
		SELECT @proc_name = ProcedureName FROM DESP_StoredProcedure WHERE StoredProcedureID = @StoredProcedureID;

		SELECT P.PARAMETER_NAME, '' AS PARAMETER_Value, X.Name AS PropertyName, X.VALUE AS PropertyValue, P.ORDINAL_POSITION AS 'Param_Position', 
			CASE P.Parameter_Mode WHEN 'IN' THEN 'Input' ELSE 'Output' END AS 'Mode', P.DATA_TYPE, P.CHARACTER_MAXIMUM_LENGTH AS 'Data_Length',P.PRECISION, P.Scale
		FROM  sys.fn_listextendedproperty(DEFAULT, 'SCHEMA', 'dbo', 'PROCEDURE', @proc_name, DEFAULT, DEFAULT) AS X 
		FULL OUTER JOIN (SELECT  SPECIFIC_NAME, PARAMETER_NAME, ORDINAL_POSITION, PARAMETER_MODE, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION AS [Precision], NUMERIC_SCALE AS Scale
						 FROM DESP_StoredProcedure Desp 
						 INNER JOIN INFORMATION_SCHEMA.PARAMETERS ISP ON ISP.SPECIFIC_NAME=Desp.ProcedureName	
						 WHERE (Desp.StoredProcedureID=@StoredProcedureID)
						 ) AS P ON X.ObjName = P.SPECIFIC_NAME COLLATE DATABASE_DEFAULT AND X.Name = P.PARAMETER_NAME COLLATE DATABASE_DEFAULT
		ORDER BY 'Param_Position';
	END;
END