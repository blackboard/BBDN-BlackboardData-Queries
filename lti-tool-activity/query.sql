-- ---------------------------------
-- Which LTI tools carry any traffic
-- ---------------------------------
with lti_tool as (
    select
        t.id
        ,t.name
        ,t.lti_version
    from cdm_lms.tool t
    where t.tool_type = 'LTI Tool'
        -- UNCOMMENT to see only LTI Tools on version 1.1
        -- and t.lti_version = '1.1'
        and t.row_deleted_time is null
)
, course_tool_registration as (
    select
        ct.tool_id
        ,count(distinct ct.course_id) as enabled_as_course_tool
    from lti_tool t
        inner directed join cdm_lms.course_tool ct
            on ct.tool_id = t.id
    where ct.row_deleted_time is null
    group by 1
)
, tool_traffic as (
    select
        a.tool_id
        ,count(distinct a.id) as access_bucket_cnt
        ,count(distinct a.person_id) as distinct_users
        ,sum(a.interaction_cnt) as interaction_cnt
        ,max(a.last_accessed_time) as last_accessed
    from lti_tool t
        inner directed join cdm_lms.activity a
            on a.tool_id = t.id
    where a.row_deleted_time is null
    group by 1
)
select
    t.name
    ,t.lti_version
    ,ifnull(reg.enabled_as_course_tool, 0) as enabled_as_course_tool
    ,ifnull(tt.distinct_users, 0) as distinct_users
    -- Volume of access, in 30-minute buckets. Activity is stored per
    -- 30-minute slice, so several launches inside one slice count once,
    -- and one long session spanning two slices counts twice.
    ,ifnull(tt.access_bucket_cnt, 0) as tool_access_buckets
    -- Sum of recorded interactions across those buckets.
    ,ifnull(tt.interaction_cnt, 0) as interaction_cnt
    ,tt.last_accessed
from lti_tool t
    left join course_tool_registration reg
        on reg.tool_id = t.id
    left join tool_traffic tt
        on tt.tool_id = t.id
order by tt.last_accessed desc nulls last, tool_access_buckets desc
;