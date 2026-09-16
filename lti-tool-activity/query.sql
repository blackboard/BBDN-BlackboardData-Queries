-- --------------------------------
-- Which LTI tool carry any traffic
-- --------------------------------
with lti_tool as (
    select
        t.*
    from cdm_lms.tool t
    where t.tool_type = 'LTI Tool'
        -- UNCOMMENT to see only LTI Tools on version 1.1
        -- and t.lti_version = '1.1'
        and t.row_deleted_time is null
)
select
    t.name
    ,t.lti_version
    ,count(distinct ct.course_id) as enabled_in_courses
    ,count(distinct a.id) as activity_cnt
    ,max(a.last_accessed_time) as last_launched
from lti_tool t
    left join cdm_lms.course_tool ct
        on ct.tool_id = t.id
        and ct.row_deleted_time is null
    left join cdm_lms.activity a
        on a.tool_id = t.id
        and a.row_deleted_time is null
group by 1, 2
order by activity_cnt desc
;