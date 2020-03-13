select
    lc.stage:batch_uid::string as batchuid_course,
    lc.name as course_name,
    lc.course_number,
    lp.stage:batch_uid::string as batchuid_person,
    lp.stage:user_id::string as user_id,
    concat(lp.first_name, ' ', lp.last_name) as person_name,
    lp.email,
    lgb.name as gradebook_column,
    lci.item_type,
    lgb.final_grade_ind as is_external_grade_column,
    lgb.used_in_calculations_ind,
    lg.score,
    lg.possible_score,
    lg.normalized_score,
    round(lg.normalized_score*100,2) as percent_score,
    lg.attempted_cnt,
    lg.graded_cnt,
    lg.first_attempted_time,
    lg.first_graded_time
from cdm_lms.grade lg
inner join cdm_lms.gradebook lgb
    on lgb.id = lg.gradebook_id
inner join cdm_lms.person_course lpc
    on lpc.id = lg.person_course_id
inner join cdm_lms.course lc
    on lc.id = lpc.course_id
inner join cdm_lms.person lp
    on lp.id = lpc.person_id
inner join cdm_lms.course_item lci
    on lci.id = lgb.course_item_id
where lgb.deleted_ind = 0
limit 10