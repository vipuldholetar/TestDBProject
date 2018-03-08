-- =================================================================   
-- Author            :  Arun Nair   
-- Create date       :  01/12/2016   
-- Execution     :  [sp_mapmodrule] '1,2,3,4,5,6,8,10,11,12,13,14',2166
-- Description       :  Run MapMOD Rule for Revision   
-- Updated By     :        select * from mapmodconditions select * from ad where advid=29731251
-- =================================================================   
CREATE PROCEDURE [dbo].[sp_MapMODRule] @MapMODControlList AS NVARCHAR(max), 
                                       @Adid              INT 
AS 
  BEGIN 
      SET NOCOUNT ON; 
		  IF 1 = 0 
		  BEGIN 
			  SET FMTONLY OFF 
		  END 
      BEGIN TRY 
	   DECLARE @NewAdRevFinal as Bit=0
          DECLARE @MapAdFinal as bit=0
          DECLARE @ScanReqdFinal  as bit=0
          DECLARE @NewAdRevYes as Bit
          DECLARE @MapAdYes as bit
          DECLARE @ScanReqdYes  as bit
		  
          DECLARE @NewAdRevNo as Bit
          DECLARE @MapAdNo as bit
          DECLARE @ScanReqdNo  as bit

		   DECLARE @NewAdRevCount as int =0
          DECLARE @MapAdCount as int=0
          DECLARE @ScanReqdCount  as int=0
          DECLARE @Counter INT =0 
          DECLARE @RowCount INT =0 
          DECLARE @AppendDescYesCode AS CHAR(1) 
          DECLARE @AppendTextYes AS NVARCHAR(max) 
          DECLARE @ConditionCode AS NVARCHAR(max)='' 
          DECLARE @AppendDescNoCode AS CHAR(1) 
          DECLARE @AppendTextNo AS NVARCHAR(max) 
          DECLARE @RecutDetail AS NVARCHAR(max)='' 
          DECLARE @Description AS NVARCHAR(max)='' 
          DECLARE @Mapmodcontrolid AS INT 
          DECLARE @ConditionResult AS BIT 

          CREATE TABLE #tempmapmodids 
            ( 
               rowid           INT IDENTITY(1, 1), 
               mapmodcontrolid INT 
            ) 

          INSERT INTO #tempmapmodids 
          SELECT id 
          FROM   [dbo].[Fn_csvtotable](@MapMODControlList) 

          SELECT @RowCount = Count(*) 
          FROM   [dbo].#tempmapmodids 

          WHILE @Counter <= @RowCount 
            BEGIN 
                SELECT @Mapmodcontrolid = mapmodcontrolid 
                FROM   #tempmapmodids 
                WHERE  rowid = @Counter 

                PRINT ( 'Mapmodcontrolid=' 
                        + Cast(@Mapmodcontrolid AS VARCHAR) ) 

                SELECT @ConditionCode = [ConditionCODE], 
                       @AppendDescYesCode = [AppendDescYesCODE], 
                       @AppendTextYes = appendtextyes, 
                       @AppendDescNoCode = [AppendDescNoCODE], 
                       @AppendTextNo = appendtextno, 
					   @NewAdRevYes=NewRevYesInd,
					   @MapAdYes=MapAdYesInd,
					   @ScanReqdYes=ScanReqYesInd,
					   @NewAdRevNo=NewRevNoInd,
					   @MapAdNo=MapAdNoInd,
					   @ScanReqdNo=ScanReqNoInd

                FROM   [dbo].[mapmodcontrol] 
                WHERE  [MadMODControlID] = @Mapmodcontrolid 

                IF ( @ConditionCode <> '' ) 
                  BEGIN 
                      PRINT( 'condition ' + @ConditionCode ) 

                      PRINT( @AppendDescYesCode )  
                      PRINT( @AppendTextYes )  
                      -- True 
                      PRINT( @adid ) 

                      PRINT( @conditioncode ) 

                      SELECT @ConditionResult = 
                  [dbo].[Ufn_mapmodcheckcondition](@adid, @conditioncode) 

                      PRINT( 'conditionresult - ' 
                             + Cast(@ConditionResult AS VARCHAR) ) 

                      IF ( @ConditionResult = 1 ) 
                        BEGIN 

						IF @NewAdRevYes = 1 begin set @NewAdRevCount =@NewAdRevCount+ 1 end
						IF @MapAdYes = 1 begin set @MapAdCount = @MapAdCount+1  end
						IF @ScanReqdYes = 1 begin set @ScanReqdCount =@ScanReqdCount+ 1  end


                            IF( @AppendDescYesCode = 'D' ) 
                              BEGIN 
                                  SET @description = @description + Char(13) + 
                                                     Char(10 
                                                     ) 
                                                     + 'MapMODReason/s: ' + 
                                                     @AppendTextYes 
                              PRINT( @description )  
                              END 

                            IF( @AppendDescYesCode = 'R' ) 
                              BEGIN 
                                  SET @recutdetail = @recutdetail + Char(13) + 
                                                     Char(10 
                                                     ) 
                                                     + 'MapMODReason/s: ' + 
                                                     @AppendTextYes 
                              PRINT( @recutdetail )  
                              END 
                        END 
                      ELSE 
                        BEGIN 
							IF @NewAdRevNo = 1 begin set @NewAdRevCount =@NewAdRevCount+ 1 end
							IF @MapAdNo = 1 begin set @MapAdCount = @MapAdCount+1  end
							IF @ScanReqdNo = 1 begin set @ScanReqdCount =@ScanReqdCount+ 1  end

                            IF( @AppendDescNoCode = 'D' ) 
                              BEGIN 
                                  SET @description = @description + Char(13) + 
                                                     Char(10 
                                                     ) 
                                                     + 'MapMODReason/s: ' + 
                                                     @AppendTextNo 
                              PRINT( @description )  
                              END 

                            IF( @AppendDescNoCode = 'R' ) 
                              BEGIN 
                                  SET @recutdetail = @recutdetail + Char(13) + 
                                                     Char(10 
                                                     ) 
                                                     + 'MapMODReason/s: ' + 
                                                     @AppendTextNo 
                              PRINT( @recutdetail )  
                              END 
                        END 
                  END 
                ELSE 
                  BEGIN 
				  	IF @NewAdRevYes = 1 begin set @NewAdRevCount =@NewAdRevCount+ 1 end
					IF @MapAdYes = 1 begin set @MapAdCount = @MapAdCount+1  end
					IF @ScanReqdYes = 1 begin set @ScanReqdCount =@ScanReqdCount+ 1  end
                      PRINT( @AppendDescYesCode )  
                      PRINT( @AppendTextYes )  
                      IF( @AppendDescYesCode = 'D' ) 
                        BEGIN 
                            SET @description = @description + Char(13) + Char(10 
                                               ) 
                                               + 'MapMODReason/s: ' + 
                                               @AppendTextYes 
                        PRINT( @description )  
                        END 

                      IF( @AppendDescYesCode = 'R' ) 
                        BEGIN 
                            SET @recutdetail = @recutdetail + Char(13) + Char(10 
                                               ) 
                                               + 'MapMODReason/s: ' + 
                                               @AppendTextYes 
                        PRINT( @recutdetail )  
                        END 
                  END 

                PRINT( '-----------' )  
                SET @Counter=@Counter + 1 
            END 

          DROP TABLE #tempmapmodids 

		  -- Comparison logic

		  print('newRevCount'+cast(@NewAdrevCount as varchar))
		  print('mapAdCount'+cast(@MapAdCount as varchar))
		  print('scanReqdCount'+cast(@ScanReqdCount as varchar))

		  if @NewAdrevCount>=@MapAdCount
		  begin
		  set @NewAdRevFinal=1
		  end
		  else
		  begin
		  set @MapAdFinal=1
		  end

		  if @ScanReqdCount>0 
		  begin
		  set @ScanReqdFinal=1
		  end

          SELECT @Description AS Description, @recutdetail AS RecutDetail,@NewAdRevFinal as RevisionAd,@MapAdFinal as MapAd,@ScanReqdFinal as Scanreqd
				
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_MapMODRule]: %d: %s',16,1,@error,@message,@lineNo); 
      END catch 
  END
