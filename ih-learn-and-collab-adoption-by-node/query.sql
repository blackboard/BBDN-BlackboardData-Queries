-- Aggregate by Hierarchy Node and term

select
    ifnull(cast(year(lt.start_date) as nvarchar), 'No Term') as term_year,
    ifnull(lt.name, 'No Term') as term,
    ifnull(h1.name, 'No Node') as hierarchy_node,
    h1.hierarchy_name_seq as hierarchy_path,
    count(distinct lc.id) as course_count,
    zeroifnull(round(sum(lci.file_size_mb))) as learn_storage_mb,
    count(distinct case when lc.design_mode = 'C' then lc.id end) as classic_course_count,
    count(distinct case when lc.design_mode != 'C' then lc.id end) as ultra_course_count,
    round(ultra_course_count / course_count,2) as ultra_adoption_percent,
    count(distinct gc.course_id) as grades_course_count,
    round(grades_course_count / course_count,2) as grades_adoption,
    round(zeroifnull(avg(gc.column_count)),2) as avg_assessments_per_course,
    count(distinct clb.lms_course_id) as collab_course_count,
    round(collab_course_count / course_count,2) as collab_adoption_percent,
    zeroifnull(sum(clb.collab_sessions)) as total_collab_sessions,
    zeroifnull(sum(clb.collab_minutes)) as total_collab_minutes,
    zeroifnull(sum(clb.collab_users)) as total_collab_users,
    zeroifnull(sum(clb.collab_storage)) as collab_storage_mb
from cdm_lms.course lc
left join cdm_lms.institution_hierarchy_course ihc
    on lc.id = ihc.course_id
    and ihc.primary_ind = 1
    and ihc.row_deleted_time is null
left join cdm_lms.institution_hierarchy h1
    on ihc.institution_hierarchy_id = h1.id
left join cdm_lms.term lt
    on lt.id = lc.term_id
left join (
    select
        mcr.lms_course_id,
        zeroifnull(round(sum(ca.duration)/60)) as collab_minutes,
        count(distinct ca.person_id) as collab_users,
        count(distinct cs.id) as collab_sessions,
        zeroifnull(round(sum(cm.size_mb))) as collab_storage
    from cdm_clb.session cs
    left join cdm_map.course_room mcr
        on mcr.clb_room_id = cs.room_id
    left join cdm_clb.attendance ca
        on cs.id = ca.session_id
    left join (
        select
            session_id,
            sum(size/1048576) as size_mb -- converting bytes to megabytes
        from cdm_clb.media
        where media_category = 'R' -- recordings only
        group by session_id
      ) cm
        on cm.session_id = cs.id
    group by mcr.lms_course_id
    ) clb on lc.id = clb.lms_course_id
    left join (
        select
            course_id,
            sum(file_size_sum)/1048576 as file_size_mb
        from cdm_lms.course_item
        group by course_id
    ) lci
        on lci.course_id = lc.id
    left join (
        select
            lgb.course_id,
            count(distinct lgb.id) as column_count,
            count(distinct case when lgb.final_grade_ind = 1 then lgb.id end) as has_final_grade
        from cdm_lms.gradebook lgb
        inner join cdm_lms.grade lg
            on lg.gradebook_id = lgb.id
            and valid_ind = 1
        group by lgb.course_id
    ) gc
        on gc.course_id = lc.id
group by
    year(lt.start_date),
    h1.name,
    h1.hierarchy_name_seq,
    lt.name
order by
    year(lt.start_date),
    lt.name,
    h1.name
