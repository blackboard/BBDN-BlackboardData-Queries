select
    lt.name as term,
    count(distinct lca.person_id) as distinct_users,
    count(distinct lpc.id) as enrolment_count,
    round(enrolment_count / distinct_users,2) as avg_enrolments,
    count(distinct lpc.course_id) as distinct_courses,
    count(distinct lca.course_id) as courses_accessed,
    round(sum(lca.duration_sum)/60,0) as course_minutes,
    round(course_minutes / distinct_users,0) as avg_minutes,
    count(distinct lca.id) as course_accesses,
    sum(interaction_cnt) as course_interactions
from cdm_lms.term lt
inner join cdm_lms.course lc
    on lc.term_id = lt.id
left join cdm_lms.course_activity lca
    on lca.course_id = lc.id
inner join cdm_lms.person_course lpc
    on lpc.id = lca.person_course_id
    and lpc.course_role = 'I'
group by term
having term like '%{term}%'