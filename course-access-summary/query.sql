with access as (
select
    lpc.course_id,
    to_date(min(lca.first_accessed_time)) as first_accessed,
    to_date(max(lca.last_accessed_time)) as last_accessed,
    sum(lca.duration_sum)/60 as total_minutes,
    count(distinct lpc.person_id) as enrolled_users,
    count(distinct lca.person_id) as active_users,
    round(total_minutes / active_users,0) as avg_minutes
from cdm_lms.person_course lpc
left join cdm_lms.course_activity lca
    on lpc.id = lca.person_course_id
where 
    lpc.course_role in ({course_roles})
    and lpc.available_ind = 1
group by 
    lpc.course_id
)

select
    lc.name as course,
    lc.stage:batch_uid::string as batchUID,
    a.first_accessed,
    a.last_accessed,
    ifnull(a.enrolled_users,0) as enrolled_users,
    ifnull(a.active_users,0) as active_users,
    ifnull(a.avg_minutes,0) as avg_minutes   
from cdm_lms.course lc
left join access a
    on a.course_id = lc.id
where lc.available_to_students_ind = 1