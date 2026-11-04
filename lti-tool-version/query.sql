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
