select
    cou.name as course_name,
    cro.name as room_name,
    ses.name as session_name,
    per.name as person_name,
    (att.duration/60) as duration_minutes,
    att.first_join_time as first_join_time,
    att.last_leave_time as last_leave_time
from cdm_clb.session as ses
join cdm_clb.room as cro 
    on cro.id = ses.room_id
join cdm_clb.attendance as att 
    on att.session_id = ses.id
join cdm_clb.person as per 
    on per.id = att.person_id
join cdm_map.course_room as cor 
    on cor.clb_room_id = cro.id
join cdm_lms.course as cou 
    on cou.id = cor.lms_course_id
where
    cou.name = 'Course Name' -- Change to the course name you want to review or remove WHERE clause for all courses
    -- Add more filters if needed
order by
    session_name asc -- Ordering by session name, but can be changed to any other attribute