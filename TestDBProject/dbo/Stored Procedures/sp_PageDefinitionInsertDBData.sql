-- ======================================================================================

-- Author			: KARUNAKAR

-- Create date		: 10th August 2015

-- Description		: This Procedure is Used to Getting Page Defintion Insert DB Data

-- Exec sp_PageDefinitionInsertDBData 10,156

-- Updated By		:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value

--					:   Karunakar on 30th October 2015,Adding Email to Page Definition Insert type Data
--					:   Karunakar on 23rd  November 2015,Adding Social to Page Definition Insert type Data
-- =========================================================================================

CREATE PROCEDURE [dbo].[sp_PageDefinitionInsertDBData]

	@OccurrenceId BIGINT,

	@MediaStreamId Int

AS

BEGIN

	

	SET NOCOUNT ON;

	 BEGIN TRY 

			DECLARE @MediaStreamValue AS NVARCHAR(50)='' 

			SELECT @MediaStreamValue = value FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'Media Stream' AND ConfigurationID= @MediaStreamId



			IF(@MediaStreamValue='CIR')

			BEGIN

				SELECT      CAST(SUBSTRING(CreativeDetailCIR.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailCIR.PageName) - LEN(PageType.Abbr) - 1) AS INT) 

							AS Number, CAST(COUNT(CreativeDetailCIR.PageName) AS INT) AS PageCount, CAST(MIN(CreativeDetailCIR.PageNumber) AS INT) AS StartPage, 

							CreativeDetailCIR.[PageTypeID]

				FROM            [OccurrenceDetailCIR] INNER JOIN

							[Pattern] ON [OccurrenceDetailCIR].[PatternID] = [Pattern].[PatternID] INNER JOIN

							[Creative] ON [Creative].PK_Id = [Pattern].[CreativeID] INNER JOIN

							CreativeDetailCIR ON CreativeDetailCIR.CreativeMasterID = [Creative].PK_Id INNER JOIN

							PageType ON CreativeDetailCIR.[PageTypeID] = PageType.[PageTypeID]

				WHERE        ([OccurrenceDetailCIR].[OccurrenceDetailCIRID] = @OccurrenceID) AND (CreativeDetailCIR.[PageTypeID] <> 'B')

				GROUP BY CreativeDetailCIR.[PageTypeID], CAST(SUBSTRING(CreativeDetailCIR.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailCIR.PageName) 

							- LEN(PageType.Abbr) - 1) AS INT)

				ORDER BY StartPage

			END

			ELSE IF  @MediaStreamValue='PUB'

			BEGIN

				SELECT   CAST(SUBSTRING(CreativeDetailPUB.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailPUB.PageName) - LEN(PageType.Abbr) - 1) AS INT) 

				AS Number, CAST(COUNT(CreativeDetailPUB.PageName) AS INT) AS PageCount, CAST(MIN(CreativeDetailPUB.PageNumber) AS INT) AS StartPage, 

				CreativeDetailPUB.[PageTypeID]

				FROM            [OccurrenceDetailPUB] INNER JOIN

				[Pattern] ON [OccurrenceDetailPUB].[PatternID] = [Pattern].[PatternID] INNER JOIN

				[Creative] ON [Creative].PK_Id = [Pattern].[CreativeID] INNER JOIN

				CreativeDetailPUB ON CreativeDetailPUB.CreativeMasterID = [Creative].PK_Id INNER JOIN

				PageType ON CreativeDetailPUB.[PageTypeID] = PageType.[PageTypeID]

				WHERE        ([OccurrenceDetailPUB].[OccurrenceDetailPUBID] = @OccurrenceID) AND (CreativeDetailPUB.[PageTypeID] <> 'B')

				GROUP BY CreativeDetailPUB.[PageTypeID], CAST(SUBSTRING(CreativeDetailPUB.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailPUB.PageName) 

				- LEN(PageType.Abbr) - 1) AS INT)

				ORDER BY StartPage

			END

			ELSE IF  @MediaStreamValue='EM'

			BEGIN

			

				SELECT      CAST(SUBSTRING(CreativeDetailEM.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailEM.PageName) - LEN(PageType.Abbr) - 1) AS INT) 

							AS Number, CAST(COUNT(CreativeDetailEM.PageName) AS INT) AS PageCount, CAST(MIN(CreativeDetailEM.PageNumber) AS INT) AS StartPage, 

							CreativeDetailEM.PageTypeId

				FROM        [OccurrenceDetailEM] INNER JOIN

							[Pattern] ON [OccurrenceDetailEM].[PatternID] = [Pattern].[PatternID] INNER JOIN

							[Creative] ON [Creative].PK_Id = [Pattern].[CreativeID] INNER JOIN

							CreativeDetailEM ON CreativeDetailEM.CreativeMasterID = [Creative].PK_Id INNER JOIN

							PageType ON CreativeDetailEM.PageTypeId = PageType.[PageTypeID]

				WHERE       ([OccurrenceDetailEM].[OccurrenceDetailEMID] = @OccurrenceID) AND (CreativeDetailEM.PageTypeId <> 'B')

				GROUP BY CreativeDetailEM.PageTypeId, CAST(SUBSTRING(CreativeDetailEM.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailEM.PageName) 

							- LEN(PageType.Abbr) - 1) AS INT)

				ORDER BY StartPage

			END

			ELSE IF  @MediaStreamValue='WEB'

			BEGIN

				SELECT      CAST(SUBSTRING(CreativeDetailWEB.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailWEB.PageName) - LEN(PageType.Abbr) - 1) AS INT) 

							AS Number, CAST(COUNT(CreativeDetailWEB.PageName) AS INT) AS PageCount, CAST(MIN(CreativeDetailWEB.PageNumber) AS INT) AS StartPage, 

							CreativeDetailWEB.[PageTypeID]

				FROM        [OccurrenceDetailWEB] INNER JOIN

							[Pattern] ON [OccurrenceDetailWEB].[PatternID] = [Pattern].[PatternID] INNER JOIN

							[Creative] ON [Creative].PK_Id = [Pattern].[CreativeID] INNER JOIN

							CreativeDetailWEB ON CreativeDetailWEB.CreativeMasterID = [Creative].PK_Id INNER JOIN

							PageType ON CreativeDetailWEB.[PageTypeID] = PageType.[PageTypeID]

				WHERE       ([OccurrenceDetailWEB].[OccurrenceDetailWEBID] = @OccurrenceID) AND (CreativeDetailWEB.[PageTypeID] <> 'B')

				GROUP BY CreativeDetailWEB.[PageTypeID], CAST(SUBSTRING(CreativeDetailWEB.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailWEB.PageName) 

							- LEN(PageType.Abbr) - 1) AS INT)

				ORDER BY StartPage

			END
			ELSE IF  @MediaStreamValue='SOC'

			BEGIN

				SELECT      CAST(SUBSTRING(CreativeDetailsoc.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailsoc.PageName) - LEN(PageType.Abbr) - 1) AS INT) 
				AS Number, CAST(COUNT(CreativeDetailsoc.PageName) AS INT) AS PageCount, CAST(MIN(CreativeDetailsoc.PageNumber) AS INT) AS StartPage, 
				CreativeDetailsoc.[PageTypeID]
				FROM        [OccurrenceDetailSOC] 
				INNER JOIN [Pattern] ON [OccurrenceDetailSOC].[PatternID] = [Pattern].[PatternID] 
				INNER JOIN [Creative] ON [Creative].PK_Id = [Pattern].[CreativeID] 
				INNER JOIN CreativeDetailsoc ON CreativeDetailsoc.CreativeMasterID = [Creative].PK_Id 
				INNER JOIN PageType ON CreativeDetailsoc.[PageTypeID] = PageType.[PageTypeID]

				WHERE       ([OccurrenceDetailSOC].[OccurrenceDetailSOCID] = @OccurrenceID) AND 
				(CreativeDetailsoc.[PageTypeID] <> 'B')

				GROUP BY CreativeDetailsoc.[PageTypeID], CAST(SUBSTRING(CreativeDetailsoc.PageName, LEN(PageType.Abbr) + 1, CHARINDEX('-', CreativeDetailsoc.PageName) 

				- LEN(PageType.Abbr) - 1) AS INT)

				ORDER BY StartPage

			END



	 END TRY

	 BEGIN CATCH

	

				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()

				RAISERROR ('sp_PageDefinitionInsertDBData: %d: %s',16,1,@error,@message,@lineNo); 

						

	 END CATCH

   

END
