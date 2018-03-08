-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/07/2015
-- Description	: This stored procedure is used update the ad details.
-- Execution	: [sp_CPUpdateAdDetailsInAdClassWorkQueue] ''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPUpdateAdDetailsInAdClassWorkQueue]
(
@AdId INT,
@ClassID INT
)
AS
BEGIN
UPDATE AD SET [ClassificationGroupID]=@ClassID WHERE [AdID]=@AdId
END