create view CreativeSyncStatus as
select codeid as creativesyncstatusid, descrip
from Code with (nolock)
where codetypeid = 2021
