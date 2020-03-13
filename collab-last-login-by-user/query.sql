with login as ( -- parsing JSON data from the DATA column
select
    data:productId::string as product_id,
    data:type::string as event_type,
    data:date::timestamp_ntz(3) as event_time,
    data:clientId::string as client_id,
    data:contextId::string as context_id,
    data:contextType::string as context_type,
    data:objectId::string as object_id,
    data:objectType::string as object_type,
    data:userId::string as user_id,
  data
from
  cdm_tlm.collab_events
where event_type = 'LOGIN'
)

select
  lp.first_name,
  lp.last_name,
  lp.email,
  max(to_date(l.event_time)) as last_login,
  max(l.event_time) as last_login_time,
  min(l.event_time) as first_login_time
from login l
left join cdm_lms.person lp
  on lp.stage:uuid::string = l.user_id -- joining to the LMS person table using the unique userid from the Stage column
group by 
  lp.first_name,
  lp.last_name,
  lp.email
--having last_login <= '2019-07-20'
order by last_login desc

