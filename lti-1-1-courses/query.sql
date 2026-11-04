-- ---------------------------------------------------------
-- Courses that launched an LTI 1.1 tool in the last 90 days,
-- with their instructors
-- ---------------------------------------------------------
with lti_1_1_launch as (
    select
        a.tool_id
        ,a.course_id
        ,a.person_id
        ,a.accessed_time
    from cdm_lms.tool t
        inner join cdm_lms.activity a
            on a.tool_id = t.id
    where t.tool_type = 'LTI Tool'
        and t.lti_version = '1.1'
        and t.row_deleted_time is null
        and a.row_deleted_time is null
        and a.accessed_time >= dateadd(day, -90, current_date)
)
, course_launch as (
    select
        l.tool_id
        ,l.course_id
        ,count(distinct l.person_id) as users
        ,max(l.accessed_time) as last_launched
    from lti_1_1_launch l
    group by 1, 2
)
, course_instructor as (
    select
        pc.course_id
        ,listagg(distinct trim(nvl(p.first_name, '') || ' ' || nvl(p.last_name, '')), '; ') as instructors
        ,listagg(distinct p.email, '; ') as instructor_emails
    from cdm_lms.person_course pc
        inner join cdm_lms.person p
            on p.id = pc.person_id
    where pc.course_role = 'I'
        and pc.row_deleted_time is null
        and pc.course_id in (select course_id from course_launch)
    group by 1
)
select
    t.name as tool_name
    ,c.course_number
    ,c.name as course_name
    ,cl.users
    ,cl.last_launched
    ,ci.instructors
    ,ci.instructor_emails
from course_launch cl
    inner join cdm_lms.tool t
        on t.id = cl.tool_id
    inner join cdm_lms.course c
        on c.id = cl.course_id
    left join course_instructor ci
        on ci.course_id = cl.course_id
order by t.name, cl.users desc
;

-- ---------------------------------------------------------
-- LTI 1.1 tools launched in the last 90 days: how many courses
-- and users launched each one
-- ---------------------------------------------------------
select
    t.name
    ,count(distinct a.course_id) as courses
    ,count(distinct a.person_id) as users
    ,max(a.accessed_time) as last_launched
from cdm_lms.tool t
    inner join cdm_lms.activity a
        on a.tool_id = t.id
where t.tool_type = 'LTI Tool'
    and t.lti_version = '1.1'
    and t.row_deleted_time is null
    and a.row_deleted_time is null
    and a.accessed_time >= dateadd(day, -90, current_date)
group by 1
order by courses desc, users desc
;