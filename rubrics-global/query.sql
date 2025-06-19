/** 
This query retrieves every score and comment for every student 
against every criteria in every rubric in every assessment in 
every course, unless filtered, and so can take some time to
run for larger institutions or those using rubrics broadly.
**/

select distinct
    lc.name as course_name,
    lc.course_number as course_id,
    lc.stage:batch_uid::string as batch_uid,
    lp.email as student_email,
    concat(lp.first_name,' ',lp.last_name) as student_name,
    lgb.name as gradebook_column_name,
    r.name as rubric_name,
    --r.description as rubric_description,
    rc.name as rubric_criteria_name,
    --rc.description as rubric_criteria_description,
    e.name as criteria_grade_name,
    e.feedback as criteria_feedback,
    e.score as criteria_score,
    e.possible_score as criteria_possible_score,
    e.normalized_score as criteria_normalized_score,
    er.score as rubric_score
from cdm_lms.evaluable_item r
left join cdm_lms.evaluable_item rc
    on rc.evaluable_item_parent_id = r.id
left join cdm_lms.evaluation e
    on e.evaluable_item_id = rc.id
left join cdm_lms.person_course lpc
    on e.person_course_id = lpc.id
left join cdm_lms.evaluation er
    on er.evaluable_item_id = r.id
    and er.person_course_id = lpc.id
left join cdm_lms.person lp
    on lp.id = lpc.person_id
left join cdm_lms.course lc
    on lc.id = lpc.course_id
left join cdm_lms.evaluable_course_item eci
    on eci.evaluable_item_id = r.id
left join cdm_lms.gradebook lgb
    on lgb.course_item_id = eci.course_item_id
left join cdm_lms.grade lg
    on lg.gradebook_id = lgb.id
    and lg.person_course_id = lpc.id
where -- UPDATE OR COMMENT OUT THE FOLLOWING AS APPROPRIATE
    lc.name = 'COURSE NAME HERE'
    and lgb.name = 'COLUMN NAME HERE'
    and r.name = 'RUBRIC NAME HERE'
    and lp.email = 'STUDENT EMAIL HERE'
limi 100; -- REMOVE OR COMMENT OUT TO RETRIEVE ALL ROWS
