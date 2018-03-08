

-- ============================================= 

-- Author:    Ramesh 

-- Create date: 04/22/2015 

-- Description:  Returns Job/JobPackage/JobStep and Id based on ProcessId

-- Query : exec usp_CheckProcessType 'IM01'

-- ============================================= 
CREATE Proc [dbo].[usp_CheckProcessType]
@ProcessCODE VARCHAR(20)
AS
SET nocount ON
	IF EXISTS(SELECT 1 FROM [Job] WHERE [ProcessCODE]=@ProcessCODE)
		BEGIN
				SELECT 'Job',[JobCODE] FROM [Job] WHERE [ProcessCODE]=@ProcessCODE
		END
	ELSE IF EXISTS(SELECT 1 FROM [JobPackage] WHERE [Target]=@ProcessCODE)
	BEGIN
				SELECT 'JobPackage',[JobPackageCODE] FROM [JobPackage] WHERE [Target]=@ProcessCODE
	END
	ELSE IF EXISTS(SELECT 1 FROM [JobStep] WHERE [Target]=@ProcessCODE)
	BEGIN
				SELECT 'JobStep',[JobStepCODE] FROM [JobStep] WHERE [Target]=@ProcessCODE
	END
	ELSE
	BEGIN
				SELECT '',''
	END