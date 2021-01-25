-- File breakdown by course item type (course level)
select
    coi.item_type as "Course Item Type",
    coalesce(sum(coi.file_cnt), 0) as "Total File Count",
    coalesce(sum(coi.file_size_sum)/1000000000, 0) as "Total File Size Sum GB"
from cdm_lms.course_item as coi
join cdm_lms.course as cou
    on cou.id = coi.course_id
where 
    cou.name like '%Example%' -- Filter by course name
    -- Other possible filters. Uncomment to use as needed. (Remove the '--' at the start of each line)
    -- and cou.id = '' -- Filter by Blackboard Data Course ID
    -- and cou.source_id = '' -- Filter by Learn Course ID
    -- and coi.item_type = 'FILE' -- Filter by Course Item Type
group by "Course Item Type"
order by "Total File Size Sum GB" DESC