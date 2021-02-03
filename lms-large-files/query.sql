-- Large files overview and usage (course level)
select
    coi.name as "Course Item Name",
    coalesce(coi.file_size_sum/1000000000, 0) as "Total File Size Sum GB",
    coalesce(sum(cia.duration_sum)/60, 0) as "Total Minutes Spent by All Course Members",
    coalesce(sum(cia.interaction_cnt), 0) as "Total Interactions by All Course Members"
from cdm_lms.course_item as coi
join cdm_lms.course as cou
    on cou.id = coi.course_id
join cdm_lms.course_item_activity as cia
    on cia.course_item_id = coi.id
where 
    cou.name like '%Example%'
    -- Other possible filters. Uncomment to use as needed. (Remove the '--' at the start of each line)
    -- and cou.id = '' -- Filter by Blackboard Data Course ID
    -- and cou.source_id = '' -- Filter by Learn Course ID
    -- and coi.item_type = 'FILE' -- Filter by Course Item Type
group by
    "Course Item Name",
    "Total File Size Sum GB"
order by "Total File Size Sum GB" DESC