-- ---------------------------------------------------
-- How many LTI Tools with specific version do we have
-- ---------------------------------------------------
select
    t.lti_version
    ,count(*) as tool_cnt
from cdm_lms.tool t
where t.tool_type = 'LTI Tool'
    and t.row_deleted_time is null
group by 1
;
