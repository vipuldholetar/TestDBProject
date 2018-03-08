
-- ============================================================================================================
-- Author			: Arun Nair 
-- Create date		: Get Occurrence
-- Description		:	 
-- Updated By		: Kaurnakar on 14th July 2015 ,Changing the Join Condition and adding ODRAdFormatMap
-- Execution		: sp_OutdoorGetOccurrenceDisplayData 10024 
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--=============================================================================================================



CREATE PROCEDURE  [dbo].[sp_OutdoorGetOccurrenceDisplayData]
(
@OccurrenceId AS INTEGER
)

AS

BEGIN

		SET NOCOUNT ON; 
		BEGIN TRY

		Declare @MediaStream as varchar(50)=''

			SELECT @MediaStream=valuetitle from [Configuration] where componentname='Media Stream' and Value='OD'

			SELECT [OccurrenceDetailODR].[OccurrenceDetailODRID] As OccurrenceId,ODRAdFormatMap.CMSSourceFormat AS [Format],
			[OccurrenceDetailODR].[DisplayLocation] AS [Location],'' AS AirportCode,
			'' AS FirstCity,[OccurrenceDetailODR].[FileSourceType] AS SourceFileType,
			[OccurrenceDetailODR].[DisplayLocation] AS [FirstLocation],@MediaStream AS FirstMedium,[OccurrenceDetailODR].[FileSource]
			FROM [dbo].[OccurrenceDetailODR]
			Inner join [dbo].[ODRAdFormatMap] on ODRAdFormatMap.[MTFormatID]=[OccurrenceDetailODR].[AdFormatID]
			left JOIN AD ON [dbo].[AD].[AdID]=[dbo].[OccurrenceDetailODR].[AdID]
			WHERE [OccurrenceDetailODR].[OccurrenceDetailODRID]=@OccurrenceId

		END TRY



		BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_OutdoorGetOccurrenceDisplayData]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 
END
