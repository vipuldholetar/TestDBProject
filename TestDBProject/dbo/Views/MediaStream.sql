create view MediaStream as 
select configurationid as mediastreamid, valuetitle as descrip, value as mediastream
from Configuration with (nolock)
where componentName = 'Media Stream'
