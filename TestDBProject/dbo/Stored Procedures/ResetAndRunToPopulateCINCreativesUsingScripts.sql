CREATE Procedure ResetAndRunToPopulateCINCreativesUsingScripts
as
begin

--Set the market id;
UPDATE [OccurrenceDetailCIN] SET [MarketID]=1;  

--Truncate creatives;
truncate table [CreativeDetailStagingCIN];

--Reset the pattersn;
update [PatternStaging] set [CreativeStgID]=null;

--Populate the creatives;
exec CINPopulateCreativesdata;

end