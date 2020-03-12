select
    --lp.source_id as user_pk1,
    concat(lp.first_name,' ', lp.last_name) as Student,
    lp.email,
    --lc.source_id as crsmain_pk1,
    lc.name as course,
    lc.course_number,
    round(zeroifnull(lca.course_access_count),0) as course_access_count,
    round(zeroifnull(lca.course_access_minutes),0) as course_access_minutes,
    round(zeroifnull(lca.course_interactions),0) as course_interactions,
    lca.first_course_access,
    lca.last_course_access,
    round(zeroifnull(ls.submission_count),0) as submission_count,
    ls.last_submission,
    round(zeroifnull(gr.total_grade),0) as  total_grade
from cdm_lms.person lp -- for Course attributes
inner join cdm_lms.person_course lpc -- for User-Course mapping
    on lpc.person_id = lp.id
    and lpc.course_role = 'S' -- limiting to Students
inner join cdm_lms.course lc -- for Course attributes
    on lc.id = lpc.course_id
left join ( -- building summary of Course Activity
    select
      person_course_id,
      count(distinct id) as course_access_count,
      sum(duration_sum)/60 as course_access_minutes,
      sum(interaction_cnt) as course_interactions,
      min(first_accessed_time) as first_course_access,
      max(last_accessed_time) as last_course_access
    from cdm_lms.course_activity
    group by person_course_id
    ) lca
    on lca.person_course_id = lpc.id
left join ( -- building a summary of submissions
    select
        person_course_id,
        count(distinct id) as submission_count,
        max(submitted_time) as last_submission
    from cdm_lms.submission
    group by person_course_id
    )ls
    on ls.person_course_id = lpc.id
left join ( - getting the total grade
    select
        person_course_id,
        normalized_score as total_grade
    from cdm_lms.grade lg
    inner join cdm_lms.gradebook lgb
        on lg.gradebook_id = lgb.id
    where lgb.final_grade_ind = 1
        and lg.row_deleted_time is null
        ) gr
    on gr.person_course_id = lpc.id
where
    lp.source_id = {userpk}
    and lc.course_number = '{coursepk}'
