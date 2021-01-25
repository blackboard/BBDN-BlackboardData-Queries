-- Top courses with most files and storage usage
select
    cou.id as "Blackboard Data ID",
    cou.source_id as "Learn Course ID",
    cou.name as "Course Name",
    cou.course_number as "Course Number",
    coalesce(sum(coi.file_cnt), 0) as "Total File Count",
    coalesce(sum(coi.file_size_sum)/1000000000, 0) as "Total File Size Sum GB"
from cdm_lms.course as cou
join cdm_lms.course_item as coi
    on coi.course_id = cou.id
group by
    cou.id,
    cou.source_id,
    cou.name,
    cou.course_number
order by "Total File Size Sum GB" DESC
limit 10 -- Change to the number of courses you'd like to see