-- ------------------------------------
-- Which LTI tools a course has enabled
-- ------------------------------------
select
    c.course_number
    ,t.name as tool_name
    ,t.lti_version
from cdm_lms.course c
    inner join cdm_lms.course_tool ct
        on ct.course_id = c.id
        and ct.row_deleted_time is null
    inner join cdm_lms.tool t
        on t.id = ct.tool_id
        and t.tool_type = 'LTI Tool'
where c.course_number = 'REPLACE-ME'
;