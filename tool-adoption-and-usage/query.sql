with items as (
    select
        lct.tool_id,
        count(distinct lci.course_id) as distinct_courses,
        count(distinct lci.id) as distinct_items,
        count(distinct lcia.id) as item_accesses,
        count(distinct lcia.course_item_id) as distinct_items_accessed,
        count(distinct lcia.person_id) as distinct_item_users,
        sum(lcia.duration_sum)/60 as item_minutes
    from cdm_lms.course_tool lct
    inner join cdm_lms.course_item lci
        on lci.course_tool_id = lct.id
    left join cdm_lms.course_item_activity lcia
        on lcia.course_item_id = lci.id
    group by lct.tool_id
    ) 

, tools as (
    select
        lct.tool_id,
        count(distinct lcta.course_id) as distinct_tool_course_accessed,
        count(distinct lcta.id) as tool_accesses,
        count(distinct lcta.person_id) as distinct_tool_users,
        sum(lcta.duration_sum)/60 as tool_minutes
    from cdm_lms.course_tool lct
    inner join cdm_lms.course_tool_activity lcta
        on lcta.course_tool_id = lct.id
    group by lct.tool_id
    ) 

select
    lt.plugin_vendor,
    lt.name,
    lt.plugin_desc,
    ifnull(i.distinct_courses,0) as distinct_courses,
    ifnull(i.distinct_items,0) as distinct_items,
    ifnull(i.distinct_items_accessed,0) as distinct_items_accessed,
    round(ifnull(i.distinct_items_accessed / i.distinct_items,0),2) as pc_items_accessed,
    ifnull(i.item_accesses,0) as item_accesses,
    ifnull(i.distinct_item_users,0) as distinct_item_users,
    round(ifnull(i.item_minutes,0),0) as item_minutes,
    ifnull(t.distinct_tool_course_accessed,0) as distinct_tool_course_accessed,
    ifnull(t.distinct_tool_users,0) as distinct_tool_users,
    ifnull(t.tool_accesses,0) as tool_accesses,
    round(ifnull(t.tool_minutes,0),0) as tool_minutes
from cdm_lms.tool lt
left join items i
    on i.tool_id = lt.id
left join tools t
    on t.tool_id = lt.id
order by item_minutes desc, tool_minutes desc   