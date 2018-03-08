-- ===================================================================================================
-- Author            : Amrutha
-- Create date       : 1/09/2016
-- Description       : Display of Publications/Occurrences of selected Ad for No Take
-- EXEC              : sp_PublicationMultiCouponOccurrenceDetails 'Red Plum',31766,'01/20/16',''
-- ====================================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationMultiCouponOccurrenceDetails]
        @Section VARCHAR(150),
		@AdID INT,
	    @IssueDate VARCHAR(50),
	    @Advertiser  VARCHAR(150)
      
AS
BEGIN
       SET NOCOUNT ON;

     BEGIN TRY 
	 Declare @SectionList varchar(max)
	 Declare @PublicationList nvarchar(100)

		
		SELECT @SectionList = (COALESCE(@SectionList + ', ', '') + CAST(Value AS varchar(max)) )
                                                         FROM [Configuration] 
                                                         WHERE SystemName ='All' 
                                                         AND ComponentName = 'Coupon Book to PUB'
														 AND (ValueTitle = @Section or @Section = '' or @Section = 'ALL')
		  print @SectionList

		 SELECT  @PublicationList = COALESCE(@PublicationList + ', ', '') + CAST(publication.[PublicationID] AS varchar(10))
			  FROM PubSection  INNER JOIN PUBLICATION ON 
			  PubSection.[PublicationID]= Publication.[PublicationID] 
			  WHERE [PubSectionID] IN (Select Distinct Id from [dbo].[fn_CSVToTable](@SectionList))

			  Print(@PublicationList)

					 --SELECT  @PublicationList =         COALESCE(@PublicationList + ', ', '') + CAST(PK_PublicationId AS varchar(10)) 
				  --                                      FROM PubSection  INNER JOIN PUBLICATION ON 
				  --                                      FK_PublicationID=PK_PublicationId 
			 SELECT d.Descrip as Publication,
				d.PubCode as PubCode, 
				b.EditionName as PubEdition,
				a.[PubIssueID],
				c.[OccurrenceDetailPUBID] as OccurrenceID,
				(select [Status] from OccurrenceStatus where OccurrenceStatusID = c.OccurrenceStatusID) [Status]
			 FROM PubIssue a, PubEdition b, [OccurrenceDetailPUB] c, Publication d
			 WHERE  d.[PublicationID] = b.[PublicationID]
			 AND a.[PubEditionID] = b.[PubEditionID]
			 AND c.[PubIssueID] = a.[PubIssueID]
			 AND b.[PublicationID]  in (Select Distinct Id from [dbo].[fn_CSVToTable](@PublicationList))
			 AND a.IssueDate = @IssueDate
			 AND c.[AdID] = @AdID
			 ORDER BY c.[OccurrenceDetailPUBID]

                          
         END TRY 
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_PublicationMultiCouponOccurrenceDetails: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH 
       END


	  --exec dbo.sp_PublicationMultiCouponOccurrenceDetails @Section='ALL',@AdID=31794,@IssueDate='01/27/16',@Advertiser='0'