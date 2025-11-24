with recursive departments as (
    select
        id as department_id,
        parent_department_id,
        'Top' as parent_name,
        name as department_name,
        1 as level,
        name as department_path
    from cdm_aly.department
    where parent_department_id is null
    union all
    select
        d.id as department_id,
        d.parent_department_id,
        p.department_name as parent_name,
        d.name as department_name,
        p.level + 1 as level,
        concat(p.department_path,'||',d.name) as department_path
    from cdm_aly.department d
    inner join departments p
        on p.department_id = d.parent_department_id
)
--select * from departments;

, dept_content_current_score as ( 
    select
        d.department_name,
        d.department_path,
        ac.name as course_name,
        ac.code as course_id,
        aco.id as content_id,
        aco.type as filetype,
        acc.upload_type,
        acc.name as item_name,
        round(aco.size/1048576,2) as filesize_mb,
        round(avg(acs.numeric_score),2) as item_score,
        count(distinct rule) as rule_count,
        max(scoring_timestamp) as last_scored
    from cdm_aly.content_score acs
    inner join cdm_aly.content aco
        on aco.id = acs.content_id
    inner join cdm_aly.course_content acc
        on aco.id = acc.content_id
    inner join cdm_aly.course ac
        on ac.id = acc.course_id
    inner join cdm_aly.course_department acd
        on acd.course_id = acc.course_id
    inner join departments d
        on d.department_id = acd.department_id
    where 
        acs.numeric_score is not null
        and ac.row_deleted_time is null
        and acs.is_latest_score = true
    group by all
)
-- select * from dept_content_current_score limit 100;

, dept_course_current_score as (
    select
        department_name,
        department_path,
        course_name,
        course_id,
        round(avg(item_score),2) as avg_score,
        count(distinct content_id) as content_count,
        avg(filesize_mb) as avg_filesize_mb
    from dept_content_current_score 
    group by 1,2,3,4
)
--select * from dept_course_current_score limit 100;

, dept_current_score as (
    select
        department_name,
        department_path,
        round(avg(item_score),2) as avg_score,
        count(distinct course_id) as course_count,
        count(distinct content_id) as content_count,
        avg(filesize_mb) as avg_filesize_mb
    from dept_content_current_score 
    group by 1,2
)
--select * from dept_current_score limit 100;

/***** UNCOMMENT (remove "--" from) THE LINE BELOW YOUR QUESTION AND RUN THE QUERY TO SEE RESULTS *****/

/* Which departments have low-scoring (<75%) courses */
--select department_name, department_path, count(distinct course_id) as course_count, count(distinct case when avg_score <0.75 then course_id end) as low_ax_course_count, div0(low_ax_course_count,course_count) as low_ax_pc from dept_course_current_score group by 1,2 order by low_ax_pc desc;

/* Which courses have the highest proportion of low-accessibility content */
-- select department_name, department_path, course_name, count(distinct content_id) as content_count, count(distinct case when item_score <0.75 then content_id end) as low_ax_content_count, div0(low_ax_content_count,content_count) as low_ax_pc from dept_content_current_score group by 1,2,3 having content_count > 25 order by low_ax_pc desc limit 25;

/* Which items have the lowest accessibility? */
-- select * from dept_content_current_score order by item_score asc limit 100;

/***** Ignore everything below this line *****/
select 'Uncomment a line above and run the query again to see results' as oops
