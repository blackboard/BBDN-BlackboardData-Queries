select
  grade_band,
  round(avg(ns_clean),2) as avg_grade,
  round(avg(total_duration_sum)/60,0) as avg_course_minutes,
  round(avg(total_interaction_cnt),0) as avg_course_interactions,
  round(avg(course_access_cnt),0) as avg_course_accesses,
  round(avg(clb_duration_sum)/60,0) as avg_collab_minutes,
  round(avg(clb_access_cnt),2) as avg_collab_accesses
from
(
    select
        person_course_id,
        course_id,
        person_id,
        sum(duration_sum) as total_duration_sum,
        sum(interaction_cnt) as total_interaction_cnt,
        count(id) as course_access_cnt
    from cdm_lms.course_activity
    group by
        person_course_id,
        course_id,
        person_id
) lms
inner join
(
    select
        mcr.lms_course_id,
        mp.lms_person_id,
        sum(ca.duration) as clb_duration_sum,
        count(ca.id) as clb_access_cnt
    from cdm_clb.attendance ca
    inner join cdm_clb.session cs
        on ca.session_id = cs.id
    inner join cdm_map.course_room mcr
        on cs.room_id = mcr.clb_room_id
    inner join cdm_map.person mp
        on mp.clb_person_id = ca.person_id
    group by
        mcr.lms_course_id,
        mp.lms_person_id
) clb
    on clb.lms_course_id = lms.course_id
    and clb.lms_person_id = lms.person_id
inner join
(
  select
      lg.person_course_id as lpc_id,
      lg.normalized_score,
      case
          when lg.normalized_score > 1 then 1
          when lg.normalized_score < 0 then 0
          else lg.normalized_score
      end as ns_clean,
      ntile(4) over (order by ns_clean) as grade_band
  from cdm_lms.grade lg
  inner join cdm_lms.gradebook lgb
      on lg.gradebook_id = lgb.id
      and lgb.final_grade_ind = 1
      and deleted_ind = 0
  where normalized_score is not null
) grd
    on grd.lpc_id = lms.person_course_id
group by grade_band
order by grade_band