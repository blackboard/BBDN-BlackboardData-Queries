select
    mcd.canon_desc as design_mode,
    ifnull(count(distinct lc.id),0) as course_count,
    ifnull(count(distinct case when course_role = 'I' then lpc.person_id else null end),0) as distinct_instructors,
    ifnull(count(distinct case when course_role = 'S' then lpc.person_id else null end),0) as distinct_students
from cdm_lms.course lc
left join cdm_lms.person_course lpc
    on lpc.course_id = lc.id
left join cdm_meta.canon_definition mcd
    on mcd.name = 'DESIGN_MODE'
    and mcd.source_domain = 'LMS'
    and mcd.canon_code = lc.design_mode
where lc.created_time > '{date}' 
group by 
    mcd.canon_desc
order by
    mcd.canon_desc