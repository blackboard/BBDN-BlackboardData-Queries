with inst as (
select
  concat(lp.first_name, ' ', lp.last_name) as instructor,
  lp.email,
  lpc.course_id,
  count(distinct lca.id) as course_accesses,
  sum(lca.duration_sum)/60 as course_minutes,
  sum(lca.interaction_cnt) as course_interactions
from cdm_lms.person lp
inner join cdm_lms.person_course lpc
  on lpc.person_id = lp.id
  and lpc.course_role = 'I'
inner join cdm_lms.course_activity lca
  on lca.person_course_id = lpc.id
where lca.first_accessed_time >= '{first_accessed_time}'
group by
  lp.first_name,
  lp.last_name,
  lp.email,
  lpc.course_id
order by instructor, course_id
)

, stu as (  
select
  lpc.course_id,
  count(distinct lpc.person_id) as enrolled_students,
  count(distinct lca.person_id) as active_students,
  sum(lca.duration_sum)/60 as student_minutes,
  sum(lca.interaction_cnt) as student_interactions,
  count(distinct lca.id) as student_accesses,
  student_minutes / active_students as avg_student_minutes,
  student_interactions / active_students as avg_student_interactions,
  student_accesses / active_students as avg_student_accesses
from cdm_lms.person_course as lpc
left join cdm_lms.course_activity as lca
  on lca.person_course_id = lpc.id
where lpc.course_role = 'S'
    and lca.first_accessed_time >= '{first_accessed_time}'
group by
  lpc.course_id
) 
 
select
  inst.instructor,
  inst.email,
  count(distinct inst.course_id) as "Course Count",
  round(avg(inst.course_accesses),0) as "Avg. Instructor Accesses",
  round(avg(inst.course_minutes),0) as "Avg. Instructor Minutes",
  round(avg(inst.course_interactions),0) as "Avg. Instructor Interactions",
  round(avg(stu.active_students),0) as "Avg. Active Students",
  round(avg(stu.avg_student_minutes),0) as "Avg. Student Minutes per Course",
  "Avg. Student Minutes per Course" / "Avg. Instructor Minutes" as "Student:Instructor Activity Ratio"
from inst
inner join stu
  on stu.course_id = inst.course_id
where 
  stu.student_minutes > 0
group by 
  inst.instructor,
  inst.email
order by
  round(avg(stu.avg_student_minutes),0) desc
limit {limit}
