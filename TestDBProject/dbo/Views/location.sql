create view location as
select codeid as locationid, descrip
from code with (nolock)
where codetypeid = 8
