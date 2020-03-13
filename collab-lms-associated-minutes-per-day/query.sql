select
    to_date(ca.first_join_time) as date,
    round(sum(ca.duration)/60,0) as total_minutes,
    count(distinct ca.person_id) as distinct_identifiable_users
from cdm_clb.attendance ca
inner join cdm_clb.session cs
    on cs.id = ca.session_id
inner join cdm_map.course_room mcr
    on mcr.clb_room_id = cs.room_id
    and mcr.lms_course_id > 0
inner join cdm_lms.course lc
    on lc.id = mcr.lms_course_id
Where
    ca.first_join_time >= dateadd(month,-1,current_date())
group by date
order by date