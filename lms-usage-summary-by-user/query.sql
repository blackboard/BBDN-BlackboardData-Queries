select distinct
    lp.stage:user_id::string as user_id,
    concat(lp.first_name, ' ', lp.last_name) as name,
    lp.email,
    mcd.canon_desc as institution_role,
    mcd2.canon_desc as system_role,
    lsa.last_login_date,
    ifnull(lsa.minutes,0) as total_login_minutes
from cdm_lms.person_course lpc
inner join cdm_lms.person lp
    on lp.id = lpc.person_id
left join (
    select
        person_id,
        to_date(max(last_accessed_time)) as last_login_date,
        round(sum(duration_sum)/60,0) as minutes
    from cdm_lms.session_activity
    group by person_id) lsa
    on lsa.person_id = lp.id
left join cdm_meta.canon_definition mcd
    on mcd.name = 'INSTITUTION_ROLE'
    and mcd.canon_code = lp.institution_role
left join cdm_meta.canon_definition mcd2
    on mcd2.name = 'SYSTEM_ROLE'
    and mcd2.canon_code = lp.system_role
where lpc.course_role = 'I'

