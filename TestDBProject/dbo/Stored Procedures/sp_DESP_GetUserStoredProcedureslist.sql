
-- =============================================
-- Author:		Lisa East
-- Create date: 8.24.17
-- Description:	Gets the list of storedprocedures the user is authorized to execute.
-- =============================================
CREATE PROCEDURE [dbo].[sp_DESP_GetUserStoredProcedureslist]

@UserId int
AS
BEGIN
	SET NOCOUNT ON;


	SELECT distinct SP.StoredProcedureId , SP.ProcedureName, ISNULL(EP.name, SP.ProcedureName) DisplayName, SP.Descrip
	FROM DESP_StoredProcedure AS SP 
	INNER JOIN INFORMATION_SCHEMA.ROUTINES AS ISR ON SP.ProcedureName = ISR.SPECIFIC_NAME 
	LEFT OUTER JOIN fn_listextendedproperty(DEFAULT, 'SCHEMA', 'dbo', 'PROCEDURE', DEFAULT, DEFAULT, DEFAULT) AS EP ON EP.Name = 'Name' AND ISR.ROUTINE_TYPE = EP.ObjType COLLATE DATABASE_DEFAULT AND ISR.ROUTINE_NAME = EP.ObjName COLLATE DATABASE_DEFAULT 
	INNER JOIN DESP_StoredProcedureRoleAssoc AS SPRA ON SP.StoredProcedureId = SPRA.StoredProcedureId 
	INNER JOIN UserRoles AS UR ON UR.RoleId = SPRA.RoleId AND UR.UserId = @UserId order by ProcedureName 
END


