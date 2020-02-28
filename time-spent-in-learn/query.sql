select
   lp.last_name,
   lp.first_name,
   lsa.person_id,
   month(first_accessed_time) as month,
   round(sum(duration_sum)/60,0) as duration_minutes
from cdm_lms.session_activity lsa
inner join cdm_lms.person lp
   on lp.id = lsa.person_id
where
   year(first_accessed_time) = {year}
group by
   lp.last_name,
   lp.first_name,
   lsa.person_id,
   month(first_accessed_time)
