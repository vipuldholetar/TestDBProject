create view vwCreativePreSync as 
select psc.id, psc.creativedetailsid, psc.mediatypeid, psc.creativesyncstatusid, st.descrip as creativesyncstatus, psc.locationid, l.descrip as location, psc.threadguid
from CreativePreSync psc
join creativesyncstatus st on psc.creativesyncstatusid = st.creativesyncstatusid
join location l on psc.locationid = l.locationid

