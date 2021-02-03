-- Collaborate recordings by size
select
    distinct clm.id as "Recording ID",
    clm.name as "Recording Name",
    cou.name as "Course Name",
    cls.name as "Session Name",
    (clm.duration/60000) as "Recording Duration (Minutes)",
    (clm.size*0.000000001) as "Recording Size (GB)"
from cdm_clb.media as clm
join cdm_clb.room as clr
    on clr.id = clm.room_id
join cdm_clb.session as cls
    on cls.room_id = clr.id
join cdm_map.course_room as cmc
    on cmc.clb_room_id = clr.id
join cdm_lms.course as cou
    on cou.id = cmc.lms_course_id
where clm.media_category = 'R'
order by "Recording Size (GB)" desc
limit 10