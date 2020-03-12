select
    mcd.canon_desc as role,
    lpc.course_role_source_desc as source_role,
    case when lsa.mobile_ind = 1 then 'Mobile' else 'Non-Mobile' end as device,
    count(distinct lsa.person_id) as distinct_users,
    round(sum(lsa.duration_sum)/60,0) as minutes,
    count(distinct lsa.id) as accesses,
    sum(interaction_cnt) as interactions,
    round(minutes / distinct_users,0) as avg_minutes_per_user,
    round(accesses / distinct_users,0) as avg_accesses_per_user,
    round(interactions / distinct_users,0) as avg_interactions_per_user
from cdm_lms.person_course lpc
inner join cdm_lms.session_activity lsa
    on lsa.person_id = lpc.person_id
left join cdm_meta.canon_definition mcd
    on mcd.source_domain = 'LMS'
    and name = 'COURSE_ROLE'
    and canon_code = lpc.course_role
where lsa.first_accessed_time >= '{date}'
group by role, source_role, Device
order by role, source_role, Device