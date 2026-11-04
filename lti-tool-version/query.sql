-- ----------------------------------------------------
-- Which LTI Tool is on version 1.1 (alternatively 1.3)
-- ----------------------------------------------------
select
    t.*
from cdm_lms.tool t
where t.tool_type = 'LTI Tool'
    and t.lti_version = '1.1'
    -- and t.lti_version = '1.3'
    and t.row_deleted_time is null
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