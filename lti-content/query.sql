-- --------------------------------------------------------
-- What LTI content exists, where, and on which LTI version
-- --------------------------------------------------------
with ci_lti as (
    select
        ci.*
    from cdm_lms.course_item ci
    where ci.row_deleted_time is null
        and ci.stage:lti_detail is not null
)
select
    ci.stage:lti_detail::string as lti_tool
    ,nvl(t.lti_version, 'unresolved') as lti_version
    ,t.name as tool_name
    ,t.row_deleted_time is not null as tool_deleted
    ,ci.item_type_source_code
    ,ci.stage:lti_placement_type::string as placement_type
    ,ci.stage:lti_cloud_document_type::string as cloud_document_type
    ,count(distinct ci.course_id) as courses
    ,count(distinct ci.id) as items
    ,count(distinct cia.person_id) as distinct_users
    ,max(cia.last_accessed_time) as last_accessed
from ci_lti ci
    left join cdm_lms.course_tool ct
        on ct.id = ci.course_tool_id
    left join cdm_lms.tool t
        on t.id = ct.tool_id
        and t.tool_type = 'LTI Tool'
    left join cdm_lms.course_item_activity cia
        on cia.course_item_id = ci.id
        and cia.row_deleted_time is null
group by 1, 2, 3, 4, 5, 6, 7
order by items desc
;